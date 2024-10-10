//
//  HEVCEncoder.swift
//  LuminaView
//
//  Created by 김성준 on 9/19/24.
//

import VideoToolbox
import Foundation

protocol CameraEncodable {
    func encodeAndReturnData(sampleBuffer: CMSampleBuffer, completion: @escaping (Data?) -> Void)
}

final class HEVCEncoder: CameraEncodable {
    private var compressionSession: VTCompressionSession?
    private var vps: Data?
    private var sps: Data?
    private var pps: Data?
    
    init() {
        setupCompressionSession()
    }
    
    private func setupCompressionSession() {
        let width = 1280
        let height = 720
        let bitrate = 1000000  // 1Mbps
        
        let status = VTCompressionSessionCreate(
            allocator: nil,
            width: Int32(width),
            height: Int32(height),
            codecType: kCMVideoCodecType_HEVC,
            encoderSpecification: nil,
            imageBufferAttributes: nil,
            compressedDataAllocator: nil,
            outputCallback: nil,
            refcon: UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque()),
            compressionSessionOut: &compressionSession
        )
        
        
        VTSessionSetProperty(compressionSession!, key: kVTCompressionPropertyKey_RealTime, value: kCFBooleanTrue)
        VTSessionSetProperty(compressionSession!, key: kVTCompressionPropertyKey_ProfileLevel, value: kVTProfileLevel_HEVC_Main_AutoLevel)
        VTSessionSetProperty(compressionSession!, key: kVTCompressionPropertyKey_AverageBitRate, value: bitrate as CFTypeRef)
        VTSessionSetProperty(compressionSession!, key: kVTCompressionPropertyKey_AllowFrameReordering, value: kCFBooleanFalse)
        VTSessionSetProperty(compressionSession!, key: kVTCompressionPropertyKey_ExpectedFrameRate, value: 30 as CFTypeRef)
        VTSessionSetProperty(compressionSession!, key: kVTCompressionPropertyKey_MaxKeyFrameInterval, value: 60 as CFTypeRef)
        VTSessionSetProperty(compressionSession!, key: kVTCompressionPropertyKey_MaxKeyFrameIntervalDuration, value: 2 as CFTypeRef)
        
        
        VTCompressionSessionPrepareToEncodeFrames(compressionSession!)
        
