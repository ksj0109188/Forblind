//
//  FetchGuideUseCase.swift
//  LuminaView
//
//  Created by 김성준 on 7/18/24.
//

import UIKit
import RxSwift
import CoreMedia

final class FetchGuideUseCase {
    let guideAPIWebRepository: GuideAPIWebRepository
    
    init(guideAPIWebRepository: GuideAPIWebRepository) {
        self.guideAPIWebRepository = guideAPIWebRepository
    }
    
    func setupApiConnect() -> PublishSubject<CMSampleBuffer> {
        guideAPIWebRepository.setupApiConnect()
    }
}
