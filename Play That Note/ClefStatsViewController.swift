//
//  ClefStatsViewController.swift
//  Play That Note
//
//  Created by Paul Crompton on 11/19/16.
//  Copyright © 2016 Paul Crompton. All rights reserved.
//

import UIKit
import CoreData
import GameKit

class ClefStatsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var statsModelController = StatsModelController()
    
    @IBOutlet weak var tableView: UITableView!
        
    // MARK: IBActions
    @IBAction func leaderboardsButton(_ sender: Any) {
        present(statsModelController.getGameCenterViewController(), animated: true, completion: nil)
    }
    @IBAction func doneButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: TableViewDataSource Functions
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
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
        if let clef = cell.clef {
            cell.textLabel?.text = "\(clef.rawValue.capitalized) Clef"
            let stats = statsModelController.getStats(for: statsModelController.fetchSavedFlashcards(for: clef, lowest: nil, highest: nil))
            let percentage = stats.percentage
            if let percentage = percentage {
                cell.detailTextLabel?.text = "\(Int(percentage))%"
            } else {
                cell.detailTextLabel?.text = "Not Started"
            }
        }
        return cell
    }
    
    // MARK: TableViewDelegate Functions
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let statsVC = storyboard?.instantiateViewController(withIdentifier: "StatsViewController") as! StatsViewController
        let cell = tableView.cellForRow(at: indexPath) as! ClefTableViewCell
        if let clef = cell.clef {
            statsVC.clef = clef
            show(statsVC, sender: self)
        }
    }
}
