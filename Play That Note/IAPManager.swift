//
//  IAPManager.swift
//  Play That Note
//
//  Created by Paul Crompton on 7/11/17.
//  Copyright © 2017 Paul Crompton. All rights reserved.
//

import UIKit
import StoreKit

class IAPManager: NSObject, SKProductsRequestDelegate {
    static let sharedInstance = IAPManager()
    
    var request: SKProductsRequest!
    var products: [SKProduct] = []
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        products = response.products
        print(products.count, "products")
        for product in products {
            print(product.localizedTitle)
        }
    }
    
    func getProductIdentifiers() -> [String] {
        var identifiers: [String] = []
        
        if let fileURL = Bundle.main.url(forResource: "products", withExtension: "plist") {
            
            let products = NSArray(contentsOf: fileURL)
            
            for product in products as! [String] {
                identifiers.append(product)
            }
        }
        
        return identifiers
    }
    
    func performProductRequestForIdentifiers(identifiers: [String]) {
        
        let products = NSSet(array: identifiers) as! Set<String>
        request = SKProductsRequest(productIdentifiers: products)
        request.delegate = self
        request.start()
    }
    
    func requestProducts() {
        performProductRequestForIdentifiers(identifiers: getProductIdentifiers())
    }
    
    
    
    
    
    
    
    
    
    
    
}
