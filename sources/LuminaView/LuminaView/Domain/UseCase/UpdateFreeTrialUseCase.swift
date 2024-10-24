//
//  Update.swift
//  LuminaView
//
//  Created by 김성준 on 10/18/24.
//

import Foundation

final class UpdateFreeTrialUseCase {
    let repository: FreeTrialRepository
    
    init(repository: FreeTrialRepository) {
        self.repository = repository
    }
    
    func execute(requestValue: FreeTrialUseCaseRequestValue) {
        repository.increaseRespondCount(request: requestValue)
    }
}
