//
//  FlashcardAlertViewController.swift
//  Play That Note
//
//  Created by Paul Crompton on 4/17/18.
//  Copyright © 2018 Paul Crompton. All rights reserved.
//

import UIKit
import CoreData

class FlashcardAlertViewController: UIViewController {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var containerView: UIView!
    var flashcardView: FlashcardView!
    
    var textColor: UIColor?
    var labelTitle: String?
    
    var flashcardHidden = false
    var pitchPlayed: String?
    
    private var formattedPitchPlayed: String? {
        if let pitch = self.pitchPlayed {
            var pitchTable: [String:String] = [
                "C#":"Db",
                "D#":"Eb",
                "F#":"Gb",
                "G#":"Ab",
                "A#":"Bb"
            ]
            
            if pitch.count > 2 {
                let flat = pitchTable[String(pitch[..<pitch.index(before: pitch.endIndex)])]
                let oct = pitch.last
                if let originalPitch = flashcard?.note {
                    let accidental = String(originalPitch[originalPitch.index(after: originalPitch.startIndex)])
                    if accidental == "b" {
                        if let flat = flat, let oct = oct {
                            return "\(flat)\(oct)"
                        }
                    }
                }
                if let originalPitch = flashcard?.note {
                    if originalPitch.count < 3 {
                        let letter = String(pitch[pitch.startIndex])
                        if letter == "A" || letter == "D" {
                            if let flat = flat, let oct = oct {
                                return "\(flat)\(oct)"
                            }
                        }
                    }
                }
            }
            return pitch
        }
        return nil
    }
    
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
    var clef = Clef.treble
    
    func setFlashcardView() {
        flashcardView = FlashcardView(clef: clef, pitch: flashcard?.note, containerView: containerView, secondPitch: formattedPitchPlayed)
        flashcardView.zoomFactor = 3
        addShadow(to: flashcardView!.containerView)
        addShadow(to: label)
    }
    
    func configureTitle() {
        if let title = labelTitle {
            label.text = title
        }
        if let color = textColor {
            label.textColor = color
        }
    }
    
    func configurePresentation() {
        if flashcardHidden {
            containerView?.isHidden = true
        } else {
            containerView?.isHidden = false
        }
    }
    
    func addShadow(to view: UIView) {
        view.layer.shadowOpacity = 0.7
        view.layer.shadowOffset = CGSize(width: 3.0, height: 2.0)
        view.layer.shadowRadius = 5.0
        view.layer.shadowColor = UIColor.darkGray.cgColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setFlashcardView()
        configureTitle()
        configurePresentation()

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.layoutIfNeeded()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        _ = self.flashcardView?.reload()
    }
    
    func animateView() {
        flashcardView.alpha = 0;
        self.flashcardView.frame.origin.y = self.flashcardView.frame.origin.y + 50
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            self.flashcardView.alpha = 1.0;
            self.flashcardView.frame.origin.y = self.flashcardView.frame.origin.y - 50
        })
    }
}
