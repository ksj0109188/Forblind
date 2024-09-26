//
//  GeminiWebRepository.swift
//  LuminaView
//
//  Created by 김성준 on 7/16/24.
//

import UIKit
import GoogleGenerativeAI
import RxSwift
import CoreMedia

//protocol GuideAPIWebRepository {
//    func setupApiConnect() -> PublishSubject<CMSampleBuffer>
//}

//final class GeminiWebRepository: GuideAPIWebRepository {
//    func setupApiConnect() -> RxSwift.PublishSubject<Data> {
//        
//    }
//    
//    var model: GenerativeModel!
//    let imageSubject = PublishSubject<UIImage>()
//    let disposeBag = DisposeBag()
//    
//    func configure(config: GeminiAPIConfig) {
//        model = GenerativeModel(name: config.modelName, apiKey: config.apiKey)
//    }
//     
//    func setupApiConnect() -> PublishSubject<UIImage> {
//        imageSubject
//            .buffer(timeSpan: .seconds(3), count: Int.max, scheduler: MainScheduler.instance)
//            .subscribe(onNext: { images in
//                //TODO: 약한참조가 필요한지 체크 필요
//                Task {
//                    await self.apiReqeust(images)
//                }
//            })
//            .disposed(by: disposeBag)
//            
//        return imageSubject
//    }
//    
//    private func apiReqeust(_ images: [UIImage]) async {
//        let prompt = "앞의 사진들을 비교해서 어떤 물체가 다가오고 있는지, 가장 가까운 물체의 거리가 대략 몇m인지 추측해서 알려줘"
//        var fullResponse = ""
//        
//        if !images.isEmpty {
//            let contentStream2 = model.generateContentStream(prompt, images.compactMap({ $0}))
//            
//            do {
//                for try await chunk in contentStream2 {
//                    if let text = chunk.text {
//                        fullResponse += text
//                    }
//                }
//            } catch(let error) {
//                debugPrint(error)
//            }
//            
//            print(fullResponse)
//            UIAccessibility.post(notification: .announcement, argument: fullResponse)
//        }
//    }
//}
