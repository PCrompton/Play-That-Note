//
//  ClefStatsViewController.swift
//  Play That Note
//
//  Created by Paul Crompton on 11/19/16.
//  Copyright © 2016 Paul Crompton. All rights reserved.
//

import UIKit
import CoreData

class ClefStatsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let statsModelController = StatsModelController()
    let gameCenterModelController = GameCenterModelController()
    
    @IBOutlet weak var tableView: UITableView!
        
    // MARK: IBActions
    @IBAction func leaderboardsButton(_ sender: Any) {
        present(gameCenterModelController.getGameCenterViewController(), animated: true, completion: nil)
    }
    @IBAction func resetButton(_ sender: Any) {
        let alertVC = UIAlertController(title: "Are you sure you want to reset your statistics?", message: "All statistics, including those in Game Center will be deleted. This cannot be undone.", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler:
            { (UIAlertAction) in
                self.statsModelController.deleteAllFlashcards()
                self.gameCenterModelController.sendScores()
                self.tableView.reloadData()
        })
        alertVC.addAction(cancelAction)
        alertVC.addAction(deleteAction)
        present(alertVC, animated: true, completion: nil)
    }
    
    // MARK: TableViewDataSource Functions
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ClefCell") as? ClefTableViewCell else {
            fatalError("Unable to instantiate cell")
        }
       
        switch indexPath.row {
        case 0:
            cell.clef = Clef.treble
        case 1:
            cell.clef = Clef.bass
        case 2:
            cell.clef = Clef.alto
        case 3:
            cell.clef = Clef.tenor
        default:
            cell.clef = nil
        }
        let stats: Stats
        if let clef = cell.clef {
            cell.textLabel?.text = "\(clef.rawValue.capitalized) Clef"
            stats = statsModelController.getStats(for: clef, lowest: nil, highest: nil)
        } else {
            cell.textLabel?.text = "Total"
            stats = statsModelController.getStatsTotals()
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: (cell.textLabel?.font.pointSize)!)
            cell.detailTextLabel?.font = UIFont.boldSystemFont(ofSize: (cell.detailTextLabel?.font.pointSize)!)
        }
        let percentage = stats.percentage
        if let percentage = percentage {
            cell.detailTextLabel?.text = "\(Int(percentage))%"
        } else {
            cell.detailTextLabel?.text = "Not Started"
        }

        return cell
    }
    
    // MARK: TableViewDelegate Functions
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let statsVC = storyboard?.instantiateViewController(withIdentifier: "StatsViewController") as! StatsViewController
        let cell = tableView.cellForRow(at: indexPath) as! ClefTableViewCell
        statsVC.clef = cell.clef
        show(statsVC, sender: self)
    }
}
