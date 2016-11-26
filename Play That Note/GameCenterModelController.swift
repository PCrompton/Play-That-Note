//
//  GameCenterModelController.swift
//  Play That Note
//
//  Created by Paul Crompton on 11/26/16.
//  Copyright © 2016 Paul Crompton. All rights reserved.
//

import Foundation
import GameKit

class GameCenterModelController: NSObject, GKGameCenterControllerDelegate {
    let statsModelController = StatsModelController()
    
    // MARK: GameCenter functions
    func authenticateLocalPlayer(completion: ((_ viewController: UIViewController) -> Void)?) {
        let localPlayer = GKLocalPlayer.localPlayer()
        localPlayer.authenticateHandler = { (viewController, error) -> Void in
            if let viewController = viewController {
                completion?(viewController)
            } else {
                print("Authentication Successful: \(GKLocalPlayer.localPlayer().isAuthenticated)")
            }
        }
    }
    
    func sendScores() {
        if GKLocalPlayer.localPlayer().isAuthenticated {
            let totalFlashcards = statsModelController.fetchSavedFlashcards(with: nil)
            let totalStats = statsModelController.getStats(for: totalFlashcards)
            let totalPlusMinus = totalStats.plusMinus
            let scoreReporter = GKScore(leaderboardIdentifier: "total.plus.minus")
            scoreReporter.value = Int64(totalPlusMinus)
            let scoreArray: [GKScore] = [scoreReporter]
            GKScore.report(scoreArray) { (error) in
                if let error = error {
                    print("Error reporting scores: \(error)")
                } else {
                    print("Successfully reported scores")
                }
            }
        }
    }
    
    func getGameCenterViewController() -> GKGameCenterViewController {
        let gameCenterViewController = GKGameCenterViewController()
        gameCenterViewController.gameCenterDelegate = self
        return gameCenterViewController
    }
    
    // MARK: GKGameCenterControllerDelegate functions
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
}
