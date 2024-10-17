//
//  DefaultFreeTrialRepository.swift
//  LuminaView
//
//  Created by 김성준 on 10/16/24.
//

import Foundation

final class DefaultFreeTrialRepository: FreeTrialRepository {
    private let userDefaults = UserDefaults.standard
    
    func isFreeTrial(request: CheckFreeTrialUseCaseRequestValue) -> Bool {
        let key = request.entity.fetchId()
        guard let currentCount = userDefaults.object(forKey: key) as? Int else {
            userDefaults.set(1, forKey: key)
            return true
        }
        
        if currentCount <= request.limitCount {
            return true
        } else {
            return false
        }
    }
    
    func increaseRespondCount(request: CheckFreeTrialUseCaseRequestValue) {
        let key = request.entity.fetchId()
        guard let currentCount = userDefaults.object(forKey: key) as? Int else {
            userDefaults.set(1, forKey: key)
            return
        }
        
        userDefaults.set(currentCount + 1, forKey: key)
    }
}
