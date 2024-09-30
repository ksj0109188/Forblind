//
//  HEVCEncoder.swift
//  LuminaView
//
//  Created by 김성준 on 9/19/24.
//

import VideoToolbox
import Foundation

protocol CameraEncodable {
    func encodeAndReturnData(sampleBuffer: CMSampleBuffer, completion: @escaping (Data?) -> Void) async
}

class HEVCEncoder: CameraEncodable {
    private var compressionSession: VTCompressionSession?
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
            refcon: UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque()),  // HEVCEncoder 인스턴스를 refcon에 설정
            compressionSessionOut: &compressionSession
        )
        
      
        VTSessionSetProperty(compressionSession!, key: kVTCompressionPropertyKey_RealTime, value: kCFBooleanTrue)
               VTSessionSetProperty(compressionSession!, key: kVTCompressionPropertyKey_ProfileLevel, value: kVTProfileLevel_HEVC_Main_AutoLevel)
               VTSessionSetProperty(compressionSession!, key: kVTCompressionPropertyKey_AverageBitRate, value: bitrate as CFTypeRef)
               VTSessionSetProperty(compressionSession!, key: kVTCompressionPropertyKey_AllowFrameReordering, value: kCFBooleanFalse)
               VTSessionSetProperty(compressionSession!, key: kVTCompressionPropertyKey_ExpectedFrameRate, value: 30 as CFTypeRef)

           
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
        
        // 블록의 총 길이를 가져옴
        var totalLength = CMBlockBufferGetDataLength(blockBuffer)
        var dataPointer: UnsafeMutablePointer<CChar>?
        
        // 압축된 데이터의 포인터를 가져옴
        let status = CMBlockBufferGetDataPointer(blockBuffer, atOffset: 0, lengthAtOffsetOut: nil, totalLengthOut: &totalLength, dataPointerOut: &dataPointer)
        
        guard status == noErr, let dataPointer = dataPointer else {
            return nil
        }
        
        let data = Data(bytes: dataPointer, count: totalLength)
        var nalUnitData = Data()
        let startCode: [UInt8] = [0x00, 0x00, 0x00, 0x01]
//        return data
        var offset = 0
        
        while offset < data.count {
            var nalUnitLength: UInt32 = 0
            memcpy(&nalUnitLength, dataPointer + offset, MemoryLayout<UInt32>.size)
            nalUnitLength = CFSwapInt32(nalUnitLength)

            let nalUnitStart = offset + MemoryLayout<UInt32>.size
            let nalUnitEnd = nalUnitStart + Int(nalUnitLength)

            if nalUnitEnd <= data.count {
                let nalUnitHeader = data[nalUnitStart]
                let nalUnitType = nalUnitHeader & 0x7E >> 1 // NAL unit type 추출
                // SPS와 PPS 검사
                if nalUnitType == 33 {
                    // SPS 처리
                    print("33 checked")
                } else if nalUnitType == 34 {
                    // PPS 처리
                    print("34 checked")
                }

                nalUnitData.append(contentsOf: startCode)
                nalUnitData.append(data[nalUnitStart..<nalUnitEnd])
            }

            offset = nalUnitEnd
        }
        
        return nalUnitData
    }
    
    // CMSampleBuffer를 받아 H.265로 인코딩하는 함수
    func encodeAndReturnData(sampleBuffer: CMSampleBuffer, completion: @escaping (Data?) -> Void) async {
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
                    // NAL 유닛 데이터 추출
                    let encodedData = self.sendCompressedData(sampleBuffer: buffer)
                    
                    // SPS 및 PPS를 전송할 데이터가 있는지 확인
                    if let attachments = CMSampleBufferGetSampleAttachmentsArray(buffer, createIfNecessary: false) {
                        for attachment in attachments as! [[String: Any]] {
                            print(attachment)
                        }
                    }
                    
                    // 필요에 따라 추가적인 작업을 할 수 있습니다
                    completion(nil)  // 최종적으로 nil을 반환하여 호출자를 알림
                }
            }
        )
    }
}
