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

protocol SendableWebSocket: AnyObject {
    func sendToWebSocket(data: Data)
}

final class WebSocketRepository: GuideAPIWebRepository, SendableWebSocket {
    private let disposeBag = DisposeBag()
    private var socket: WebSocket
    private var isSocketconnected: Bool = false
    let encoder: CameraEncodable = HEVCEncoder()
    var resultStream: PublishSubject<Result<String, Error>>?
    
    deinit {
        debugPrint("WebSocketRepository is Deinited")
    }
    
    func setupApiConnect(requestStream: RxSwift.PublishSubject<CMSampleBuffer>) {
        let encodingSubject = PublishSubject<Data>()
        
        requestStream
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
                if isSocketconnected {
                    self.sendToWebSocket(data: mergedData)
                }
            })
            .disposed(by: disposeBag)
    }
    
    func setupResultStream(resultStream: PublishSubject<Result<String, Error>>) {
        self.resultStream = resultStream
    }
    
    init(config: WebSocketAPIConfig) {
        let url = URL(string: config.url)!
        var request = URLRequest(url: url)
        
        request.timeoutInterval = 10
        //TODO: Third party 말고 URLSession.websocket을 사용해 연결 하도록 처리히자.
        socket = WebSocket(request: request)
        socket.delegate = self
        
        socket.connect()
    }
    
    func sendToWebSocket(data: Data) {
        print("sendToWebSocket", data)
        guard !isSocketconnected else {
            debugPrint("isSocketconnected property is false")
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
            
            
            let jsonData = try! JSONSerialization.data(withJSONObject: metadata)
            
            socket.write(data: jsonData)
            
            offset += chunkSize
        }
    }
}

extension WebSocketRepository: WebSocketDelegate {
    func didReceive(event: Starscream.WebSocketEvent, client: any Starscream.WebSocketClient) {
        switch event {
        case .connected(let headers):
            isSocketconnected = true
            print("WebSocket is connected: \(headers)")
        case .disconnected(let reason, let code):
            isSocketconnected = false
            print("WebSocket is disconnected: \(reason) with code: \(code)")
        case .text(let string):
            guard let resultStream = resultStream else {
                isSocketconnected = false
                return
            }
            resultStream.onNext(.success(string))
        case .binary(let data):
            print("Received data: \(data)")
        case .error(let error):
            isSocketconnected = false
            print("WebSocket encountered an error: \(error?.localizedDescription ?? "")")
        default:
            isSocketconnected = false
            print("didReceive default case")
            break
        }
    }
}

