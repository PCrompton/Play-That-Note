//
//  FlashcardStatsViewController.swift
//  Play That Note
//
//  Created by Paul Crompton on 11/19/16.
//  Copyright © 2016 Paul Crompton. All rights reserved.
//

import UIKit
import WebKit
import CoreData

class FlashcardStatsViewController: UIViewController, WKNavigationDelegate  {
    
    //
    @IBOutlet weak var correctLabel: UILabel!
    @IBOutlet weak var incorrectLabel: UILabel!
    @IBOutlet weak var percentLabel: UILabel!
    @IBOutlet weak var plusMinusLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    
    var flashcard: Flashcard?
    
    let jsDrawStaffWithPitch = "drawStaffWithPitch"
    var webView: WKWebView?
    
    var dimensions: String {
        get {
            let dimParams = "\(Int(containerView.frame.width)), \(Int(containerView.frame.height))"
            print(dimParams)
            return dimParams
        }
    }
    
    // MARK: Lifecycle Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let flashcard = flashcard else {
            fatalError("No flashcard found")
        }
        correctLabel.text = "Correct: \(flashcard.correct)"
        incorrectLabel.text = "Incorrect: \(flashcard.incorrect)"
        percentLabel.text = "\(Int(flashcard.percentage))%"
        plusMinusLabel.text = "+/-: \(flashcard.plusMinus)"
        if flashcard.plusMinus < 0 {
            plusMinusLabel.textColor = UIColor.red
        } else if flashcard.plusMinus > 0 {
            plusMinusLabel.textColor = UIColor.green
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        webView = WKWebView(frame: CGRect(x: 0, y: 0, width: containerView.frame.width, height: containerView.frame.height))
        webView?.configuration.ignoresViewportScaleLimits = true
        if let webView = webView {
            webView.navigationDelegate = self
            webView.allowsBackForwardNavigationGestures = false
            webView.isUserInteractionEnabled = false
            containerView.addSubview(webView)
            
            if let url = Bundle.main.url(forResource: "index", withExtension: "html", subdirectory: "vexFlow") {
                let request = URLRequest(url: url)
                webView.load(request)
            }
        }
    }
    
    // MARK: WKNavigationDelegate Functions
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        guard let clef = flashcard?.clef else {
            fatalError("No clef found")
        }
        if let pitch = flashcard?.note {
            webView.evaluateJavaScript("\(jsDrawStaffWithPitch)(\"\(pitch)\", \"\(clef)\", \(dimensions))")
        } else {
            webView.evaluateJavaScript("\(jsDrawStaffWithPitch)(null, \"\(clef)\", \(dimensions))")
        }
    }
}
