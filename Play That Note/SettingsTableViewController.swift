//
//  SettingsTableViewController.swift
//  Play That Note
//
//  Created by Paul Crompton on 11/14/16.
//  Copyright © 2016 Paul Crompton. All rights reserved.
//

import UIKit
import AVFoundation

class SettingsTableViewController: UITableViewController {
    
    // MARK: Properties
    @IBOutlet weak var consecutivePitchesLabel: UILabel!
    @IBOutlet weak var consecutivePitchesStepper: UIStepper!
    @IBOutlet weak var bufferSizeLabel: UILabel!
    @IBOutlet weak var bufferSizeSlider: UISlider!
    @IBOutlet weak var levelThresholdLabel: UILabel!
    @IBOutlet weak var levelThresholdSlider: UISlider!
    
    
    // MARK: Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        consecutivePitchesLabel.text = "\(Settings.consecutivePitches) Pitches"
        consecutivePitchesStepper.value = Double(Settings.consecutivePitches)
        
        bufferSizeLabel.text = "\(Settings.bufferSize)"
        bufferSizeSlider.value = Float(Settings.bufferSize)
        
        levelThresholdLabel.text = "\(Settings.levelThreshold) dB"
        levelThresholdSlider.value = Settings.levelThreshold
    }
    
    // MARK: IBActions
    @IBAction func doneButton() {
        dismiss(animated: true, completion: nil)
    }

    
    @IBAction func consecutivePitchesStepper(_ stepper: UIStepper) {
        consecutivePitchesLabel.text = "\(Int(stepper.value)) Pitches"
        Settings.consecutivePitches = Int(stepper.value)
        print("Stepper Pressed", Settings.consecutivePitches)
    }
    
    @IBAction func bufferSlider(_ slider: UISlider) {
        bufferSizeLabel.text = "\(Int(slider.value))"
        Settings.bufferSize = AVAudioFrameCount(slider.value)
        print("Slider Value Changed", Settings.bufferSize)
    }
    
    @IBAction func levelThresholdSlider(_ slider: UISlider) {
        levelThresholdLabel.text = "\(slider.value) dB"
        Settings.levelThreshold = slider.value
    }

    @IBAction func restoreDefaultsButton(_ sender: UIBarButtonItem) {
        Settings.resetToDefaults()
        consecutivePitchesLabel.text = "\(Settings.consecutivePitches) Pitches"
        consecutivePitchesStepper.value = Double(Settings.consecutivePitches)

        bufferSizeLabel.text = "\(Settings.bufferSize)"
        bufferSizeSlider.value = Float(Settings.bufferSize)

        levelThresholdLabel.text = "\(Settings.levelThreshold) db"
        levelThresholdSlider.value = Settings.levelThreshold

    }
}
