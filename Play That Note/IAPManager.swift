//
//  IAPManager.swift
//  NoteTaker
//
//  Created by Ron Buencamino on 10/5/16.
//  Copyright © 2016 Animatronic Gopher Inc. All rights reserved.
//

import UIKit
import StoreKit
import TPInAppReceipt

class IAPManager: NSObject, SKPaymentTransactionObserver, SKProductsRequestDelegate {
    static let shared = IAPManager()
    
    var request:SKProductsRequest!
    var products:[SKProduct] = []
    var canMakePayments: Bool {
        return SKPaymentQueue.canMakePayments()
    }
    
    var receiptRefreshRequest: SKReceiptRefreshRequest?
    
    var settingsVC: SettingsTableViewController?
    
    func setupPurchases(_ handler: @escaping (Bool) -> Void){
        if SKPaymentQueue.canMakePayments() {
            SKPaymentQueue.default().add(self)
            handler(true)
            return
        }
        
        handler(false)
    }
    
    // MARK - SKProductsRequest
    func getProductIdentifiers() -> [String] {
        var identifiers:[String] = []
        
        if let fileUrl = Bundle.main.url(forResource: "products", withExtension: "plist"){
            let products = NSArray(contentsOf: fileUrl)
            
            for product in products as! [String]{
                identifiers.append(product)
            }
        }
        return identifiers
    }
    func performProductRequestForIdentifiers(identifiers:[String]){
        let products = NSSet(array: identifiers) as! Set<String>
        
        self.request = SKProductsRequest(productIdentifiers: products)
        self.request.delegate = self
        self.request.start()
        
    }
    
    func requestProducts() {
        self.performProductRequestForIdentifiers(identifiers: self.getProductIdentifiers())
    }
    
    func getProduct(by productID: String) -> SKProduct? {
        print("getProduct called")
        requestProducts()
        for product in products {
            if product.productIdentifier == productID {
                return product
            }
        }
        return nil
    }
    
    // MARK - Payment Request
    func createPaymentRequestForProduct(product:SKProduct){
        let payment = SKMutablePayment(product: product)
        payment.quantity = 1
        
        SKPaymentQueue.default().add(payment)
    }
    
    // MARK - Receipt Validation
    
    func validateReceipt(completion: @escaping (Bool) -> Void){
        do {
            let receipt = try InAppReceipt.localReceipt()
            do {
                try receipt.verify()
                print("Verification Successful")
                completion(true)
            } catch {
                print("Error validating receipt:", error)
                completion(false)
            }
        } catch {
            print("Error finding receipt:", error)
            completion(false)
        }
    }
    
    // MARK - Unlock Functionality
    func unlockFunctionalityForProduct(productID:String){
        print("Unlocking \(productID)")
        UserDefaults.standard.set(true, forKey: productID)
        UserDefaults.standard.synchronize()
        
    }
    
    // MARK - Lock Functionality
    func lockFunctionalityForProduct(productID:String){
        UserDefaults.standard.set(false, forKey: productID)
        UserDefaults.standard.synchronize()
        
    }
    
    // MARK - Restore Purchases
    func restorePurchasedItems(){
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    // MARK - SKProductsRequestDelegate
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        self.products = response.products
    }
    
    func handleFailedTransaction(transaction: SKPaymentTransaction) {
        if let error = transaction.error {
            print(error.localizedDescription)
            let alert = UIAlertController(title: "Transaction Failed", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
            let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
            let tryAgain = UIAlertAction(title: "Try Again", style: UIAlertActionStyle.default, handler: { (action) in
                if let product = IAPManager.shared.getProduct(by: MusicSettings.productID) {
                    IAPManager.shared.createPaymentRequestForProduct(product: product)
                }
            })
            alert.addAction(tryAgain)
            alert.addAction(cancel)
            settingsVC?.tabBarController?.present(alert, animated: true, completion: nil)
        } else {
            print("Error not found for transaction")
        }
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    func handleSuccessfulTransaction(transaction: SKPaymentTransaction) {
        self.validateReceipt(completion: { (success) in
            if success {
                let productID = transaction.payment.productIdentifier
                
                self.unlockFunctionalityForProduct(productID: transaction.payment.productIdentifier)
                SKPaymentQueue.default().finishTransaction(transaction)
                if productID == MusicSettings.productID {
                    self.settingsVC?.menuConfig()
//                    self.settingsVC?.showMusicSettings(sender: self.settingsVC?.tableView.cellForRow(at: IndexPath(item: Settings.music.rawValue, section: 0)))
                }
            } else {
                print("There was a problem validating the receipt")
                self.handleFailedTransaction(transaction: transaction)
            }
        })
    }
    
    // MARK - SKPaymentTransactionObserver
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions as [SKPaymentTransaction] {
            switch transaction.transactionState {
            // handle appropriate transaction state
            case .purchasing:
                print("purchasing")
            case .deferred:
                print("deferred")
            case .failed:
                print("failed")
                handleFailedTransaction(transaction: transaction)
            case .purchased:
                print("purchased")
                handleSuccessfulTransaction(transaction: transaction)
            case .restored:
                print("restored")
                handleSuccessfulTransaction(transaction: transaction)
            }
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        //
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, removedTransactions transactions: [SKPaymentTransaction]) {
        //
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedDownloads downloads: [SKDownload]) {
        //
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        //
        print("paymentQueueRestoreCompletedTransactionsFinished")
    }    
}
