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
    let localPlayer = GKLocalPlayer.localPlayer()
    
    // MARK: GameCenter functions
    func authenticateLocalPlayer(completion: ((_ viewController: UIViewController?, _ error: Error?) -> Void)?) {
        localPlayer.authenticateHandler = { (viewController, error) -> Void in
            if viewController == nil {
                print("Authentication Successful: \(GKLocalPlayer.localPlayer().isAuthenticated)")
            }
            completion?(viewController, error)
        }
    }
    func getBestScores(completion: @escaping (_ scores: [String]?, _ error: Error?) -> Void) {
        GKLeaderboard.loadLeaderboards() { (leaderboards, error) in
            if let error = error {
                completion(nil, error)
            } else if let leaderboards = leaderboards {
                print("Leaderboards: \(leaderboards)")
                var bestScores = [String]()
                for leaderboard in leaderboards {
                    leaderboard.playerScope = .global
                    leaderboard.loadScores(completionHandler: { (scores, error) in
                        if let error = error {
                            completion(nil, error)
                        }
                        if let bestScore = scores?[0].formattedValue {
                            bestScores.append(bestScore)
                            if leaderboards.last === leaderboard {
                                completion(bestScores, nil)
                            }
                        }
                    })
                }
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
        gameCenterViewController.viewState = .leaderboards
        return gameCenterViewController
    }
    
    // MARK: GKGameCenterControllerDelegate functions
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
}
