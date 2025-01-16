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
    private var disposeBag = DisposeBag()
    private var socket: WebSocket
    private var request: URLRequest
    let encoder: CameraEncodable = HEVCEncoder()
    var resultStream: PublishSubject<String>?
    var encodingSubject: PublishSubject<Data>?
    var requestStream: PublishSubject<CMSampleBuffer>?
    
    init(config: WebSocketAPIConfig) {
        let url = URL(string: config.url)!
        var request = URLRequest(url: url)
        
        request.timeoutInterval = 10
        
        self.request = request
        //TODO: Third party 말고 URLSession.websocket을 사용해 연결 하도록 처리히자.
        socket = WebSocket(request: request)
        socket.delegate = self
    }
    
    deinit {
        debugPrint("WebSocketRepository is Deinited")
    }
    
    func setupAPIConnect(requestStream: RxSwift.PublishSubject<CMSampleBuffer>) {
        reconnectWebSocket()
        encodingSubject = PublishSubject<Data>()
        
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
            .subscribe(onNext: { self.encodingSubject?.onNext($0) })
            .disposed(by: disposeBag)
        
        encodingSubject?
            .buffer(timeSpan: .seconds(5), count: Int.max, scheduler: ConcurrentDispatchQueueScheduler(qos: .userInitiated))
            .subscribe(onNext: { [weak self] encodedChunks in
                debugPrint("encodingSubject subscribe")
                guard let self = self else { return }
                let mergedData = Data(encodedChunks.joined())
                self.sendToWebSocket(data: mergedData)
            })
            .disposed(by: disposeBag)
    }
    
    func stopAPIConnect() {
        debugPrint("stopAPIConnect")
        encodingSubject?.onCompleted()
        encodingSubject = nil
        requestStream?.onCompleted()
        socket.disconnect()
    }
    
    func setupResultStream(resultStream: PublishSubject<String>) {
        self.resultStream = resultStream
    }
    
    func reconnectWebSocket() {
        socket.disconnect()
        socket = WebSocket(request: request)
        socket.delegate = self
        socket.connect()
    }
    
    func sendToWebSocket(data: Data) {
        print("sendToWebSocket", data)

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
            debugPrint("WebSocket is connected: \(headers)")
        case .disconnected(let reason, let code):
            resultStream?.onError(WebSocketErrorTypes.disconnected)
            stopAPIConnect()
            debugPrint("WebSocket is disconnected: \(reason) with code: \(code)")
        case .text(let string):
            resultStream?.onNext(string)
        case .binary(let data):
            debugPrint("Received data: \(data)")
        case .error(let error):
            resultStream?.onError(WebSocketErrorTypes.serverError)
            stopAPIConnect()
            debugPrint("WebSocket encountered an error: \(error?.localizedDescription ?? "")")
        case .viabilityChanged(let _):
            break
        default:
            resultStream?.onError(WebSocketErrorTypes.undefinedError)
            stopAPIConnect()
            debugPrint("didReceive default case")
            break
        }
    }
}

enum WebSocketErrorTypes: Error {
    case disconnected
    case connectionFailed
    case serverError
    case undefinedError
}
