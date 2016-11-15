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

struct Settings {
    static var consecutiveMax = 3
    static var bufferSize: AVAudioFrameCount = 4096
    static var estimationStragegy = EstimationStrategy.yin
    static var levelThreshold: Float = -20.0
}
