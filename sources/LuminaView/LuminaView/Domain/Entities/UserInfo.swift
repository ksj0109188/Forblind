//
//  UserInfo.swift
//  LuminaView
//
//  Created by 김성준 on 11/20/24.
//

import Foundation
import FirebaseFirestore

struct UserInfo: Identifiable, Codable {
    @DocumentID var id: String?
    var payments: [String]?
    var remainUsageSeconds: Int
    
    var remainUsageString: String {
        let hours = remainUsageSeconds / 3600
        let minutes = (remainUsageSeconds % 3600) / 60
        let seconds = remainUsageSeconds % 60
        
        return String(format: "%02d시간 %02d분 %02d초", hours, minutes, seconds)
    }
}
