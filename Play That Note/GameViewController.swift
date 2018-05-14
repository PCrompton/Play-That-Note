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
    @IBOutlet weak var flashCardActivityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var transpositionLabel: UILabel!
    
    @IBOutlet weak var rangeLabel: UILabel!
    var pitchEngine: PitchEngine?
    var consecutivePitches = [Pitch]()
    var flashcards = [Flashcard]()
    
    var running = false
    
    var correct: Int = 0
    var incorrect: Int = 0
    var strikes: Int = 0 {
        didSet {
            if strikes > 0 {
                note1.isHighlighted = true
            }
            if strikes > 1 {
                note2.isHighlighted = true
            }
            
            if strikes > 2 {
                note3.isHighlighted = true
            }
            
            if strikes == 0 {
                note1.isHighlighted = false
                note2.isHighlighted = false
                note3.isHighlighted = false
            }
        }
    }
    
    @IBOutlet weak var noteStack: UIStackView!
    @IBOutlet weak var note1: UIImageView!
    @IBOutlet weak var note2: UIImageView!
    @IBOutlet weak var note3: UIImageView!
    
    
    var totalAnswered: Int {
        return Int(self.correct + self.incorrect)
    }
    var percentage: Double {
        if totalAnswered != 0 {
            return Double(correct)/Double(totalAnswered)*100
        }
        return 0.0
    }

    // MARK: Lifecyle Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        configurePitchEngine()
        configureFlashcards()
        configButtons()
        view.bringSubview(toFront: noteStack)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.layoutIfNeeded()
    }
    
    
    override func viewLayoutMarginsDidChange() {
        animateButtons()
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
                   
                    animateButtons()
                    //buttonStackView.isHidden = buttonStackView.isHidden ? false : true
                }
            }
        }
    }
    
    var hidden: Bool = false
    func animateButtons() {
        if view.traitCollection.verticalSizeClass == .compact {
            if hidden {
                buttonStackViewBottomConstraint.constant = 0
                hidden = false
            } else {
                buttonStackViewBottomConstraint.constant = -(buttonStackView.frame.height + 1)
                hidden = true
            }
            UIView.animate(withDuration: 0.25) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: nil) { (_) in
            if self.running {
                if self.view.traitCollection.verticalSizeClass == .compact {
                    if self.running {
                        self.hidden = false
                    } else {
                        self.hidden = true
                    }
                    self.animateButtons()
                } else {
                    self.hidden = true
                    self.animateButtons()
                }
            }
        }
    }


    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        setButtonStackViewAxis()

        configTranspositionLabel()
        configRangeLabel()
    }
    
    override func updateStatsLabels() {
        correctLabel.text = "\(correct)"
        incorrectLabel.text = "\(incorrect)"
        percentageLabel.text = "\(Int(percentage)) %"
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

