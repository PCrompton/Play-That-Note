//
//  SettingsTableViewController.swift
//  Play That Note
//
//  Created by Paul Crompton on 11/14/16.
//  Copyright © 2016 Paul Crompton. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {
    
    
    // MARK: Properties
    @IBOutlet weak var consecutivePitchesTextField: UITextField!
    @IBOutlet weak var bufferSizeSlider: UISlider!
    @IBOutlet weak var levelThresholdSlider: UISlider!


    // MARK: Methods
    @IBAction func doneButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func consecutivePitchesStepper(_ sender: Any) {
    }
    
    @IBAction func bufferSlider(_ sender: Any) {
    }
    
    @IBAction func levelThresholdSlider(_ sender: Any) {
    }
}
