//
//  WebSocketRepository.swift
//  LuminaView
//
//  Created by 김성준 on 9/19/24.
//

import Foundation
import RxSwift
import Starscream
import CoreMedia

protocol GuideAPIWebRepository {
    func setupApiConnect() -> PublishSubject<CMSampleBuffer>
}

protocol SendableWebSocket: AnyObject {
    func sendToWebSocket(data: Data)
}

class WebSocketRepository: GuideAPIWebRepository, SendableWebSocket {
    let requestAPISubject = PublishSubject<CMSampleBuffer>()
    let disposeBag = DisposeBag()
    private var socket: WebSocket!
    let encoder: CameraEncodable = HEVCEncoder()
    var isWorked: Bool = false
    
    init(config: WebSocketAPIConfig) {
        //        let url = URL(string: config.url)!
        let url = URL(string: "ws://loacalhost:8080/data-upload")!
        var request = URLRequest(url: url)
        
        request.timeoutInterval = 10
        //TODO: Third party 말고 URLSession.websocket을 사용해 연결 하도록 처리히자.
        socket = WebSocket(request: request)
        socket.delegate = self
        
        socket.connect()
    }
    
    func setupApiConnect() -> PublishSubject<CMSampleBuffer> {
        requestAPISubject
            .buffer(timeSpan: .seconds(3), count: Int.max, scheduler: MainScheduler.instance)
            .subscribe(onNext: { buffers in
                var mergedData = Data()
                
                for buffer in buffers {
                    self.encoder.encodeAndReturnData(sampleBuffer: buffer) { encodedData in
                        if let encodedData = encodedData {
                            mergedData.append(encodedData)
                        }
                    }
                }

                self.sendToWebSocket(data: mergedData)
            })
            .disposed(by: disposeBag)
        
        return requestAPISubject
    }
    
    func sendToWebSocket(data: Data) {
        if isWorked {
            return
        }
        let chunkSize = 4192  // 청크 크기를 WebSocket의 버퍼 크기보다 작게 설정
        var offset = 0
        let totalChunks = (data.count + chunkSize - 1) / chunkSize  // 전체 청크 수 계산
        
        while offset < data.count {
            let chunk = data.subdata(in: offset..<min(offset + chunkSize, data.count))
            let isLastChunk = offset + chunkSize >= data.count // 마지막 청크인지 확인
            
            // 청크 메타데이터 정의
            let chunkIndex = offset / chunkSize
            let metadata: [String: Any] = [
                "chunkIndex": chunkIndex,
                "totalChunks": totalChunks,
                "chunkSize": chunk.count,
                "isLastChunk": isLastChunk,
                "data": chunk.base64EncodedString() // 청크를 Base64로 인코딩
            ]
            
            // JSON으로 변환
            let jsonData = try! JSONSerialization.data(withJSONObject: metadata)
                // WebSocket으로 메타데이터 전송
                socket.write(data: jsonData)
            
            offset += chunkSize
        }
        
        isWorked = true
    }
    
}

extension WebSocketRepository: WebSocketDelegate {
    func didReceive(event: Starscream.WebSocketEvent, client: any Starscream.WebSocketClient) {
        print(event)
        print(client)
        //        print(fullResponse)
        //        UIAccessibility.post(notification: .announcement, argument: fullResponse)
    }
    
    func didReceive(event: WebSocketEvent, client: WebSocket) {
        switch event {
            case .connected(let headers):
                print("WebSocket is connected: \(headers)")
            case .disconnected(let reason, let code):
                print("WebSocket is disconnected: \(reason) with code: \(code)")
            case .text(let string):
                print("Received text: \(string)")
            case .binary(let data):
                print("Received data: \(data)")
            case .error(let error):
                print("WebSocket encountered an error: \(error?.localizedDescription ?? "")")
            default:
                break
        }
    }
}
