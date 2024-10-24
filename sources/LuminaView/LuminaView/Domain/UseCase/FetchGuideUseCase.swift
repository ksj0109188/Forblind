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
    
    func execute(requestStream: PublishSubject<CMSampleBuffer>, resultStream: PublishSubject<Result<String, Error>>) {
        repository.setupApiConnect(requestStream: requestStream)
        repository.setupResultStream(resultStream: resultStream)
    }

}
