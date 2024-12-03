//
//  PaymentViewController.swift
//  LuminaView
//
//  Created by 김성준 on 12/3/24.
//

import UIKit
import RxSwift

final class PaymentViewController: UIViewController {
    private let viewModel: PaymentViewModel = PaymentViewModel()
    
    override func viewDidLoad() {
        
        Task {
            await viewModel.fetchProducts()
        }
    }
}
