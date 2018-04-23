//
//  GameViewController+PitchEngineDelegate.swift
//  Play That Note
//
//  Created by Paul Crompton on 4/16/18.
//  Copyright © 2018 Paul Crompton. All rights reserved.
//

import Foundation
import Pitchy
import Beethoven
import AVFoundation
import UIKit

extension GameViewController {
    
    func configurePitchEngine() {
        let config = Config(bufferSize: PitchDetectionSettings.bufferSize, estimationStrategy: PitchDetectionSettings.estimationStrategy)
        pitchEngine = PitchEngine(config: config, delegate: self)
        pitchEngine?.levelThreshold = PitchDetectionSettings.levelThreshold
    }
    
    func stopGame(sender: UIButton, pitchEngine: PitchEngine) {
        running = false
        pitchEngine.stop()
        sender.setTitle("Start", for: .normal)
        configDirectionLabel()
        print("Pitch Engine Stopped")
    }
    
    func startGame(sender: UIButton, pitchEngine: PitchEngine) {
        running = true
        flashCardActivityIndicator.startAnimating()
        sender.isEnabled = false
        let concurrentQueue = DispatchQueue(label: "queuename", attributes: .concurrent)
        concurrentQueue.async {
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
    }
    
    func configureFlashcardAlertViewController() -> FlashcardAlertViewController {
        let flashcardAlertViewController = self.storyboard?.instantiateViewController(withIdentifier: "FlashcardAlertViewController") as! FlashcardAlertViewController
        flashcardAlertViewController.clef = clef
        flashcardAlertViewController.providesPresentationContextTransitionStyle = true
        flashcardAlertViewController.definesPresentationContext = true
        flashcardAlertViewController.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        flashcardAlertViewController.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        
        return flashcardAlertViewController
        
    }
    
    // MARK: PitchEngineDelegate functions
    func pitchEngine(_ pitchEngine: PitchEngine, didReceivePitch pitch: Pitch) {
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
                
                print(pitch.note.string, pitch.note.index)
                let flashcardAlertViewController = configureFlashcardAlertViewController()
                
                if note.index == Int((flashcard?.pitchIndex)!) + MusicSettings.Transpose.semitones {
                    flashcardAlertViewController.flashcardHidden = true
                    flashcardAlertViewController.labelTitle = "Correct!"
                    flashcardAlertViewController.textColor = UIColor.green
                    flashcard?.correct += 1
                    correct += 1
                    
                } else {
                    let pitchIndex = Int((flashcard?.pitchIndex)!)
                    if note.index > pitchIndex + 12 {
                        flashcardAlertViewController.flashcardHidden = true
                        flashcardAlertViewController.labelTitle = "Way too high!"
                    } else if note.index < pitchIndex - 12 {
                        flashcardAlertViewController.flashcardHidden = true
                        flashcardAlertViewController.labelTitle = "Way too low!"
                    } else {
                        flashcardAlertViewController.flashcardHidden = false
                        flashcardAlertViewController.flashcard = flashcard
                        flashcardAlertViewController.secondPitch = note.string
                        if note.index > pitchIndex {
                            flashcardAlertViewController.labelTitle = "Too high!"
                        } else if note.index < pitchIndex {
                            flashcardAlertViewController.labelTitle = "Too low!"
                        }
                    }
                    
                    if samePitchClass(pitchIndex1: note.index, pitchIndex2: pitchIndex) {
                        flashcardAlertViewController.labelTitle?.append("\nWrong octave!")
                        //flashcardAlertViewController.flashcardHidden = true
                    }
                    
                    flashcardAlertViewController.textColor = UIColor.red
                    flashcard?.incorrect += 1
                    incorrect += 1
                }
                stack.save()
                updateStatsLabels()
                
                present(flashcardAlertViewController, animated: true)
                var delay = 1.5
                if !flashcardAlertViewController.flashcardHidden {
                    delay = 2.0
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    flashcardAlertViewController.dismiss(animated: true, completion: {
                        
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
    
    func pitchEngine(_ pitchEngine: PitchEngine, didReceiveError error: Error) {
        print(Error.self)
        consecutivePitches.removeAll()
    }
    
    public func pitchEngineWentBelowLevelThreshold(_ pitchEngine: PitchEngine) {
        print("Below Threshhold", pitchEngine.signalLevel)
        consecutivePitches.removeAll()
        return
    }
    
    // Helper functions
    func checkIfIsPitch(pitches: [Pitch]) -> Bool {
        for i in 1..<pitches.count {
            if pitches[i].note.index != pitches[i-1].note.index {
                return false
            }
        }
        return true
    }
    
    func samePitchClass(pitchIndex1: Int, pitchIndex2: Int) -> Bool {
        var sortedArray = [pitchIndex1, pitchIndex2].sorted()
        var lower = sortedArray[0]
        var higher = sortedArray[1]
        if lower < 0 {
            let diff = abs(lower)
            lower += diff
            higher += diff
        }
        return lower%12 == higher%12
    }
    
    func configureAlertTitle(for alertController: FlashcardAlertViewController, with title: String, with font: UIFont, with color: UIColor) {
        alertController.label.text = title
        alertController.label.font = font
        alertController.label.textColor = color
    }
}
