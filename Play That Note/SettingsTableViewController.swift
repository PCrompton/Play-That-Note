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
    @IBOutlet weak var consecutivePitchesLabel: UILabel!
    @IBOutlet weak var consecutivePitchesStepper: UIStepper!
    @IBOutlet weak var bufferSizeLabel: UILabel!
    @IBOutlet weak var bufferSizeSlider: UISlider!
    @IBOutlet weak var levelThresholdSlider: UISlider!
    
    
    // MARK: Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        consecutivePitchesStepper.value = Double(Settings.consecutiveMax)
        consecutivePitchesLabel.text = "\(Settings.consecutiveMax) Pitches"
        bufferSizeLabel.text = "\(Settings.bufferSize)"
        bufferSizeSlider.value = Float(Settings.bufferSize)
    }
    
    // MARK: IBActions
    @IBAction func doneButton() {
        dismiss(animated: true, completion: nil)
    }

    
    @IBAction func consecutivePitchesStepper(_ stepper: UIStepper) {
        consecutivePitchesLabel.text = "\(Int(stepper.value)) Pitches"
        Settings.consecutiveMax = Int(stepper.value)
        print("Stepper Pressed", Settings.consecutiveMax)
    }
    
    @IBAction func bufferSlider(_ slider: UISlider) {
        bufferSizeLabel.text = "\(Int(slider.value))"
        Settings.bufferSize = UInt32(slider.value)
        print("Slider Value Changed", Settings.bufferSize)
    }
    
    @IBAction func levelThresholdSlider(_ sender: UISlider) {
    }
}
