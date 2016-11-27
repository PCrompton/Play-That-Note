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
                            if leaderboards[leaderboards.endIndex-1] === leaderboard {
                                completion(bestScores, nil)
                            } else {
                                completion(nil, nil)
                            }
                        }
                    })
                }
            }
        }
    }
    
    func sendScores() {
        if GKLocalPlayer.localPlayer().isAuthenticated {
            var scoreArray = [GKScore]()
            let totalStats = statsModelController.getStatsTotals()
            let totalPlusMinus = totalStats.plusMinus
            let totalPercentage = totalStats.percentage
            let totalPlusMinusScoreReporter = GKScore(leaderboardIdentifier: "total.plus.minus")
            scoreArray.append(totalPlusMinusScoreReporter)
            let totalPercentageScoreReporter = GKScore(leaderboardIdentifier: "total.percentage")
            totalPlusMinusScoreReporter.value = Int64(totalPlusMinus)
            if let totalPercentage = totalPercentage {
                totalPercentageScoreReporter.value = Int64(totalPercentage)
                scoreArray.append(totalPercentageScoreReporter)
            }
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
        gameCenterViewController.leaderboardIdentifier = "total.plus.minus"
        return gameCenterViewController
    }
    
    // MARK: GKGameCenterControllerDelegate functions
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
}
