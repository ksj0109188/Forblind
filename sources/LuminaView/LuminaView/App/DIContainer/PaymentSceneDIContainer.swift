//
//  PaymentSceneDIContainer.swift
//  LuminaView
//
//  Created by 김성준 on 12/26/24.
//

import Foundation
import UIKit

final class PaymentSceneDIContainer: PaymentSceneFlowCoordinatorDependencies {
    struct Dependencies {
        let inAppPurchaseService: PaymentService
        let loginRepository: LoginRepository
        let paymentRepository: PaymentRepository
        let userInfoRepository: UserInfoRepository
        let remoteUsageRepository: RemoteUsageRepository
    }
    
    private let dependencies: Dependencies
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    // MARK: UseCase
    func makePurchaseUseCase() -> InAppPurchaseUseCase {
        InAppPurchaseUseCase(service: dependencies.inAppPurchaseService)
    }
    
    func makeCheckLoginUseCase() -> CheckLoginUseCase {
        CheckLoginUseCase(repository: dependencies.loginRepository)
    }
    
    func makeCreatePaymentInfoUseCase() -> CreatePaymentInfoUseCase {
        CreatePaymentInfoUseCase(repository: dependencies.paymentRepository)
    }
    
    func makeUpdateUsageInfoUseCase() -> RegisterUsageInfoUseCase {
        RegisterUsageInfoUseCase(repository: dependencies.remoteUsageRepository)
    }
    
    // MARK: ViewModel
    func makePaymentViewModel() -> PaymentViewModel {
        PaymentViewModel(purchaseUseCase: makePurchaseUseCase(),
                         checkLogin: makeCheckLoginUseCase(),
                         createPaymentInfoUseCase: makeCreatePaymentInfoUseCase(),
                         updateUsageInfoUseCase: makeUpdateUsageInfoUseCase())
    }
    
    // MARK: Presentation
    func makePaymentViewController() -> PaymentViewController {
        let vc = PaymentViewController()
        vc.create(viewModel: makePaymentViewModel())
        
        return vc
    }
    
    //TODO: navigationController 상위 개념에서 핸들링 하는 것으로 변경필요
    func makePaymentSceneFlowCoordinator(navigationController: UINavigationController, parentCoordinator: PaymentSceneFlowCoordinatorDelegate) -> PaymentSceneFlowCoordinator {
        
        return PaymentSceneFlowCoordinator(navigationController: navigationController,
                                           dependencies: self,
                                           delegate: parentCoordinator)
    }
}
