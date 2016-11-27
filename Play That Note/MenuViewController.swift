//
//  MenuViewController.swift
//  Play That Note
//
//  Created by Paul Crompton on 11/12/16.
//  Copyright © 2016 Paul Crompton. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {
    
    let statsModelController = StatsModelController()
    let gameCenterModelController = GameCenterModelController()
    
    @IBOutlet weak var bestScoresLabel: UILabel!
    
    @IBOutlet weak var bestScoresActivityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        title = "Choose a Clef"

        gameCenterModelController.authenticateLocalPlayer { (viewController, error) in
            if error != nil {
                DispatchQueue.main.async {
                    self.showErrorPopup(with: "Error Authenticating Player", message: "Check your internet connection")
                }
            }
            if let viewController = viewController {
                self.present(viewController, animated: true, completion: nil)
            } else {
                self.gameCenterModelController.getBestScores(completion: { (scores, error) in
                    if error != nil {
                        DispatchQueue.main.async {
                            self.bestScoresActivityIndicator.stopAnimating()
                            self.bestScoresLabel.text = "No Connection"
                            self.bestScoresLabel.isHidden = false
                            self.showErrorPopup(with: "Error Downloading Scores", message: "Check your internet connection")
                        }
                    }
                    if let scores = scores {
                        DispatchQueue.main.async {
                            let randomScoreIndex = Int(arc4random_uniform(UInt32(scores.count)))
                            self.bestScoresLabel.text = scores[randomScoreIndex]
                            self.bestScoresActivityIndicator.stopAnimating()
                            self.bestScoresLabel.isHidden = false
                        }
                    }
                })
            }
        }
    }
    
    func showErrorPopup(with title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default)
        alertController.addAction(action)
        self.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let sender = sender as? UIButton else {
            return
        }
        guard let destinationController = segue.destination as? GameViewController else {
            return
        }
        
        switch sender.tag {
        case 0: destinationController.clef = Clef.treble
        case 1: destinationController.clef = Clef.bass
        case 2: destinationController.clef = Clef.alto
        case 3: destinationController.clef = Clef.tenor
        default: return
        }
    }
}
