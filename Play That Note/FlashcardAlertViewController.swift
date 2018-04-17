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
    
    func configureTitle() {
        if let title = labelTitle {
            label.text = title
        }
        if let color = textColor {
            label.textColor = color
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setFlashcardView()
        configureTitle()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.layoutIfNeeded()
    }
    
    func animateView() {
        flashcardView.alpha = 0;
        self.flashcardView.frame.origin.y = self.flashcardView.frame.origin.y + 50
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            self.flashcardView.alpha = 1.0;
            self.flashcardView.frame.origin.y = self.flashcardView.frame.origin.y - 50
        })
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
