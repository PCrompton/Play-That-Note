//
//  MusicSettings.swift
//  Play That Note
//
//  Created by Paul Crompton on 7/1/17.
//  Copyright © 2017 Paul Crompton. All rights reserved.
//

import Foundation

struct MusicSettings {

    struct Transpose {
        
        enum Direction: String {
            case lower = "Lower"
            case higher = "Higher"
        }
        
        enum Quality: String {
            case diminished = "Diminished"
            case minor = "Minor"
            case perfect = "Perfect"
            case major = "Major"
            case augmented = "Augmented"
        }
        
        enum Interval: String {
            case unison = "Unison"
            case second = "2nd"
            case third = "3rd"
            case fourth = "4th"
            case fifth = "5th"
            case sixth = "6th"
            case seventh = "7th"
        }
        
        static var direction = Direction.lower
        static var octave = 0
        static var quality = Quality.perfect
        static var interval = Interval.unison
        
        static var semitones: Int {
            var semitones = 0
            switch interval {
            case .unison:
                break
            case .second:
                if quality == .minor {
                    semitones += 1
                } else if quality == .major {
                    semitones += 2
                }
            case .third:
                if quality == .minor {
                    semitones += 3
                } else if quality == .major {
                    semitones += 4
                }
            case .fourth:
                if quality == .diminished {
                    semitones += 4
                } else if quality == .perfect {
                    semitones += 5
                } else if quality == .augmented {
                    semitones += 6
                }
            case .fifth:
                if quality == .diminished {
                    semitones += 6
                } else if quality == .perfect {
                    semitones += 7
                } else if quality == .augmented {
                    semitones += 8
                }
            case .sixth:
                if quality == .minor {
                    semitones += 8
                } else if quality == .major {
                    semitones += 9
                }
            case .seventh:
                if quality == .minor {
                    semitones += 10
                } else if quality == .major {
                    semitones += 11
                }
            }
            switch direction {
            case .higher:
                return semitones + 12*octave
            case .lower:
                return -semitones - 12*octave
            }
        }
        
        static var description: String {
            let intervalExp: String
            if interval == .unison {
                intervalExp = String()
            } else if quality == .augmented {
                intervalExp = "an \(quality) \(interval) ".lowercased()
            } else {
                intervalExp = "a \(quality) \(interval) ".lowercased()
            }
            
            let octaveExp: String
            if octave == 1 {
                octaveExp = "an octave "
            } else if octave > 1 {
                octaveExp = "\(octave) octaves "
            } else {
                octaveExp = String()
            }
            
            let and: String
            if octaveExp == String() || intervalExp == String() {
                and = String()
            } else {
                and = "and "
            }
            
            let preposition: String
            if intervalExp == String() && octaveExp == String() {
                preposition = "as "
            } else {
                preposition = "than "
            }
            
            let dirExp: String
            if preposition == "as " {
                dirExp = String()
            } else {
                dirExp = "\(direction) ".lowercased()
            }
            
            return "Sounds \(octaveExp)\(and)\(intervalExp)\(dirExp)\(preposition)written"
        }
        
        static let pickerView: [[String]] = [
            [Direction.lower.rawValue,
             Direction.higher.rawValue
            ],
            addOctaveSuffix(numArray(0, max: 2)),
            [Quality.diminished.rawValue,
             Quality.major.rawValue,
             Quality.perfect.rawValue,
             Quality.minor.rawValue,
             Quality.augmented.rawValue
            ],
            [Interval.unison.rawValue,
             Interval.second.rawValue,
             Interval.third.rawValue,
             Interval.fourth.rawValue,
             Interval.fifth.rawValue,
             Interval.sixth.rawValue,
             Interval.seventh.rawValue
            ]
        ]
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
}

