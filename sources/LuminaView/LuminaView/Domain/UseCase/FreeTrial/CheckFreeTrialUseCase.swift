//
//  checkFreeTrialUseCase.swift
//  LuminaView
//
//  Created by 김성준 on 10/11/24.
//

import Foundation
import RxSwift

final class CheckFreeTrialUseCase {
    let repository: FreeTrialRepository
    
    init(repository: FreeTrialRepository) {
        self.repository = repository
    }
    
    func execute(requestValue: FreeTrialUseCaseRequestValue) -> Bool {
        repository.isFreeTrial(request: requestValue)
    }
    
}

struct FreeTrialUseCaseRequestValue {
    let entity: FreeTrial
    let limitCount: Int
}
