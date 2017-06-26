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
    
    @IBOutlet weak var bestScoreStackView: UIStackView!
    @IBOutlet weak var bestScoresLabel: UILabel!
    @IBOutlet weak var bestScoresActivityIndicator: UIActivityIndicatorView!

    @IBOutlet weak var trebleClefButton: UIButton!
    @IBOutlet weak var bassClefButton: UIButton!
    @IBOutlet weak var altoClefButton: UIButton!
    @IBOutlet weak var tenorClefButton: UIButton!
    
    @IBOutlet weak var clefStackView: UIStackView!
    @IBOutlet weak var topClefStackView: UIStackView!
    @IBOutlet weak var bottomClefStackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bestScoreStackView.isHidden = true
        authenticatePlayerAndDownloadScores()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if gameCenterModelController.localPlayer.isAuthenticated {
            getBestScores()
            bestScoreStackView.isHidden = false
        } else {
            authenticatePlayerAndDownloadScores()
            bestScoreStackView.isHidden = true
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.verticalSizeClass == .compact {
            trebleClefButton.contentVerticalAlignment = .center
            trebleClefButton.contentHorizontalAlignment = .center

            bassClefButton.contentVerticalAlignment = .center
            bassClefButton.contentHorizontalAlignment = .center
            
            altoClefButton.contentVerticalAlignment = .center
            altoClefButton.contentHorizontalAlignment = .center
            
            tenorClefButton.contentVerticalAlignment = .center
            tenorClefButton.contentHorizontalAlignment = .center
        } else {
            trebleClefButton.contentVerticalAlignment = .bottom
            trebleClefButton.contentHorizontalAlignment = .right
            
            bassClefButton.contentVerticalAlignment = .bottom
            bassClefButton.contentHorizontalAlignment = .left
            
            altoClefButton.contentVerticalAlignment = .top
            altoClefButton.contentHorizontalAlignment = .right
            
            tenorClefButton.contentVerticalAlignment = .top
            tenorClefButton.contentHorizontalAlignment = .left
        }
    }
    
    func authenticatePlayerAndDownloadScores() {
        gameCenterModelController.authenticateLocalPlayer { (viewController, error) in
            if let viewController = viewController {
                self.present(viewController, animated: true, completion: nil)
            }
            self.getBestScores()
            self.gameCenterModelController.sendScores()
            if self.gameCenterModelController.localPlayer.isAuthenticated {
                self.bestScoreStackView.isHidden = false
            }
        }
    }
    
    func getBestScores() {
        gameCenterModelController.getBestScores(completion: { (scores, error) in
            if error != nil {
                DispatchQueue.main.async {
                    let errorMessage: String
                    if self.gameCenterModelController.localPlayer.isAuthenticated {
                        errorMessage = "Check your internet connection"
                    } else {
                        errorMessage = "You are not logged into Game Center. To log into Game Center, open the iOS Settings app, scroll down to Game Center and tap \"Sign In.\""
                    }
                    self.bestScoresLabel.text = "No Connection"
                    self.showErrorPopup(with: "Error Downloading Scores", message: errorMessage)
                }
            }
            if let scores = scores {
                DispatchQueue.main.async {
                    let randomScoreIndex = Int(arc4random_uniform(UInt32(scores.count)))
                    self.bestScoresLabel.text = scores[randomScoreIndex]
                }
            } else {
                self.bestScoresLabel.text = "No Data"
            }
            DispatchQueue.main.async {
                self.bestScoresActivityIndicator.stopAnimating()
                self.bestScoresLabel.isHidden = false
            }
        })
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
