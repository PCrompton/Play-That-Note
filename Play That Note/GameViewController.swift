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
    
    var pitchEngine: PitchEngine?
    var consecutivePitches = [Pitch]()
    var flashcards = [Flashcard]()

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
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        pitchEngine?.stop()
        gameCenterModelController.sendScores()
    }
    
    // MARK: Gameplay Functions
    @IBAction func StartButton(_ sender: UIButton) {
        guard let pitchEngine = pitchEngine else {
            fatalError("No Pitch Engine Found")
        }
        if !pitchEngine.active {
            pitchEngine.start()
            
            // These two lines of code are here to guard against a known bug in the Beethoven framework where the pitchEngine may not start on the first try
            pitchEngine.stop()
            pitchEngine.start()
            
            sender.setTitle("Stop", for: .normal)
            print("Pitch Engine Started")
            flashcard = getRandomflashcard()
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
                    self.flashcard = self.getRandomflashcard()
                }
                alertController.addAction(action)
                print(pitch.note.string, pitch.note.index)
                guard let noteToDisplay = flashcard?.note else {
                    fatalError("No note found")
                }
                if note.index == Int((flashcard?.pitchIndex)!) {
                    alertController.title = noteToDisplay
                    alertController.message = "Congrates, you played \(noteToDisplay)"
                    flashcard?.correct += 1
                } else {
                    alertController.message = "Sorry, that was not \(noteToDisplay)"
                    flashcard?.incorrect += 1
                }
                stack.save()
                updateStatsLabels()
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

