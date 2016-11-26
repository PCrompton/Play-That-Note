//
//  GameViewController.swift
//  Play That Note
//
//  Created by Paul Crompton on 11/7/16.
//  Copyright © 2016 Paul Crompton. All rights reserved.
//

import UIKit
import Pitchy
import Beethoven
import WebKit
import AVFoundation
import CoreData
import GameKit

class GameViewController: UIViewController, PitchEngineDelegate, WKNavigationDelegate {

    // MARK: Parameters
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var clefPercentageLabel: UILabel!
    @IBOutlet weak var clefPlusMinusLabel: UILabel!
    @IBOutlet weak var correctLabel: UILabel!
    @IBOutlet weak var incorrectLabel: UILabel!
    @IBOutlet weak var percentageLabel: UILabel!
    @IBOutlet weak var plusMinusLabel: UILabel!
    
    let stack = (UIApplication.shared.delegate as! AppDelegate).stack
    let statsModelController = StatsModelController()
    var pitchEngine: PitchEngine?
    var consecutivePitches = [Pitch]()
    
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

    var flashcards = [Flashcard]() {
        didSet {
            statsModelController.flashcards = flashcards
        }
    }
    var flashcardToShow: Flashcard? {
        didSet {
            webView?.reload()
            guard let flashcard = flashcardToShow else {
                print("No flashcard found")
                return
            }
            correctLabel.text = "Correct: \(flashcard.correct)"
            incorrectLabel.text = "Incorrect: \(flashcard.incorrect)"
            percentageLabel.text = "\(Int(flashcard.percentage))%"
            plusMinusLabel.text = "+/-: \(flashcard.plusMinus)"
            plusMinusLabel.textColor = getLabelColor(for: flashcard.plusMinus)
        }
    }

    // MARK: Lifecyle Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        let config = Config(bufferSize: Settings.bufferSize, estimationStrategy: Settings.estimationStrategy)
        pitchEngine = PitchEngine(config: config, delegate: self)
        pitchEngine?.levelThreshold = Settings.levelThreshold
        flashcards = statsModelController.fetchSavedFlashcards(for: clef, lowest: Int32(lowest.index), highest: Int32(highest.index))
        if flashcards.count == 0 {
            flashcards = statsModelController.createFlashcards(clef: clef, lowest: lowest, highest: highest)
            stack.save()
        }
        updateClefStatsLabels()
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        pitchEngine?.stop()
        statsModelController.sendScores()
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
    
    // MARK: Gameplay Functions
    @IBAction func StartButton(_ sender: UIButton) {
        guard let pitchEngine = pitchEngine else {
            fatalError("No Pitch Engine Found")
        }
        if !pitchEngine.active {
            pitchEngine.start()
            sender.setTitle("Stop", for: .normal)
            print("Pitch Engine Started")
            flashcardToShow = getRandomflashcard()
        } else {
            pitchEngine.stop()
            sender.setTitle("Start", for: .normal)
            print("Pitch Engine Stopped")
        }
    }
    
    func getRandomBool() -> Bool {
        let num = Int(arc4random_uniform(2))
        if num == 0 {
            return true
        } else {
            return false
        }
    }
    
    func getRandomflashcard() -> Flashcard {
        let index = Int(arc4random_uniform(UInt32(flashcards.count)))
        let flashcard = flashcards[index]
        if flashcard.percentage > 50.0 {
            var bool = getRandomBool()
            if bool {
                return getRandomflashcard()
            } else {
                if flashcard.percentage > 75.0 {
                    bool = getRandomBool()
                    if bool {
                        return getRandomflashcard()
                    }
                }
            }
        }
        return flashcard
    }
    
    func checkIfIsPitch(pitches: [Pitch]) -> Bool {
        for i in 1..<pitches.count {
            if pitches[i].note.index != pitches[i-1].note.index {
                return false
            }
        }
        return true
    }
    
    // MARK: WKNavigationDelegate Functions
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if let pitch = flashcardToShow?.note {
            webView.evaluateJavaScript("\(jsDrawStaffWithPitch)(\"\(pitch)\", \"\(clef)\", \(dimensions))")
        } else {
            webView.evaluateJavaScript("\(jsDrawStaffWithPitch)(null, \"\(clef)\", \(dimensions))")
        }
    }
    
    // MARK: PitchEngineDelegate functions
    public func pitchEngineDidReceivePitch(_ pitchEngine: PitchEngine, pitch: Pitch) {
        let note = pitch.note
        print(note.string, pitchEngine.signalLevel)
        if consecutivePitches.count < Settings.consecutivePitches {
            consecutivePitches.append(pitch)
        } else {
            consecutivePitches.remove(at: 0)
            consecutivePitches.append(pitch)
            if checkIfIsPitch(pitches: consecutivePitches) {
                pitchEngine.stop()
                consecutivePitches.removeAll()
                let alertController = UIAlertController(title: note.string, message: nil, preferredStyle: .alert)
                let action = UIAlertAction(title: "Next", style: .default) {
                    (action) in
                    self.pitchEngine?.start()
                    self.flashcardToShow = self.getRandomflashcard()
                }
                alertController.addAction(action)
                print(pitch.note.string, pitch.note.index)
                if note.index == Int((flashcardToShow?.pitchIndex)!) {
                    alertController.message = "Congrates, you played \(note.string)"
                    flashcardToShow?.correct += 1
                } else {
                    guard let note = flashcardToShow?.note else {
                        fatalError("No note found")
                    }
                    alertController.message = "Sorry, that was not \(note)"
                    flashcardToShow?.incorrect += 1
                }
                stack.save()
                updateClefStatsLabels()
                present(alertController, animated: true)
            }
        }
    }
    
    public func pitchEngineDidReceiveError(_ pitchEngine: PitchEngine, error: Error) {
        print(Error.self)
        consecutivePitches.removeAll()
    }
    
    public func pitchEngineWentBelowLevelThreshold(_ pitchEngine: PitchEngine) {
        print("Below Threshhold", pitchEngine.signalLevel)
        consecutivePitches.removeAll()
        return
    }
}

