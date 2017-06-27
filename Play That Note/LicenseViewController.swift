//
//  LicenseViewController.swift
//  Play That Note
//
//  Created by Paul Crompton on 6/26/17.
//  Copyright © 2017 Paul Crompton. All rights reserved.
//

import UIKit
import WebKit

class LicenseViewController: UIViewController, WKNavigationDelegate {
    
    var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView = WKWebView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height), configuration: WKWebViewConfiguration())
        webView.navigationDelegate = self
        webView.configuration.ignoresViewportScaleLimits = false
        webView.backgroundColor = UIColor.clear
        webView.allowsBackForwardNavigationGestures = true
        webView.isUserInteractionEnabled = true
        
        if let url = Bundle.main.url(forResource: "index", withExtension: "html", subdirectory: "License") {
            let request = URLRequest(url: url)
            webView.load(request)
        }
        self.view.addSubview(webView)
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        webView.reload()
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == .linkActivated  {
            if let url = navigationAction.request.url,
                UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
                print(url)
                print("Redirected to browser. No need to open it locally")
                decisionHandler(.cancel)
            } else {
                print("Open it locally")
                decisionHandler(.allow)
            }
        } else {
            print("not a user click")
            decisionHandler(.allow)
        }
    }
}
