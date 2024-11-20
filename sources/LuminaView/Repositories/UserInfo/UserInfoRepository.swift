//
//  UserInfoRepository.swift
//  LuminaView
//
//  Created by 김성준 on 11/20/24.
//

import Foundation

protocol UserInfoRepository {
    func fetchUserInfo(uid: String, completion: @escaping (Result<UserInfo, Error>) -> Void)
    func registerUserInfo(uid: String, completion: @escaping (Result<Bool, Error>) -> Void)
}
