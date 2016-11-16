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
        consecutivePitchesLabel.text = "\(UserDefaults.standard.value(forKey: "consecutivePitches")!) Pitches"
        consecutivePitchesStepper.value = UserDefaults.standard.value(forKey: "consecutivePitches") as! Double
        
        bufferSizeLabel.text = "\(UserDefaults.standard.value(forKey: "bufferSize")!)"
        bufferSizeSlider.value = Float(UserDefaults.standard.value(forKey: "bufferSize") as! AVAudioFrameCount)
        
        levelThresholdLabel.text = "\(UserDefaults.standard.value(forKey: "levelThreshold")!) dB"
        levelThresholdSlider.value = UserDefaults.standard.value(forKey: "levelThreshold") as! Float
    }
    
    // MARK: IBActions
    @IBAction func doneButton() {
        dismiss(animated: true, completion: nil)
    }

    
    @IBAction func consecutivePitchesStepper(_ stepper: UIStepper) {
        consecutivePitchesLabel.text = "\(Int(stepper.value)) Pitches"
        UserDefaults.standard.set(Int(stepper.value), forKey: "consecutivePitches")
        //print("Stepper Pressed", Settings.consecutivePitches)
    }
    
    @IBAction func bufferSlider(_ slider: UISlider) {
        bufferSizeLabel.text = "\(Int(slider.value))"
        UserDefaults.standard.set(slider.value, forKey: "bufferSize")
        //print("Slider Value Changed", Settings.bufferSize)
    }
    
    @IBAction func levelThresholdSlider(_ slider: UISlider) {
        levelThresholdLabel.text = "\(slider.value) dB"
        UserDefaults.standard.set(slider.value, forKey: "levelThreshold")
    }

    @IBAction func restoreDefaultsButton(_ sender: UIBarButtonItem) {
        consecutivePitchesLabel.text = "\(Settings.consecutivePitches) Pitches"
        consecutivePitchesStepper.value = Double(Settings.consecutivePitches)
        UserDefaults.standard.set(Settings.consecutivePitches, forKey: "consecutivePitches")
        
        bufferSizeLabel.text = "\(Settings.bufferSize)"
        bufferSizeSlider.value = Float(Settings.bufferSize)
        UserDefaults.standard.set(Settings.bufferSize, forKey: "bufferSize")
        
        levelThresholdLabel.text = "\(Settings.levelThreshold) db"
        levelThresholdSlider.value = Settings.levelThreshold
        UserDefaults.standard.set(Settings.levelThreshold, forKey: "levelThreshold")
        
        
        
    }
}
