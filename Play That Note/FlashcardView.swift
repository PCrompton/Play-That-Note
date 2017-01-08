//
//  FlashcardView.swift
//  Play That Note
//
//  Created by Paul Crompton on 1/7/17.
//  Copyright © 2017 Paul Crompton. All rights reserved.
//

import UIKit
import WebKit

class FlashcardView: WKWebView, WKNavigationDelegate {
    
    var pitch: String = "null"
    var clef: String = "null"
    
    let containerView: UIView
    let jsDrawStaffWithPitch = "drawStaffWithPitch"
    
    var dimensions: String {
        let dimParams = "\(Int(containerView.frame.width)), \(Int(containerView.frame.height))"
        return dimParams
    }
    
    init(clef: Clef?, pitch: String?, containerView: UIView) {
        self.containerView = containerView

        super.init(frame: CGRect(x: 0, y: 0, width: containerView.frame.width, height: containerView.frame.height), configuration: WKWebViewConfiguration())
        
        if let pitch = pitch {
            self.pitch = pitch
        }
        
        if let clef = clef {
            self.clef = clef.rawValue
        }
        
        self.navigationDelegate = self
        self.configuration.ignoresViewportScaleLimits = true
        self.backgroundColor = UIColor.clear
        self.allowsBackForwardNavigationGestures = false
        self.isUserInteractionEnabled = true
        
        if let url = Bundle.main.url(forResource: "index", withExtension: "html", subdirectory: "vexFlow") {
            let request = URLRequest(url: url)
            self.load(request)
        }
        containerView.addSubview(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: WKNavigationDelegate functions
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("\(clef)")
        webView.evaluateJavaScript("\(jsDrawStaffWithPitch)(\"\(pitch)\", \"\(clef)\", \(dimensions))", completionHandler: nil)
    }
}
