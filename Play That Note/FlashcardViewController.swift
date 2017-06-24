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

class FlashcardViewController: UIViewController {
    
    // MARK: Parameters
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var correctLabel: UILabel!
    @IBOutlet weak var incorrectLabel: UILabel!
    @IBOutlet weak var percentageLabel: UILabel!
    @IBOutlet weak var plusMinusLabel: UILabel!
    
    let stack = (UIApplication.shared.delegate as! AppDelegate).stack
    let statsModelController = StatsModelController()
    let gameCenterModelController = GameCenterModelController()
    
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
    
    var flashcardView: FlashcardView?
    
    var flashcard: Flashcard? {
        didSet {
            if let flashcard = flashcard {
                flashcardView?.pitch = flashcard.note!
                flashcardView?.clef = flashcard.clef!
            }
            _ = flashcardView?.reload()
        }
    }
    
    // MARK: Lifecycle functions
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.hidesBarsWhenVerticallyCompact = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        updateStatsLabels()
        flashcardView = FlashcardView(clef: clef, pitch: flashcard?.note, containerView: containerView)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.hidesBarsWhenVerticallyCompact = false
        navigationController?.hidesBarsOnTap = false
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        _ = flashcardView?.reload()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if view.traitCollection.verticalSizeClass == .compact {
            navigationController?.hidesBarsOnTap = true
        } else {
            navigationController?.hidesBarsOnTap = false
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
}
