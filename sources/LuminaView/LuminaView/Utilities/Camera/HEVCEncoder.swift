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

class HEVCEncoder: CameraEncodable {
    private var compressionSession: VTCompressionSession?
    
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
            refcon: UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque()),  // HEVCEncoder 인스턴스를 refcon에 설정
            compressionSessionOut: &compressionSession
        )
        
        VTSessionSetProperty(compressionSession!, key: kVTCompressionPropertyKey_AverageBitRate, value: bitrate as CFTypeRef)
        VTSessionSetProperty(compressionSession!, key: kVTCompressionPropertyKey_ProfileLevel, value: kVTProfileLevel_HEVC_Main_AutoLevel)
        VTCompressionSessionPrepareToEncodeFrames(compressionSession!)
        
        if status != noErr {
            debugPrint("Failed to create compression session: \(status)")
            return
        }
        debugPrint("Compression session created successfully")
        
    }
    
    func sendCompressedData(sampleBuffer: CMSampleBuffer) -> Data? {
        guard let blockBuffer = CMSampleBufferGetDataBuffer(sampleBuffer) else {
            return nil
        }
        
        var length = 0
        var dataPointer: UnsafeMutablePointer<Int8>?
        
        // 압축된 데이터를 가져옴
        CMBlockBufferGetDataPointer(blockBuffer, atOffset: 0, lengthAtOffsetOut: nil, totalLengthOut: &length, dataPointerOut: &dataPointer)
        
        if let dataPointer = dataPointer {
            let data = Data(bytes: dataPointer, count: length)
            
            // NAL 유닛 앞에 스타트 코드 추가
            var nalUnitData = Data()
            let startCode: [UInt8] = [0x00, 0x00, 0x00, 0x01]
            
            // NAL 단위로 나누기 (NAL 유닛의 크기를 기준으로 반복)
            var offset = 0
            while offset < data.count {
                var nalUnitLength: UInt32 = 0
                memcpy(&nalUnitLength, dataPointer + offset, 4)
                nalUnitLength = CFSwapInt32BigToHost(nalUnitLength)  // Big-endian to host-endian
                
                let nalUnitStart = offset + 4
                let nalUnitEnd = nalUnitStart + Int(nalUnitLength)
                
                if nalUnitEnd <= data.count {
                    // 스타트 코드 추가
                    nalUnitData.append(contentsOf: startCode)
                    nalUnitData.append(data[nalUnitStart..<nalUnitEnd])
                }
                
                offset = nalUnitEnd
            }
            
            return nalUnitData
        }
        
        return nil
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
            outputHandler: { status, flags, buffer in
                if let buffer = buffer {
                    if let attachments = CMSampleBufferGetSampleAttachmentsArray(buffer, createIfNecessary: false) {
                        // SPS/PPS 추출 및 전송
                        for attachment in attachments as! [[String: Any]] {
//                            print(attachment[kCMSampleAttachmentKey_NotSync as String] as? Bool)
                            if let isNotSync = attachment[kCMSampleAttachmentKey_NotSync as String] as? Bool, isNotSync {
                                // SPS/PPS인지 확인
//                                print(buffer)
                                if let encodedData = self.sendCompressedData(sampleBuffer: buffer) {
                                    completion(encodedData)
                                }
                            }
                        }
                    }
                    completion(nil)
                }
            }
        )
    }
}
