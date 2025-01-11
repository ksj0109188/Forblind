//
//  DefaultUsageRepository.swift
//  LuminaView
//
//  Created by 김성준 on 1/10/25.
//

import Foundation

final class DefaultLocalUsageRepository: LocalUsageRepository {
    private let defaults = UserDefaults.standard
    private let key = "usage"

    func fetchTempUsage() -> Int {
        return defaults.integer(forKey: key)
    }
    
    func updateTempUsage(_ usage: Int) {
        defaults.set(usage, forKey: key)
    }
    
    func resetTempUsage() {
        defaults.set(0, forKey: key)
    }
}
