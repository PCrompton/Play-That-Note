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
import AVFoundation
import CoreData

class GameViewController: FlashcardViewController, PitchEngineDelegate {

    // MARK: Parameters
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var buttonStackView: UIStackView!
    
    @IBOutlet weak var flashCardActivityIndicator: UIActivityIndicatorView!
    var pitchEngine: PitchEngine?
    var consecutivePitches = [Pitch]()
    var flashcards = [Flashcard]()
    
    var correct: Int = 0
    var incorrect: Int = 0
    var totalAnswered: Int {
        return Int(self.correct + self.incorrect)
    }
    var percentage: Double {
        if totalAnswered != 0 {
            return Double(correct)/Double(totalAnswered)*100
        }
        return 0.0
    }
    var plusMinus: Int {
        return Int(self.correct) - Int(self.incorrect)
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
        for button in [startButton, cancelButton] {
            addShadows(to: button!)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        let touch: UITouch? = touches.first
        //location is relative to the current view
        // do something with the touched point
        guard let pitchEngine = pitchEngine else {
            fatalError("No Pitch Engine Found")
        }
        if view.traitCollection.verticalSizeClass == .compact {
            if pitchEngine.active {
                if touch?.view != buttonStackView {
                    buttonStackView.isHidden = buttonStackView.isHidden ? false : true
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setButtonStackViewAxis()
    }
    
    func setButtonStackViewAxis() {
        if view.traitCollection.verticalSizeClass == .compact {
            buttonStackView.axis = .horizontal
        } else {
            buttonStackView.axis = .vertical
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        setButtonStackViewAxis()
        guard let pitchEngine = pitchEngine else {
            fatalError("No Pitch Engine Found")
        }
        if pitchEngine.active {
            if view.traitCollection.verticalSizeClass == .compact {
                buttonStackView.isHidden = true
            } else {
                buttonStackView.isHidden = false
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        pitchEngine?.stop()
        gameCenterModelController.sendScores()
    }
    
    func addShadows(to button: UIButton) {
        button.layer.shadowOpacity = 0.7
        button.layer.shadowOffset = CGSize(width: 3.0, height: 2.0)
        button.layer.shadowRadius = 5.0
        button.layer.shadowColor = UIColor.darkGray.cgColor
    }
    
    override func updateStatsLabels() {
        correctLabel.text = "\(correct)"
        incorrectLabel.text = "\(incorrect)"
        percentageLabel.text = "\(Int(percentage)) %"
        plusMinusLabel.text = "\(plusMinus) +/-"
        plusMinusLabel.textColor = getLabelColor(for: plusMinus)
    }

    // MARK: Gameplay Functions
    @IBAction func cancelButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func startButton(_ sender: UIButton) {
        guard let pitchEngine = pitchEngine else {
            fatalError("No Pitch Engine Found")
        }
        if !pitchEngine.active {
            flashCardActivityIndicator.startAnimating()
            sender.isEnabled = false
            let concurrentQueue = DispatchQueue(label: "queuename", attributes: .concurrent)
            concurrentQueue.async {
                pitchEngine.start()
                
                // These two lines of code are here to guard against a known bug in the Beethoven framework where the pitchEngine may not start on the first try
                pitchEngine.stop()
                pitchEngine.start()
                self.flashcard = self.getRandomflashcard()
                print("Pitch Engine Started")
                DispatchQueue.main.async {
                    sender.setTitle("Stop", for: .normal)
                    sender.isEnabled = true
                    self.flashCardActivityIndicator.stopAnimating()
                    if self.view.traitCollection.verticalSizeClass == .compact {
                        self.buttonStackView.isHidden = true
                    }
                }
            }

        } else {
            pitchEngine.stop()
            sender.setTitle("Start", for: .normal)
            print("Pitch Engine Stopped")
        }
    }
    
    func getRandomBool() -> Bool {
        return Int(arc4random_uniform(2)) == 0
    }
    
    func getRandomflashcard() -> Flashcard {
        let index = Int(arc4random_uniform(UInt32(flashcards.count)))
        let flashcard = flashcards[index]
        if flashcard === self.flashcard {
            return getRandomflashcard()
        }
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
    
    func configureAlertTitle(for alertController: UIAlertController, with title: String, with font: UIFont, with color: UIColor) {
        let myString  = title
        var myMutableString = NSMutableAttributedString()
        myMutableString = NSMutableAttributedString(string: myString as String, attributes: [NSFontAttributeName:font])
        myMutableString.addAttribute(NSForegroundColorAttributeName, value: color, range: NSRange(location:0,length:myString.characters.count))
        alertController.setValue(myMutableString, forKey: "attributedTitle")
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
                print(pitch.note.string, pitch.note.index)
                guard let noteToDisplay = flashcard?.note else {
                    fatalError("No note found")
                }
                let font = UIFont.systemFont(ofSize: 42.0)
                var color: UIColor
                var title: String
                
                if note.index == Int((flashcard?.pitchIndex)!) {
                    //alertController.title = "Correct!"
                    title = "Correct!"
                    color = UIColor.green
                    flashcard?.correct += 1
                    correct += 1
                } else {
                    title = "Incorrect!"
                    color = UIColor.red
                    flashcard?.incorrect += 1
                    incorrect += 1
                }
                configureAlertTitle(for: alertController, with: title, with: font, with: color)
                stack.save()
                updateStatsLabels()
                present(alertController, animated: true)
                let delay = 1.5
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    alertController.dismiss(animated: true, completion: {
                        DispatchQueue.main.async {
                            self.flashCardActivityIndicator.startAnimating()
                            let concurrentQueue = DispatchQueue(label: "queuename", attributes: .concurrent)
                            concurrentQueue.async {
                                self.pitchEngine?.start()
                                self.flashcard = self.getRandomflashcard()
                                DispatchQueue.main.async {
                                    self.flashCardActivityIndicator.stopAnimating()
                                }
                            }
                        }
                    })
                }
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

