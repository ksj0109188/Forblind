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
    let repository: GuideAPIWebRepository
    
    init(guideAPIWebRepository: GuideAPIWebRepository) {
        self.repository = guideAPIWebRepository
    }
    
    func setupApiConnect() -> PublishSubject<CMSampleBuffer> {
        repository.setupApiConnect()
    }
}
