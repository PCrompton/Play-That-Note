//
//  MusicSettings.swift
//  Play That Note
//
//  Created by Paul Crompton on 7/1/17.
//  Copyright © 2017 Paul Crompton. All rights reserved.
//

import Foundation





struct MusicSettings {
    
    static var direction = "Lower"
    static var octave = 0
    static var quality = "Perfect"
    static var interval = "Unison"
    
    static var transposeDescription: String {
        let intervalExp: String
        if interval == "Unison" {
            intervalExp = ""
        } else if quality == "Augmented" {
            intervalExp = "an \(quality.lowercased()) \(interval) "
        } else {
            intervalExp = "a \(quality.lowercased()) \(interval) "
        }
        
        let octaveExp: String
        if octave == 1 {
            octaveExp = "an octave "
        } else if octave > 1 {
            octaveExp = "\(octave) octaves "
        } else {
            octaveExp = ""
        }
        
        let and: String
        if octaveExp == "" || intervalExp == "" {
            and = ""
        } else {
            and = "and "
        }
        
        let preposition: String
        if intervalExp == "" && octaveExp == "" {
            preposition = "as "
        } else {
            preposition = "than "
        }
        
 
        let dirExp: String
        if preposition == "as " {
            dirExp = ""
        } else {
            dirExp = "\(direction.lowercased()) "
        }
   
        return "Sounds \(octaveExp)\(and)\(intervalExp)\(dirExp)\(preposition)written"
    }
    
    static let transposePickerView: [[String]] = [
        ["Lower", "Higher"],
        addOctaveSuffix(numArray(0, max: 2)),
        ["Diminished", "Major",  "Perfect", "Minor", "Augmented"],
        addIntervalSuffix(numArray(1, max: 7))
    ]
    
    static func addIntervalSuffix(_ array: [String]) -> [String] {
        var newArray = [String]()
        for e in array {
            switch e {
            case "1":
                newArray.append("Unison")
            case "2":
                newArray.append("\(e)nd")
            case "3":
                newArray.append("\(e)rd")
            default:
                newArray.append("\(e)th")
            }
        }
        return newArray
    }
    
    static func numArray(_ min: Int, max: Int) -> [String] {
        var array = [String]()
        var i = min
        while i <= max {
            array.append("\(i)")
            i += 1
        }
        return array
    }
    
    static func addOctaveSuffix(_ array: [String]) -> [String] {
        var newArray = [String]()
        for e in array {
            if e == "1" {
                newArray.append("\(e) Octave")
            } else {
                newArray.append("\(e) Octaves")
            }
        }
        return newArray
    }
}

