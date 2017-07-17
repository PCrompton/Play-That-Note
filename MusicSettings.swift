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
    
    static var productID = "com.playThatNote.transposition_range"
    
    static var isUnlocked: Bool {
        if let isUnlocked = UserDefaults.standard.value(forKey: MusicSettings.productID) as? Bool {
            return isUnlocked
        } else {
            return false
        }
    }

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
        
        static var trebleOmitAccidentals = false {
            didSet {
                UserDefaults.standard.set(trebleOmitAccidentals, forKey: "trebleOmitAccidentals")
            }
        }
        static var bassOmitAccidentals = false {
            didSet {
                UserDefaults.standard.set(bassOmitAccidentals, forKey: "bassOmitAccidentals")
            }
        }
        static var altoOmitAccidentals = false {
            didSet {
                UserDefaults.standard.set(altoOmitAccidentals, forKey: "altoOmitAccidentals")
            }
        }
        static var tenorOmitAccidentals = false {
            didSet {
                UserDefaults.standard.set(tenorOmitAccidentals, forKey: "tenorOmitAccidentals")
            }
        }
        
        static var treble = Defaults.treble {
            didSet {
                UserDefaults.standard.set([treble.lowestIndex, treble.highestIndex], forKey: "trebleRange")
            }
        }
        static var bass = Defaults.bass {
            didSet {
                UserDefaults.standard.set([bass.lowestIndex, bass.highestIndex], forKey: "bassRange")
            }
        }
        static var alto = Defaults.alto {
            didSet {
                UserDefaults.standard.set([alto.lowestIndex, alto.highestIndex], forKey: "altoRange")
            }
        }
        static var tenor = Defaults.tenor {
            didSet {
                UserDefaults.standard.set([tenor.lowestIndex, tenor.highestIndex], forKey: "tenorRange")
            }
        }
        
        static func omitAccidentals(for clef: Clef) -> Bool? {
            switch clef {
            case .treble:
                return trebleOmitAccidentals
            case .bass:
                return bassOmitAccidentals
            case .alto:
                return altoOmitAccidentals
            case .tenor:
                return tenorOmitAccidentals
            default:
                return nil
            }
        }
        
        static func omitAccidentals(for clef: Clef, bool: Bool) {
            switch clef {
            case .treble:
                trebleOmitAccidentals = bool
            case .bass:
                bassOmitAccidentals = bool
            case .alto:
                altoOmitAccidentals = bool
            case .tenor:
                tenorOmitAccidentals = bool
            default:
                break
            }
        }
        
        static func description(for clef: Clef) -> String {
            var description = String()
            switch clef {
            case .treble:
                description = "\(treble.lowest.string) to \(treble.highest.string)"
            case .bass:
                description = "\(bass.lowest.string) to \(bass.highest.string)"
            case .alto:
                description = "\(alto.lowest.string) to \(alto.highest.string)"
            case .tenor:
                description = "\(tenor.lowest.string) to \(tenor.highest.string)"
            default:
                break
            }
            
            guard let omitAccidentals = omitAccidentals(for: clef) else {
                return description
            }
            
            if omitAccidentals {
                description += " (omit accidentals)"
            }
            return description
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
        
        static func defaultRange(for clef: Clef) -> ClefRange? {
            switch clef {
            case .treble:
                return Defaults.treble
            case .bass:
                return Defaults.bass
            case .alto:
                return Defaults.alto
            case .tenor:
                return Defaults.tenor
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
                range = nil
            }
            guard let unwrappedRange = range,
                let omitAccidentals = omitAccidentals(for: clef) else {
                return [rangeArray, rangeArray]
            }
           
            let lowest = unwrappedRange.lowest.index
            let highest = unwrappedRange.highest.index
            var i = lowest
            while i <= highest {
            
                if omitAccidentals {
                    if try! Note(index: i).string.characters.count == 2 {
                        rangeArray.append(i)
                    }
                } else {
                    rangeArray.append(i)
                }
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
            Range.trebleOmitAccidentals = false
            Range.bass = Defaults.bass
            Range.bassOmitAccidentals = false
            Range.alto = Defaults.alto
            Range.altoOmitAccidentals = false
            Range.tenor = Defaults.tenor
            Range.tenorOmitAccidentals = false
        }
    }
}

