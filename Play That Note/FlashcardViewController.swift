//
//  FlashcardSuperViewController.swift
//  Play That Note
//
//  Created by Paul Crompton on 11/26/16.
//  Copyright © 2016 Paul Crompton. All rights reserved.
//

import UIKit
import WebKit
import Pitchy

class FlashcardViewController: UIViewController, WKNavigationDelegate {
    
    // MARK: Parameters
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var clefPercentageLabel: UILabel!
    @IBOutlet weak var clefPlusMinusLabel: UILabel!
    @IBOutlet weak var correctLabel: UILabel!
    @IBOutlet weak var incorrectLabel: UILabel!
    @IBOutlet weak var percentageLabel: UILabel!
    @IBOutlet weak var plusMinusLabel: UILabel!
    
    let stack = (UIApplication.shared.delegate as! AppDelegate).stack
    let statsModelController = StatsModelController()
    let gameCenterModelController = GameCenterModelController()
    
    let jsDrawStaffWithPitch = "drawStaffWithPitch"
    
    var webView: WKWebView?
    var dimensions: String {
        get {
            let dimParams = "\(Int(containerView.frame.width)), \(Int(containerView.frame.height))"
            print(dimParams)
            return dimParams
        }
    }
    
    var lowest = try! Note(letter: .C, octave: 1)
    var highest = try! Note(letter: .C, octave: 7)
    var clef = Clef.treble {
        didSet {
            switch clef {
            case .treble:
                lowest = try! Note(letter: .F, octave: 3);
                highest = try! Note(letter: .E, octave: 6)
            case .bass:
                lowest = try! Note(letter: .A, octave: 1);
                highest = try! Note(letter: .G, octave: 4)
            case .alto:
                lowest = try! Note(letter: .G, octave: 2);
                highest = try! Note(letter: .F, octave: 5)
            case .tenor:
                lowest = try! Note(letter: .E, octave: 2);
                highest = try! Note(letter: .D, octave: 5)
            default:
                return
            }
        }
    }
    
    var flashcard: Flashcard? {
        didSet {
            webView?.reload()
        }
    }
    
    // MARK: Lifecycle functions
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        webView = WKWebView(frame: CGRect(x: 0, y: 0, width: containerView.frame.width, height: containerView.frame.height))
        webView?.configuration.ignoresViewportScaleLimits = true
        webView?.backgroundColor = UIColor.clear
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
    
    // MARK: WKNavigationDelegate functions
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        updateStatsLabels()
        if let pitch = flashcard?.note {
            webView.evaluateJavaScript("\(jsDrawStaffWithPitch)(\"\(pitch)\", \"\(clef)\", \(dimensions))")
        } else {
            webView.evaluateJavaScript("\(jsDrawStaffWithPitch)(null, \"\(clef)\", \(dimensions))")
        }
    }
    
    // MARK: Data Functions
    func getLabelColor(for value: Int) -> UIColor {
        if value < 0 {
            return UIColor.red
        } else if value > 0 {
            return UIColor.green
        } else {
            return UIColor.blue
        }
    }
    
    func updateStatsLabels() {
        updateFlashcardStatsLabels()
        updateClefStatsLabels()
    }
    
    func updateFlashcardStatsLabels() {
        guard let flashcard = flashcard else {
            print("No flashcard found")
            return
        }
        correctLabel.text = "Correct: \(flashcard.correct)"
        incorrectLabel.text = "Incorrect: \(flashcard.incorrect)"
        percentageLabel.text = "\(Int(flashcard.percentage))%"
        plusMinusLabel.text = "+/-: \(flashcard.plusMinus)"
        plusMinusLabel.textColor = getLabelColor(for: flashcard.plusMinus)
    }
    
    func updateClefStatsLabels() {
        let clefStats = statsModelController.getStats(for: clef, lowest: nil, highest: nil)
        clefPlusMinusLabel.text = "+/-: \(clefStats.plusMinus)"
        clefPlusMinusLabel.textColor = getLabelColor(for: clefStats.plusMinus)
        if let percentage = clefStats.percentage {
            clefPercentageLabel.text = "\(Int(percentage))%"
        } else {
            clefPercentageLabel.text = "No Data"
        }
    }
}
