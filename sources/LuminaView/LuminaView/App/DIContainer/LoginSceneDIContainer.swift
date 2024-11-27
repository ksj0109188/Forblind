//
//  LoginSceneDIContainer.swift
//  LuminaView
//
//  Created by 김성준 on 11/27/24.
//

import UIKit

///note:
///LoginViewController는 현재 Apple Login만 구현토록 설정
///따라서 Apple Login API형태가 delegate pattern으로 제공되므로 ViewController와 강한결합 의도(분리시 복잡도 증가 우려)
///추가 SNS로그인시 리팩토링 필요
final class LoginSceneDIContainer: LoginSceneFlowCoordinatorDependencies {
    struct Dependencies {
        let authManager: AuthManager
    }
    
    private let dependencies: Dependencies
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    // MARK: Utility
    func makeAuthManager() -> AuthManager {
        return dependencies.authManager
    }
    
    // MARK: UseCase
    
    
    // MARK: ViewModel
    func makeLoginViewModel() -> LoginViewModel {
        LoginViewModel(authManger: makeAuthManager())
    }
    
    // MARK: Presentation
    func makeLoginViewController() -> LoginViewController {
        let vc = LoginViewController()
        vc.create(viewModel: makeLoginViewModel())
        
        return vc
    }
    
    func makeLoginSceneFlowCoordinator(navigationController: UINavigationController, parentCoordinator: LoginSceneFlowCoordinatorDelegate) -> LoginSceneFlowCoordinator {
        
        return LoginSceneFlowCoordinator(navigationController: navigationController,
                                         dependencies: self,
                                         delegate: parentCoordinator)
    }
}
