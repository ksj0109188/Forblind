//
//  PaymentViewController.swift
//  LuminaView
//
//  Created by 김성준 on 12/3/24.
//

import UIKit
import RxSwift
import StoreKit

class PaymentViewController: UIViewController {
    private let viewModel: PaymentViewModel = PaymentViewModel()
    private let disposeBag = DisposeBag()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(ProductCell.self, forCellReuseIdentifier: ProductCell.reuseIdentifier)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .black
        tableView.indicatorStyle = .white
        
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Task {
            viewModel.fetchProducts()
            setupViews()
            setupConstraints()
            bindViewModel()
        }
    }
    
    private func bindViewModel() {
        viewModel.products
            .bind(to: tableView.rx.items(cellIdentifier: ProductCell.reuseIdentifier)) { [weak self] (index, product, cell) in
                guard let cell = cell as? ProductCell else { return }
                
                cell.configure(
                    title: product.displayName,
                    description: product.description,
                    price: product.displayPrice
                ) { [weak self] in
                    // 구매 버튼 클릭 이벤트 처리
                    self?.handlePurchase(for: product)
                }
            }
            .disposed(by: disposeBag)
    }
    
    private func setupViews() {
        view.addSubview(tableView)
    }
    
    private func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            tableView.heightAnchor.constraint(equalTo: view.heightAnchor),
            tableView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            tableView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
        ])
    }
    
    private func handlePurchase(for product: Product) {
        debugPrint("구매 요청: \(product.displayName)")
        // ViewModel에 구매 이벤트 전달
        Task {
            let _ = try await viewModel.purchase(product: product)
        }
    }
}
