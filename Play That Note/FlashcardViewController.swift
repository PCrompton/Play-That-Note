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
         
    var clef = Clef.treble
    
    var flashcardView: FlashcardView?
    
    var flashcard: Flashcard? {
        didSet {
            if let flashcard = flashcard {
                flashcardView?.pitch = flashcard.note!
                flashcardView?.clef = flashcard.clef!
            }
            DispatchQueue.main.async {
                _ = self.flashcardView?.reload()
            }
        }
    }
    
    func setFlashcardView() {
        flashcardView = FlashcardView(clef: clef, pitch: flashcard?.note, containerView: containerView)
        addFlashcardShadow(to: flashcardView!)
    }
    
    func addFlashcardShadow(to flashcardView: FlashcardView) {
        flashcardView.layer.shadowOpacity = 0.7
        flashcardView.layer.shadowOffset = CGSize(width: 3.0, height: 2.0)
        flashcardView.layer.shadowRadius = 5.0
        flashcardView.layer.shadowColor = UIColor.darkGray.cgColor
    }
    
    // MARK: Lifecycle functions
    override func viewDidLoad() {
        super.viewDidLoad()
        setFlashcardView()
        //navigationController?.hidesBarsWhenVerticallyCompact = true
    }
    
    func setBars() {
        let navBar = navigationController?.navigationBar
        let tabBar = tabBarController?.tabBar
        if view.traitCollection.verticalSizeClass == .compact {
            if let navBar = navBar {
                navBar.isHidden = navBar.isHidden ? false : true
            }
            if let tabBar = tabBar {
                tabBar.isHidden = tabBar.isHidden ? false : true
            }
        } else {
            if let navBar = navBar {
                navBar.isHidden = false
            }
            if let tabBar = tabBar {
                tabBar.isHidden = false
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        let touch: UITouch? = touches.first
        let navBar = navigationController?.navigationBar
        let tabBar = tabBarController?.tabBar
        if touch?.view != navBar && touch?.view != tabBar {
            setBars()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        updateStatsLabels()
        setFlashcardView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
        tabBarController?.tabBar.isHidden = false
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        _ = self.flashcardView?.reload()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        setBars()
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
        correctLabel.text = "\(flashcard.correct)"
        incorrectLabel.text = "\(flashcard.incorrect)"
        percentageLabel.text = "\(Int(flashcard.percentage)) %"
        plusMinusLabel.text = "\(flashcard.plusMinus) +/- "
        plusMinusLabel.textColor = getLabelColor(for: flashcard.plusMinus)
    }
}
