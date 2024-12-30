//
//  CheckLoginUseCase.swift
//  LuminaView
//
//  Created by 김성준 on 11/26/24.
//

import Foundation

final class CheckLoginUseCase {
    let repository: LoginRepository
    
    init(repository: LoginRepository) {
        self.repository = repository
    }
    
    func exec() -> String? {
        repository.fetchUID()
    }
}
