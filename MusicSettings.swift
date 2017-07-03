//
//  MusicSettings.swift
//  Play That Note
//
//  Created by Paul Crompton on 7/1/17.
//  Copyright © 2017 Paul Crompton. All rights reserved.
//

import Foundation
import Pitchy
struct MusicSettings {

    struct Transpose {
        struct Defaults {
            static var direction = Direction.lower
            static var octave = 0
            static var quality = Quality.perfect
            static let interval = Interval.unison
        }
        
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
        
        static var direction: Direction = Defaults.direction {
            didSet {
                UserDefaults.standard.set(direction.rawValue, forKey: "direction")
            }
        }
        static var octave: Int = Defaults.octave {
            didSet {
                UserDefaults.standard.set(octave, forKey: "octave")
            }
        }
        static var quality: Quality = Defaults.quality {
            didSet {
                UserDefaults.standard.set(quality.rawValue, forKey: "quality")
            }
        }
        static var interval: Interval = Defaults.interval {
            didSet {
                UserDefaults.standard.set(interval.rawValue, forKey: "interval")
            }
        }
        
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
        static func resetToDefaults() {
            direction = Defaults.direction
            octave = Defaults.octave
            quality = Defaults.quality
            interval = Defaults.interval
        }
    }
    
    struct Range {
        struct ClefRange {
            let clef: Clef
            var lowest: Note {
                return try! Note(index: lowestIndex)
            }
            var highest: Note {
                return try! Note(index: highestIndex)
            }
            
            let lowestIndex: Int
            let highestIndex: Int
        }
        
        struct Defaults {
            static var treble = ClefRange(clef: .treble, lowestIndex: try! Note(letter: .F, octave: 3).index, highestIndex: try! Note(letter: .E, octave: 6).index)
            static var bass = ClefRange(clef: .bass, lowestIndex: try! Note(letter: .A, octave: 1).index, highestIndex: try! Note(letter: .G, octave: 4).index)
            static var alto = ClefRange(clef: .alto, lowestIndex: try! Note(letter: .G, octave: 2).index, highestIndex: try! Note(letter: .F, octave: 5).index)
            static let tenor = ClefRange(clef: .tenor, lowestIndex: try! Note(letter: .E, octave: 2).index, highestIndex: try! Note(letter: .D, octave: 5).index)
        }
        
        static var treble = Defaults.treble
        static var bass = Defaults.bass
        static var alto = Defaults.alto
        static var tenor = Defaults.tenor
        
        static func description(for clef: Clef) -> String {
            switch clef {
            case .treble:
                return "\(treble.lowest.string) to \(treble.highest.string)"
            case .bass:
                return "\(bass.lowest.string) to \(bass.highest.string)"
            case .alto:
                return "\(alto.lowest.string) to \(alto.highest.string)"
            case .tenor:
                return "\(tenor.lowest.string) to \(tenor.highest.string)"
            default:
                return String()
            }
        }
        
        static func set(for clef: Clef, lowest: Int, highest: Int) {
            let range = ClefRange(clef: clef, lowestIndex: lowest, highestIndex: highest)
            switch clef {
            case .treble:
                treble = range
            case .bass:
                bass = range
            case .alto:
                alto = range
            case .tenor:
                tenor = range
            default:
                break
            }
        }
        
        static func range(for clef: Clef) -> ClefRange? {
            switch clef {
            case .treble:
                return treble
            case .bass:
                return bass
            case .alto:
                return alto
            case .tenor:
                return tenor
            default:
                return nil
            }
        }
        
        static func pickerView(for clef: Clef) -> [[Int]] {
             var rangeArray = [Int]()
            let range: ClefRange?
            switch clef {
            case .treble:
                range = Defaults.treble
            case .bass:
                range = Defaults.bass
            case .alto:
                range = Defaults.alto
            case .tenor:
                range = Defaults.tenor
            default:
                return [rangeArray, rangeArray]
            }
            let lowest = range!.lowest.index
            let highest = range!.highest.index
            var i = lowest
            while i <= highest {
                rangeArray.append(i)
                i += 1
            }
            var lowArray = rangeArray
            var highArray = rangeArray
            
            lowArray.removeLast()
            highArray.removeFirst()
            
            return [lowArray, highArray]
        }
        
        static func resetToDefaults() {
            Range.treble = Defaults.treble
            Range.bass = Defaults.bass
            Range.alto = Defaults.alto
            Range.tenor = Defaults.tenor
        }
        
    }
}

