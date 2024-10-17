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
import AVFAudio

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
        let url = URL(string: "ws://192.168.45.219:8080/data-upload")!
        var request = URLRequest(url: url)
        
        request.timeoutInterval = 10
        //TODO: Third party 말고 URLSession.websocket을 사용해 연결 하도록 처리히자.
        socket = WebSocket(request: request)
        socket.delegate = self
        
        socket.connect()
    }
    
    func setupApiConnect() -> PublishSubject<CMSampleBuffer> {
        let encodingSubject = PublishSubject<Data>()
        //
        requestAPISubject
            .observe(on: ConcurrentDispatchQueueScheduler(qos: .userInitiated))
            .flatMap { [weak self] buffer -> Observable<Data> in
                guard let self = self else { return Observable.empty() }
                return Observable.create { observer in
                    self.encoder.encodeAndReturnData(sampleBuffer: buffer) { encodedData in
                        if let data = encodedData {
                            observer.onNext(data)
                        }
                        observer.onCompleted()
                    }
                    return Disposables.create()
                }
            }
            .subscribe(onNext: { encodingSubject.onNext($0) })
            .disposed(by: disposeBag)

        encodingSubject
            .buffer(timeSpan: .seconds(5), count: Int.max, scheduler: ConcurrentDispatchQueueScheduler(qos: .userInitiated))
            .subscribe(onNext: { [weak self] encodedChunks in
                guard let self = self else { return }
                let mergedData = Data(encodedChunks.joined())
                self.sendToWebSocket(data: mergedData)
            })
            .disposed(by: disposeBag)

        return requestAPISubject
    }
    
    func sendToWebSocket(data: Data) {
        print("sendToWebSocket", data)
        if isWorked {
            return
        }
        
        let chunkSize = 4000  // 청크 크기를 WebSocket의 버퍼 크기보다 작게 설정
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
                "chunkSize": chunk.count - 1,
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
        switch event {
            case .connected(let headers):
                print("WebSocket is connected: \(headers)")
            case .disconnected(let reason, let code):
                print("WebSocket is disconnected: \(reason) with code: \(code)")
            case .text(let string):
                print("Received text: \(string)")
                let utterance = AVSpeechUtterance(string: string)
                let synthesizer = AVSpeechSynthesizer()
                
                synthesizer.speak(utterance)
            case .binary(let data):
                print("Received data: \(data)")
            case .error(let error):
                print("WebSocket encountered an error: \(error?.localizedDescription ?? "")")
            default:
                break
        }
    }
}
