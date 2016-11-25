//
//  StoreKitHelper.swift
//  Live3s
//
//  Created by ALWAYSWANNAFLY on 5/10/16.
//  Copyright © 2016 com.phucnguyen. All rights reserved.
//

import StoreKit


public typealias ProductIdentifier = String
public typealias ProductsRequestCompletionHandler = (_ success: Bool, _ products: [SKProduct]?) -> ()

open class StoreKitHelper : NSObject  {
    
    static let productIdentifiers: Set = [
        "emobi.wind.live3s.p1"
    ]
    
    static let IAPHelperPurchaseNotification = "IAPHelperPurchaseNotification"
    
    static let shareHelper = StoreKitHelper(productIds: StoreKitHelper.productIdentifiers)
    
    public init(productIds: Set<ProductIdentifier>) {
        super.init()
        SKPaymentQueue.default().add(self)
        for productIdentifier in productIds {
            let purchased = UserDefaults.standard.bool(forKey: productIdentifier)
            if purchased {
                purchasedProductIdentifiers.insert(productIdentifier)
                print("Previously purchased: \(productIdentifier)")
            } else {
                print("Not purchased: \(productIdentifier)")
            }
        }
    }
    fileprivate var purchasedProductIdentifiers = Set<String>()
    
    fileprivate var productsRequest: SKProductsRequest?
    fileprivate var productsRequestCompletionHandler: ProductsRequestCompletionHandler?
    
    func requestProducts(_ completionHandler: @escaping ProductsRequestCompletionHandler) {
        productsRequest?.cancel()
        productsRequestCompletionHandler = completionHandler
        
        productsRequest = SKProductsRequest(productIdentifiers: StoreKitHelper.productIdentifiers)
        productsRequest!.delegate = self
        productsRequest!.start()
    }
    
    func buyProduct(_ product: SKProduct) {
        print("Buying \(product.productIdentifier)...")
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
    
    func isProductPurchased(_ productIdentifier: ProductIdentifier) -> Bool {
        return purchasedProductIdentifiers.contains(productIdentifier)
    }
    
    static func canMakePayments() -> Bool {
        return SKPaymentQueue.canMakePayments()
    }
    
    func restorePurchases() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
}

extension StoreKitHelper: SKProductsRequestDelegate {
    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        print("Loaded list of products...")
        let products = response.products
        productsRequestCompletionHandler?(true, products)
        clearRequestAndHandler()
        
        for p in products {
            print("Found product: \(p.productIdentifier) \(p.localizedTitle) \(p.price.floatValue)")
        }
    }
    
    public func request(_ request: SKRequest, didFailWithError error: Error) {
        print("Failed to load list of products.")
        print("Error: \(error.localizedDescription)")
        productsRequestCompletionHandler?(false, nil)
        clearRequestAndHandler()
    }
    
    fileprivate func clearRequestAndHandler() {
        productsRequest = nil
        productsRequestCompletionHandler = nil
    }
}

// MARK: - SKPaymentTransactionObserver

extension StoreKitHelper: SKPaymentTransactionObserver {
    
    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch (transaction.transactionState) {
            case .purchased:
                completeTransaction(transaction)
                break
            case .failed:
                failedTransaction(transaction)
                break
            case .restored:
                restoreTransaction(transaction)
                break
            case .deferred:
                break
            case .purchasing:
                break
            }
        }
    }
    
    fileprivate func completeTransaction(_ transaction: SKPaymentTransaction) {
        print("completeTransaction...")
        deliverPurchaseNotificatioForIdentifier(transaction.payment.productIdentifier)
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    fileprivate func restoreTransaction(_ transaction: SKPaymentTransaction) {
        guard let productIdentifier = transaction.original?.payment.productIdentifier else { return }
        
        print("restoreTransaction... \(productIdentifier)")
        deliverPurchaseNotificatioForIdentifier(productIdentifier)
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    fileprivate func failedTransaction(_ transaction: SKPaymentTransaction) {
        print("failedTransaction...")
        if transaction.error!.code != SKError.paymentCancelled.rawValue {
            print("Transaction Error: \(transaction.error?.localizedDescription)")
        }
        
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    fileprivate func deliverPurchaseNotificatioForIdentifier(_ identifier: String?) {
        guard let identifier = identifier else { return }
        
        purchasedProductIdentifiers.insert(identifier)
        UserDefaults.standard.set(true, forKey: identifier)
        UserDefaults.standard.synchronize()
        NotificationCenter.default.post(name: Notification.Name(rawValue: StoreKitHelper.IAPHelperPurchaseNotification), object: identifier)
    }
}
