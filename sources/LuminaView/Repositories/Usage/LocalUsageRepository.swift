//
//  UsageRepository.swift
//  LuminaView
//
//  Created by 김성준 on 1/10/25.
//

import Foundation

protocol LocalUsageRepository {
    func fetchTempUsage() -> Int
    func updateTempUsage(_ usage: Int)
    func resetTempUsage()
}