        if status != noErr {
            debugPrint("Failed to create compression session: \(status)")
            return
        }
        debugPrint("Compression session created successfully")
        
    }
    
    func sendCompressedData(sampleBuffer: CMSampleBuffer) -> Data? {
        guard let dataBuffer = CMSampleBufferGetDataBuffer(sampleBuffer) else {
            print("Failed to get data buffer from sample buffer")
            return nil
        }

        var totalLength: Int = 0
        var dataPointerRef: UnsafeMutablePointer<Int8>?
        
        let status = CMBlockBufferGetDataPointer(dataBuffer,
                                                 atOffset: 0,
                                                 lengthAtOffsetOut: nil,
                                                 totalLengthOut: &totalLength,
                                                 dataPointerOut: &dataPointerRef)
        
        guard status == kCMBlockBufferNoErr else {
            print("Error getting data pointer: \(status)")
            return nil
        }
        
        guard let dataPointer = dataPointerRef else {
            print("Data pointer is nil")
            return nil
        }
        
        let bufferData = Data(bytes: dataPointer, count: totalLength)
        
        var nalUnitData = Data()
        let startCode: [UInt8] = [0x00, 0x00, 0x00, 0x01]
        
        // VPS, SPS, PPS를 키 프레임에만 추가
        if isKeyFrame(sampleBuffer) {
            if let vps = self.vps {
                nalUnitData.append(contentsOf: startCode)
                nalUnitData.append(vps)
            }
            if let sps = self.sps {
                nalUnitData.append(contentsOf: startCode)
                nalUnitData.append(sps)
            }
            if let pps = self.pps {
                nalUnitData.append(contentsOf: startCode)
                nalUnitData.append(pps)
            }
        }
        
        // 인코딩된 프레임 데이터 추가
        var offset = 0
        while offset < totalLength {
            // 안전하게 NAL 유닛 길이 읽기
            guard offset + 4 <= totalLength else { break }
            let nalUnitLength = UInt32(bufferData[offset]) << 24 |
                                UInt32(bufferData[offset + 1]) << 16 |
                                UInt32(bufferData[offset + 2]) << 8 |
                                UInt32(bufferData[offset + 3])
            
            let nalUnitStart = offset + 4 // 4바이트 길이 필드 이후
            let nalUnitEnd = nalUnitStart + Int(nalUnitLength)
            
            guard nalUnitEnd <= totalLength else { break }
            
            nalUnitData.append(contentsOf: startCode)
            nalUnitData.append(bufferData[nalUnitStart..<nalUnitEnd])
            
            offset = nalUnitEnd
        }
        
        return nalUnitData
    }
    
    func isKeyFrame(_ sampleBuffer: CMSampleBuffer) -> Bool {
        guard let attachments = CMSampleBufferGetSampleAttachmentsArray(sampleBuffer, createIfNecessary: false) as? [[CFString: Any]],
              let attachment = attachments.first,
              let dependsOnOthers = attachment[kCMSampleAttachmentKey_DependsOnOthers] as? Bool else {
            return false
        }
        return !dependsOnOthers
    }
    
    // CMSampleBuffer를 받아 H.265로 인코딩하는 함수
    func encodeAndReturnData(sampleBuffer: CMSampleBuffer, completion: @escaping (Data?) -> Void) {
        guard let compressionSession = compressionSession else {
            completion(nil)
            return
        }
        
        let presentationTimeStamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
        let duration = CMSampleBufferGetDuration(sampleBuffer)
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            completion(nil)
            return
        }
        
        VTCompressionSessionEncodeFrame(
            compressionSession,
            imageBuffer: imageBuffer,
            presentationTimeStamp: presentationTimeStamp,
            duration: duration,
            frameProperties: nil,
            infoFlagsOut: nil,
            outputHandler: { [weak self] status, flags, buffer in
                guard let self = self, let buffer = buffer else {
                    print("Encoding failed: no buffer or self is nil")
                    completion(nil)
                    return
                }
                
                if status != noErr {
                    print("Encoding failed with status: \(status)")
                    completion(nil)
                    return
                }
                
                if let formatDescription = CMSampleBufferGetFormatDescription(buffer) {
                    self.extractParameterSets(from: formatDescription)
                }
                
                if let encodedData = self.sendCompressedData(sampleBuffer: buffer) {
                    self.analyzeNALUnits(encodedData)
                    completion(encodedData)
                } else {
                    completion(nil)
                }
            }
        )
    }
}

extension HEVCEncoder {
    func analyzeNALUnits(_ data: Data) {
        let startCode: [UInt8] = [0x00, 0x00, 0x00, 0x01]
        var offset = 0
        
        while offset < data.count - 4 {
            if data[offset..<offset+4] == Data(startCode) {
                let nalUnitType = (data[offset + 4] & 0x7E) >> 1

                switch nalUnitType {
                    case 32:
                        self.vps = data[offset..<data.count]
                    case 33:
                        self.sps = data[offset..<data.count]
                    case 34:
                        self.pps = data[offset..<data.count]
                    case 39:
                        break
                    case 0...9:
                        break
                    case 16...21:
                        break
                    default:
                        break
                }
                
                offset += 4
            } else {
                offset += 1
            }
        }
    }
    
    private func extractParameterSets(from formatDescription: CMFormatDescription) {
        var parameterSetCount = 0
        CMVideoFormatDescriptionGetHEVCParameterSetAtIndex(formatDescription,
                                                           parameterSetIndex: 0,
                                                           parameterSetPointerOut: nil,
                                                           parameterSetSizeOut: nil,
                                                           parameterSetCountOut: &parameterSetCount,
                                                           nalUnitHeaderLengthOut: nil)
        
        for i in 0..<parameterSetCount {
            var parameterSetPointer: UnsafePointer<UInt8>?
            var parameterSetSize: Int = 0
            
            CMVideoFormatDescriptionGetHEVCParameterSetAtIndex(formatDescription,
                                                               parameterSetIndex: i,
                                                               parameterSetPointerOut: &parameterSetPointer,
                                                               parameterSetSizeOut: &parameterSetSize,
                                                               parameterSetCountOut: nil,
                                                               nalUnitHeaderLengthOut: nil)
            
            if let pointer = parameterSetPointer {
                let data = Data(bytes: pointer, count: parameterSetSize)
                let nalUnitType = (data[0] & 0x7E) >> 1
                
                switch nalUnitType {
                    case 32:
                        self.vps = data
                    case 33:
                        self.sps = data
                    case 34:
                        self.pps = data
                    default:
                        break
                }
            }
        }
    }
}
