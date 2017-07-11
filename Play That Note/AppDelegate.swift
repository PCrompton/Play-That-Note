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
            
            
            if let consecutivePitches = UserDefaults.standard.value(forKey: "consecutivePitches") as? Int,
            let bufferSize = UserDefaults.standard.value(forKey: "bufferSize") as? AVAudioFrameCount,
            let levelThreshhold = UserDefaults.standard.value(forKey: "levelThreshold") as? Float {
                
                PitchDetectionSettings.consecutivePitches = consecutivePitches
                PitchDetectionSettings.bufferSize = bufferSize
                PitchDetectionSettings.levelThreshold = levelThreshhold
            } else {
                PitchDetectionSettings.resetToDefaults()
            }

            if let direction = UserDefaults.standard.value(forKey: "direction") as? String,
                let octave = UserDefaults.standard.value(forKey: "octave") as? Int,
                let quality = UserDefaults.standard.value(forKey: "quality") as? String,
                let interval = UserDefaults.standard.value(forKey: "interval") as? String {
                MusicSettings.Transpose.direction = MusicSettings.Transpose.Direction(rawValue: direction)!
                MusicSettings.Transpose.octave = octave
                MusicSettings.Transpose.quality = MusicSettings.Transpose.Quality(rawValue: quality)!
                MusicSettings.Transpose.interval =  MusicSettings.Transpose.Interval(rawValue: interval)!
            } else {
                MusicSettings.Transpose.resetToDefaults()
            }
            
            if let treble = UserDefaults.standard.value(forKey: "trebleRange") as? [Int],
                let bass = UserDefaults.standard.value(forKey: "bassRange") as? [Int],
                let alto = UserDefaults.standard.value(forKey: "altoRange") as? [Int],
                let tenor = UserDefaults.standard.value(forKey: "tenorRange") as? [Int],
                let trebleOmitAccidentals = UserDefaults.standard.value(forKey: "trebleOmitAccidentals") as? Bool,
                let bassOmitAccidentals = UserDefaults.standard.value(forKey: "bassOmitAccidentals") as? Bool,
                let altoOmitAccidentals = UserDefaults.standard.value(forKey: "altoOmitAccidentals") as? Bool,
                let tenorOmitAccidentals = UserDefaults.standard.value(forKey: "tenorOmitAccidentals") as? Bool {
                
                MusicSettings.Range.treble = MusicSettings.Range.ClefRange(clef: .treble, lowestIndex: treble[0], highestIndex: treble[1])
                MusicSettings.Range.bass = MusicSettings.Range.ClefRange(clef: .bass, lowestIndex: bass[0], highestIndex: bass[1])
                MusicSettings.Range.alto = MusicSettings.Range.ClefRange(clef: .alto, lowestIndex: alto[0], highestIndex: alto[1])
                MusicSettings.Range.tenor = MusicSettings.Range.ClefRange(clef: .tenor, lowestIndex: tenor[0], highestIndex: tenor[1])
                
                MusicSettings.Range.trebleOmitAccidentals = trebleOmitAccidentals
                MusicSettings.Range.bassOmitAccidentals = bassOmitAccidentals
                MusicSettings.Range.altoOmitAccidentals = altoOmitAccidentals
                MusicSettings.Range.tenorOmitAccidentals = tenorOmitAccidentals
            } else {
                MusicSettings.Range.resetToDefaults()
            }

        } else {
            print("This is the first launch ever!")
            UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
        }
    }
    
    func applicationDidFinishLaunching(_ application: UIApplication) {
        checkIfFirstLaunch()
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        IAPManager.sharedInstance.requestProducts()
        
        return true
    }
}

