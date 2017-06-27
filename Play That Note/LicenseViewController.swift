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
        webView.allowsBackForwardNavigationGestures = false
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
