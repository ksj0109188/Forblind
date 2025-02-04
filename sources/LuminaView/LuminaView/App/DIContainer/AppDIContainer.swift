//
//  AppDIContainer.swift
//  LuminaView
//
//  Created by 김성준 on 7/16/24.
//

import Foundation

final class AppDIContainer {
    lazy var appConfigurations = AppConfigurations()
    lazy var guideService: GuideAPIWebRepository = {
        let config = WebSocketAPIConfig(url: appConfigurations.webSocketURL)
        
        return WebSocketRepository(config: config)
    }()
    
    lazy var freeTrialService: FreeTrialRepository = {
        return DefaultFreeTrialRepository()
    }()
    
    lazy var userInfoService: UserInfoRepository = {
        return FirebaseUserInfoRepository()
    }()
    
    lazy var remoteUsageRepository: RemoteUsageRepository = {
        return FirebaseUserInfoRepository()
    }()
    
    lazy var localUsageRepository: LocalUsageRepository = {
        return DefaultLocalUsageRepository()
    }()
    
    lazy var inAppPurchaseService: PaymentService = {
        return AppleInAppPurchaseService()
    }()
    
    lazy var paymentRepository: PaymentRepository = {
       return FirebasePaymentRepository()
    }()
    
    lazy var loginService: LoginRepository = {
        return FirebaseLoginRepository()
    }()
    
    lazy var authManager: AuthManager = {
        return AuthManager()
    }()
    
    func makeDriveModeSceneDIContainer() -> DriveModeSceneDIContainer {
        let dependencies = DriveModeSceneDIContainer.Dependencies(guideAPIWebRepository: guideService,
                                                                  freeTrialRepository: freeTrialService,
                                                                  userInfoRepository: userInfoService,
                                                                  loginRepository: loginService,
                                                                  localUsageRepository: localUsageRepository,
                                                                  remoteUsageRepository: remoteUsageRepository,
                                                                  cameraManager: CameraManger(), speakManager: SpeakManager())
        
        return DriveModeSceneDIContainer(dependencies:  dependencies)
    }
    
    func makeLoginSceneDIContainer() -> LoginSceneDIContainer {
        let dependencies = LoginSceneDIContainer.Dependencies(authManager: authManager)
        
        return LoginSceneDIContainer(dependencies: dependencies)
    }
    
    func makePaymentDIContainer() -> PaymentSceneDIContainer {
        let dependencies = PaymentSceneDIContainer.Dependencies(inAppPurchaseService: inAppPurchaseService,
                                                                loginRepository: loginService,
                                                                paymentRepository: paymentRepository,
                                                                userInfoRepository: userInfoService,
                                                                remoteUsageRepository: remoteUsageRepository)
        
        return PaymentSceneDIContainer(dependencies: dependencies)
    }
}
