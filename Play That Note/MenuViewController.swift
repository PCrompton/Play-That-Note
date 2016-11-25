//
//  MenuViewController.swift
//  Play That Note
//
//  Created by Paul Crompton on 11/12/16.
//  Copyright © 2016 Paul Crompton. All rights reserved.
//

import UIKit
import GameKit

class MenuViewController: UIViewController {
    
    override func viewDidLoad() {
        title = "Choose a Clef"
        authenticateLocalPlayer()
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
    
    func authenticateLocalPlayer() {
        let localPlayer = GKLocalPlayer.localPlayer()
        localPlayer.authenticateHandler = { (viewController, error) -> Void in
            if let viewController = viewController {
                self.present(viewController, animated: true, completion: nil)
            } else {
                print("Authentication Successful: \(GKLocalPlayer.localPlayer().isAuthenticated)")
            }
        }
    }
}
