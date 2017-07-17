//
//  SettingsTableViewController.swift
//  Play That Note
//
//  Created by Paul Crompton on 11/14/16.
//  Copyright © 2016 Paul Crompton. All rights reserved.
//

import UIKit
import AVFoundation

class PitchDetectionSettingsTableViewController: UITableViewController {
    
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
        consecutivePitchesLabel.text = "\(PitchDetectionSettings.consecutivePitches) Buffers"
        consecutivePitchesStepper.value = Double(PitchDetectionSettings.consecutivePitches)
        
        bufferSizeLabel.text = "\(PitchDetectionSettings.bufferSize)"
        bufferSizeSlider.value = Float(PitchDetectionSettings.bufferSize)
        
        levelThresholdLabel.text = "\(PitchDetectionSettings.levelThreshold) dB"
        levelThresholdSlider.value = PitchDetectionSettings.levelThreshold
    }
    
    // MARK: IBActions
    @IBAction func consecutivePitchesStepper(_ stepper: UIStepper) {
        consecutivePitchesLabel.text = "\(Int(stepper.value)) Buffers"
        PitchDetectionSettings.consecutivePitches = Int(stepper.value)
    }
    
    @IBAction func bufferSlider(_ slider: UISlider) {
        bufferSizeLabel.text = "\(Int(slider.value))"
        PitchDetectionSettings.bufferSize = AVAudioFrameCount(slider.value)
    }
    
    @IBAction func levelThresholdSlider(_ slider: UISlider) {
        levelThresholdLabel.text = "\(slider.value) dB"
        PitchDetectionSettings.levelThreshold = slider.value
    }

    @IBAction func restoreDefaultsButton(_ sender: UIBarButtonItem) {
        PitchDetectionSettings.resetToDefaults()
        consecutivePitchesLabel.text = "\(PitchDetectionSettings.consecutivePitches) Pitches"
        consecutivePitchesStepper.value = Double(PitchDetectionSettings.consecutivePitches)

        bufferSizeLabel.text = "\(PitchDetectionSettings.bufferSize)"
        bufferSizeSlider.value = Float(PitchDetectionSettings.bufferSize)

        levelThresholdLabel.text = "\(PitchDetectionSettings.levelThreshold) db"
        levelThresholdSlider.value = PitchDetectionSettings.levelThreshold

    }
}
