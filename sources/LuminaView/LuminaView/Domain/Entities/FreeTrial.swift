//
//  FreeTrial.swift
//  LuminaView
//
//  Created by 김성준 on 10/17/24.
//

import Foundation

final class FreeTrial {
    private let id = "FreeTrialID"
    private let remainCount: Int
    
    init(remainCount: Int) {
        self.remainCount = remainCount
    }
    
    func fetchId() -> String {
        return id
    }
    
}
