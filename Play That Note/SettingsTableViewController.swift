//
//  SettingsTableViewController.swift
//  Play That Note
//
//  Created by Paul Crompton on 6/30/17.
//  Copyright © 2017 Paul Crompton. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UITableViewDelegate Functions
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else {
            fatalError("Cell Not Found")
        }
        switch (cell.tag) {
        case 0:
            let vc = storyboard?.instantiateViewController(withIdentifier: "MusicSettingsTableViewController") as! MusicSettingsTableViewController
            show(vc, sender: cell)
        case 1:
            let vc = storyboard?.instantiateViewController(withIdentifier: "PitchDetectionSettingsTableViewController") as! PitchDetectionSettingsTableViewController
            show(vc, sender: cell)
        case 2:
            let vc = storyboard?.instantiateViewController(withIdentifier: "LicenseViewController") as! LicenseViewController
            show(vc, sender: cell)
        default: return
        }
    }

    // MARK: - Navigation

//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//
//    }
}
