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
    
    func configureAlertTitle(for alertController: UIAlertController, with title: String, with font: UIFont, with color: UIColor) {
        let myString  = title
        var myMutableString = NSMutableAttributedString()
        myMutableString = NSMutableAttributedString(string: myString as String, attributes: [NSAttributedStringKey.font:font])
        myMutableString.addAttribute(NSAttributedStringKey.foregroundColor, value: color, range: NSRange(location:0,length:myString.count))
        alertController.setValue(myMutableString, forKey: "attributedTitle")
    }
}
