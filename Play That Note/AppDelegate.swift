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
    
    func checkIfFirstLaunch() {
        if (UserDefaults.standard.bool(forKey: "hasLaunchedBefore")) {
            print("App has launched before")
            Settings.consecutivePitches = UserDefaults.standard.value(forKey: "consecutivePitches") as! Int
            Settings.bufferSize = UserDefaults.standard.value(forKey: "bufferSize") as! AVAudioFrameCount
            Settings.levelThreshold = UserDefaults.standard.value(forKey: "levelThreshold") as! Float
        } else {
            print("This is the first launch ever!")
            UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
//            UserDefaults.standard.set(Settings.consecutivePitches, forKey: "consecutivePitches")
//            UserDefaults.standard.set(Settings.bufferSize, forKey: "bufferSize")
//            UserDefaults.standard.set(Settings.levelThreshold, forKey: "levelThreshold")
        }
    }
    
    func applicationDidFinishLaunching(_ application: UIApplication) {
        checkIfFirstLaunch()
    }
}

