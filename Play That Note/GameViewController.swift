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
    
    @IBOutlet weak var buttonStackViewBottomConstraint: NSLayoutConstraint!
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
        configurePitchEngine()
        configureFlashcards()
        configButtons()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configDirectionLabel()
        setButtonStackViewAxis()
        configTranspositionLabel()
        configRangeLabel()
        setTranspositionLabel()
        setRangeLabel()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        pitchEngine?.stop()
        gameCenterModelController.sendScores()
    }
    
    //Layout control functions
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        let touch: UITouch? = touches.first
        //location is relative to the current view
        // do something with the touched point
        if view.traitCollection.verticalSizeClass == .compact {
            if running {
                if touch?.view != buttonStackView {
                    buttonStackViewBottomConstraint.constant = -(buttonStackView.frame.height + 1)
                    UIView.animate(withDuration: 0.5) {
                        self.view.layoutIfNeeded()
                    }
                    //buttonStackView.isHidden = buttonStackView.isHidden ? false : true
                }
            }
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
            startGame(sender: sender, pitchEngine: pitchEngine)
        } else {
            stopGame(sender: sender, pitchEngine: pitchEngine)
        }
    }
}

