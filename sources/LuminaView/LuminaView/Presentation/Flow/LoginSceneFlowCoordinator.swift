//
//  LoginSceneFlowCoordinator.swift
//  LuminaView
//
//  Created by 김성준 on 11/27/24.
//

import UIKit

protocol LoginSceneFlowCoordinatorDependencies {
    func makeLoginViewController(actions: LoginViewModelActions) -> LoginViewController
}

protocol LoginSceneFlowCoordinatorDelegate: AnyObject {
    func presentPaymentScene()
    func presentDriveModeScene()
}

final class LoginSceneFlowCoordinator: Coordinator {
    var children: [any Coordinator]?
    //TODO:  이렇게 하위 coordinator에서 navigationcontroller를 조작하는 건 글로벌적으로 오류 발생 야기할 수 있을듯. 따라서 delegate 패턴 활용해서 appflowcoordinator 사용하는 거 한 번 생각해보자.

    private weak var navigationController: UINavigationController?
    
    private weak var delegate: LoginSceneFlowCoordinatorDelegate?
    private let dependencies: LoginSceneFlowCoordinatorDependencies
    private var onDismissForViewController: [UIViewController: (()->Void)] = [:]
    
    init(children: [any Coordinator]? = nil,
         navigationController: UINavigationController?,
         dependencies: LoginSceneFlowCoordinatorDependencies,
         delegate: LoginSceneFlowCoordinatorDelegate?) {
        self.children = children
        self.navigationController = navigationController
        self.dependencies = dependencies
        self.delegate = delegate
    }
    
    func start(animated: Bool, onDismissed: (() -> Void)?) {
        let actions = LoginViewModelActions(showDriveModeScene: showDriveModeScene)
        let vc = dependencies.makeLoginViewController(actions: actions)
        
        onDismissForViewController[vc] = onDismissed
        navigationController?.pushViewController(vc, animated: false)
    }
    
    func showPaymentScene() {
        delegate?.presentPaymentScene()
    }
    
    func showDriveModeScene() {
        delegate?.presentDriveModeScene()
    }
}
