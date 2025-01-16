//
//  SaveTempUsageUsecase.swift
//  LuminaView
//
//  Created by 김성준 on 1/10/25.
//

import Foundation

final class SaveTempUsageUsecase {
    let repository: LocalUsageRepository
    
    init(repository: LocalUsageRepository) {
        self.repository = repository
    }
    
    func exec() -> Int {
        var usage = repository.fetchTempUsage()
        usage += 5
        
        repository.updateTempUsage(usage)
        
        return usage
    }
}
