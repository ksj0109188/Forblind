//
//  PaymentViewModel.swift
//  LuminaView
//
//  Created by 김성준 on 12/3/24.
//

import RxSwift
import StoreKit
import RxRelay

typealias Transaction = StoreKit.Transaction

final class PaymentViewModel {
    private let disposeBag = DisposeBag()
    private let productsRelay = BehaviorRelay<[Product]>(value: [])
    private let purchaseUseCase: InAppPurchaseUseCase
    private let checkLogin: CheckLoginUseCase
    private let createPaymentInfoUseCase: CreatePaymentInfoUseCase
    private let updateUsageInfoUseCase: UpdateUsageInfoUseCase
    
    var products: Observable<[Product]> {
        return productsRelay.asObservable()
    }
    
    init(purchaseUseCase: InAppPurchaseUseCase,
         checkLogin: CheckLoginUseCase,
         createPaymentInfoUseCase: CreatePaymentInfoUseCase,
         updateUsageInfoUseCase: UpdateUsageInfoUseCase) {
        self.purchaseUseCase = purchaseUseCase
        self.checkLogin = checkLogin
        self.createPaymentInfoUseCase = createPaymentInfoUseCase
        self.updateUsageInfoUseCase = updateUsageInfoUseCase
    }
    
    func fetchProducts() {
        Task {
            do {
                let fetchedProducts = try await Product.products(for: Products.allProductIDs)
                
                DispatchQueue.main.async {
                    self.productsRelay.accept(fetchedProducts.sorted { $0.price < $1.price})
                }
            } catch {
                print("Error loading products: \(error)")
            }
        }
    }
    
    func purchase(product: Product) async {
        guard let userUID = checkLogin.exec() else { return }
        guard let transcation = try? await purchaseUseCase.exec(product: product) else { return }
        guard let usage = Products.duration(for: transcation.productID) else { return }
        
        let paymentID = String(transcation.originalID)
        let paymentInfo = PaymentInfo(id: paymentID,
                                      productID: transcation.productID,
                                      usageSeconds: usage,
                                      userUID: userUID)
        
        
        createPaymentInfoUseCase.execute(paymentInfo: paymentInfo) { result in
            switch result {
            case .success(let paymentInfo):
                self.updateUsageInfoUseCase.execute(paymentInfo: paymentInfo) { _ in }
            case .failure(let failure):
                debugPrint(failure)
            }
        }
            
    }
}
