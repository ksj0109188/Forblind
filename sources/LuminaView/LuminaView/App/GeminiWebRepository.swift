//
//  GeminiWebRepository.swift
//  LuminaView
//
//  Created by 김성준 on 7/16/24.
//

import UIKit
import GoogleGenerativeAI
import RxSwift

final class GeminiWebRepository {
    let model = GenerativeModel(name: "gemini-1.5-flash", apiKey: "Tempkey")
    let imageSubject = PublishSubject<UIImage>()
    let disposeBag = DisposeBag()
    
    private func setupApiConnect() {
        imageSubject
            .buffer(timeSpan: .seconds(5), count: Int.max, scheduler: MainScheduler.instance)
            .subscribe(onNext: { images in
                //TODO: 약한참조가 필요한지 체크 필요
                Task {
                    await self.apiReqeust(images)
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func apiReqeust(_ images: [UIImage]) async {
        let prompt = "앞의 사진들을 비교해서 어떤 물체가 다가오고 있는지, 가장 가까운 물체의 거리가 대략 몇m인지 추측해서 알려줘"
        var fullResponse = ""
        
        let contentStream2 = model.generateContentStream(prompt, images.compactMap({ $0}))
        
        do {
            for try await chunk in contentStream2 {
                if let text = chunk.text {
                    fullResponse += text
                }
            }
        } catch(let error) {
            print(error)
        }
        print(fullResponse)
    }
}
