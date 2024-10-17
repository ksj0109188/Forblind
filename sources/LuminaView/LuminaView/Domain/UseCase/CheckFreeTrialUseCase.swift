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
    
    init(repository: FreeTrialRepository, entity: FreeTrial) {
        self.repository = repository
    }
    
    func execute(requestValue: CheckFreeTrialUseCaseRequestValue) -> Bool {
        repository.isFreeTrial(request: requestValue)
    }
    
}

struct CheckFreeTrialUseCaseRequestValue {
    let entity: FreeTrial
    let limitCount: Int
}
