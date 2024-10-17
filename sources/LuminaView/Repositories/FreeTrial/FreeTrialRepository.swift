//
//  FreeTrialRepository.swift
//  LuminaView
//
//  Created by 김성준 on 10/16/24.
//

import Foundation

protocol FreeTrialRepository {
    func isFreeTrial(request: CheckFreeTrialUseCaseRequestValue) -> Bool
    func increaseRespondCount(request: CheckFreeTrialUseCaseRequestValue)
}
