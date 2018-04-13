//
//  Settings.swift
//  Play That Note
//
//  Created by Paul Crompton on 11/14/16.
//  Copyright © 2016 Paul Crompton. All rights reserved.
//

import Foundation
import Beethoven
import AVFoundation

struct PitchDetectionSettings {
    struct Defaults {
        static var consecutivePitches = 3
        static var bufferSize: AVAudioFrameCount = 4096
        static var levelThreshold: Float = -20.0
        static let estimationStrategy = EstimationStrategy.yin
    }
    
    static var consecutivePitches = Defaults.consecutivePitches {
        didSet {
            UserDefaults.standard.set(consecutivePitches, forKey: "consecutivePitches")
        }
    }
    static var bufferSize = Defaults.bufferSize {
        didSet {
            UserDefaults.standard.set(bufferSize, forKey: "bufferSize")
        }
    }
    static var levelThreshold = Defaults.levelThreshold {
        didSet {
            UserDefaults.standard.set(levelThreshold, forKey: "levelThreshold")
        }
    }
    
    static var estimationStrategy = Defaults.estimationStrategy
    
    static func resetToDefaults() {
        consecutivePitches = Defaults.consecutivePitches
        bufferSize = Defaults.bufferSize
        levelThreshold = Defaults.levelThreshold
        estimationStrategy = Defaults.estimationStrategy
    }
}
