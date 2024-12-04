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
        tableView.delegate = self
        tableView.dataSource = self
        tableView.indicatorStyle = .white
        
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Task {
            viewModel.fetchProducts()
            setupViews()
            setupConstraints()
        }
    }
    
    private func bindViewModel() {
        viewModel.products
            .bind(to: tableView.rx.items(cellIdentifier: ProductCell.reuseIdentifier)) { [weak self] (index, product, cell) in
                guard let cell = cell as? ProductCell else { return }
                self?.configureCell(cell, with: product)
            }
            .disposed(by: disposeBag)
    }
    
    private func configureCell(_ cell: ProductCell, with product: Product) {
          cell.configure(
              title: product.displayName,
              description: product.description,
              price: product.displayPrice
          )
      }
    
    private func setupViews() {
        view.addSubview(tableView)
        
    }
    
    private func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        let padding = 20.0
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
    
}

extension PaymentViewController: UITableViewDelegate {
    
}

extension PaymentViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        <#code#>
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        <#code#>
    }
}
