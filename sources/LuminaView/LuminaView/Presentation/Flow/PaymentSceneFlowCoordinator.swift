//
//  PaymentSceneFlowCoordinator.swift
//  LuminaView
//
//  Created by 김성준 on 12/26/24.
//

import UIKit

protocol PaymentSceneFlowCoordinatorDependencies {
    func makePaymentViewController() -> PaymentViewController
}

protocol PaymentSceneFlowCoordinatorDelegate: AnyObject {
    
}

final class PaymentSceneFlowCoordinator: Coordinator {
    var children: [any Coordinator]?
    private weak var navigationController: UINavigationController?
    private let dependencies: PaymentSceneFlowCoordinatorDependencies
    private weak var delegate: PaymentSceneFlowCoordinatorDelegate?
    private var onDismissForViewController: [UIViewController: (()->Void)] = [:]
    
    init(navigationController: UINavigationController,
         dependencies: PaymentSceneFlowCoordinatorDependencies,
         delegate: PaymentSceneFlowCoordinatorDelegate? = nil) {
        self.navigationController = navigationController
        self.dependencies = dependencies
        self.delegate = delegate
    }
    
    func start(animated: Bool, onDismissed: (() -> Void)?) {
        let vc = dependencies.makePaymentViewController()
        onDismissForViewController[vc] = onDismissed
        navigationController?.pushViewController(vc, animated: false)
    }
    
}
