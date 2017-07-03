//
//  AppDelegate.swift
//  Play That Note
//
//  Created by Paul Crompton on 11/7/16.
//  Copyright © 2016 Paul Crompton. All rights reserved.
//

import UIKit
import AVFoundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    let stack = CoreDataStack(modelName: "Model")!
    
    func checkIfFirstLaunch() {
        if (UserDefaults.standard.bool(forKey: "hasLaunchedBefore")) {
            print("App has launched before")
            Settings.consecutivePitches = UserDefaults.standard.value(forKey: "consecutivePitches") as! Int
            Settings.bufferSize = UserDefaults.standard.value(forKey: "bufferSize") as! AVAudioFrameCount
            Settings.levelThreshold = UserDefaults.standard.value(forKey: "levelThreshold") as! Float
            
            MusicSettings.Transpose.direction = MusicSettings.Transpose.Direction(rawValue: UserDefaults.standard.value(forKey: "direction") as! String)!
            MusicSettings.Transpose.octave = UserDefaults.standard.value(forKey: "octave") as! Int
            MusicSettings.Transpose.quality = MusicSettings.Transpose.Quality(rawValue: UserDefaults.standard.value(forKey: "quality") as! String)!
            MusicSettings.Transpose.interval =  MusicSettings.Transpose.Interval(rawValue: UserDefaults.standard.value(forKey: "interval") as! String)!
            
        } else {
            print("This is the first launch ever!")
            UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
            Settings.resetToDefaults()
            MusicSettings.Transpose.resetToDefaults()
        }
    }
    
    func applicationDidFinishLaunching(_ application: UIApplication) {
        checkIfFirstLaunch()
    }
}

