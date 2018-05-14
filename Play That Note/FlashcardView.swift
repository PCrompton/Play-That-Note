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
    var zoomFactor = 4
    var secondPitch: String?
    
    init(clef: Clef?, pitch: String?, containerView: UIView, secondPitch: String?) {
        self.containerView = containerView
        self.secondPitch = secondPitch
        super.init(frame: CGRect(x: 0, y: 0, width: containerView.frame.width, height: containerView.frame.height), configuration: WKWebViewConfiguration())
        containerView.backgroundColor = UIColor.clear
        self.isOpaque = false
        backgroundColor = UIColor.clear
        scrollView.backgroundColor = UIColor.clear
        
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
        self.isUserInteractionEnabled = false
        
        if let url = Bundle.main.url(forResource: "index", withExtension: "html", subdirectory: "vexFlow") {
            let request = URLRequest(url: url)
            self.load(request)
        }
        containerView.addSubview(self)
        self.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setBackground(for view: UIView, to color: UIColor) {
        view.backgroundColor = color
        for subview in view.subviews {
            subview.backgroundColor = color
            if subview.subviews.count > 0 {
                setBackground(for: subview, to: color)
            }
        }
    }
    
    func drawStaffWithPitch(pitch: String, clef: String) {
        if let secondPitch = secondPitch {
            self.evaluateJavaScript("\(jsDrawStaffWithPitch)(\"\(pitch)\", \"\(clef)\", \"\(zoomFactor)\", \"\(secondPitch)\")", completionHandler: nil)
        } else {
            self.evaluateJavaScript("\(jsDrawStaffWithPitch)(\"\(pitch)\", \"\(clef)\", \"\(zoomFactor)\")", completionHandler: nil)
        }
    }

    
    // MARK: WKNavigationDelegate functions
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("\(clef)")
        drawStaffWithPitch(pitch: pitch, clef: clef)
        //containerView.sendSubview(toBack: self)
    }
}
