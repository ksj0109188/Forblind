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
}
