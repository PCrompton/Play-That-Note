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
    
    @IBOutlet weak var directionLabel: UILabel!
    @IBOutlet weak var flashCardActivityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var transpositionLabel: UILabel!
    
    @IBOutlet weak var rangeLabel: UILabel!
    var pitchEngine: PitchEngine?
    var consecutivePitches = [Pitch]()
    var flashcards = [Flashcard]()
    
    var running = false
    
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
        let config = Config(bufferSize: PitchDetectionSettings.bufferSize, estimationStrategy: PitchDetectionSettings.estimationStrategy)
        pitchEngine = PitchEngine(config: config, delegate: self)
        pitchEngine?.levelThreshold = PitchDetectionSettings.levelThreshold
        
        let defaultRange = MusicSettings.Range.defaultRange(for: clef)!
        
        flashcards = statsModelController.fetchSavedFlashcards(for: clef, lowest: Int32(defaultRange.lowestIndex), highest: Int32(defaultRange.highestIndex))
        
        if flashcards.count == 0 {
            flashcards = statsModelController.createFlashcards(clef: clef, lowest: defaultRange.lowest, highest: defaultRange.highest)
            stack.save()
        }
        
        flashcards = statsModelController.filter(for: flashcards, range: MusicSettings.Range.range(for: clef)!, omitAccidentals: MusicSettings.Range.omitAccidentals(for: clef)!)
        
        for button in [startButton, cancelButton] {
            addShadows(to: button!)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        let touch: UITouch? = touches.first
        //location is relative to the current view
        // do something with the touched point
        if view.traitCollection.verticalSizeClass == .compact {
            if running {
                if touch?.view != buttonStackView {
                    buttonStackView.isHidden = buttonStackView.isHidden ? false : true
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configDirectionLabel()
        setButtonStackViewAxis()
        configTranspositionLabel()
        configRangeLabel()
        transpositionLabel.text = MusicSettings.Transpose.description
        rangeLabel.text = MusicSettings.Range.description(for: clef)
    }
    
    func configDirectionLabel() {
        if view.traitCollection.verticalSizeClass == .compact {
            directionLabel.isHidden = true
        } else {
            directionLabel.isHidden = !running
        }
    }
    
    func configTranspositionLabel() {
        if view.traitCollection.verticalSizeClass == .compact {
            transpositionLabel.isHidden = true
        } else {
            transpositionLabel.isHidden = false
        }
    }
    
    func configRangeLabel() {
        if view.traitCollection.verticalSizeClass == .compact {
            rangeLabel.isHidden = true
        } else {
            rangeLabel.isHidden = false
        }
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
        if running {
            if view.traitCollection.verticalSizeClass == .compact {
                buttonStackView.isHidden = true
            } else {
                buttonStackView.isHidden = false
            }
        }
        configDirectionLabel()
        configTranspositionLabel()
        configRangeLabel()
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
        running = !running
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
                    self.configDirectionLabel()
                }
            }
        } else {
            pitchEngine.stop()
            sender.setTitle("Start", for: .normal)
            configDirectionLabel()
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
        if consecutivePitches.count < PitchDetectionSettings.consecutivePitches {
            consecutivePitches.append(pitch)
        } else {
            consecutivePitches.remove(at: 0)
            consecutivePitches.append(pitch)
            if checkIfIsPitch(pitches: consecutivePitches) {
                pitchEngine.stop()
                consecutivePitches.removeAll()
                let alertController = UIAlertController(title: note.string, message: nil, preferredStyle: .alert)
                print(pitch.note.string, pitch.note.index)
                let font = UIFont.systemFont(ofSize: 42.0)
                var color: UIColor
                var title: String
                
                if note.index == Int((flashcard?.pitchIndex)!) + MusicSettings.Transpose.semitones {
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

