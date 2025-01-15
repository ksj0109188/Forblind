//
//  StopGuideUseCase.swift
//  LuminaView
//
//  Created by 김성준 on 1/15/25.
//

import Foundation

//TODO: 서버 에러 발생시 viewcontroller에 경고창 출력 안됨 확인 해보자
//TODO: 주행모드 정지시, encodingSubject등 이런 것들도 종료해야한다.

final class StopGuideUseCase {
    let repository: GuideAPIWebRepository
    
    init(repository: GuideAPIWebRepository) {
        self.repository = repository
    }
    
    func execute() {
        repository.stopAPIConnect()
    }
}
