//
//  Stats.swift
//  Play That Note
//
//  Created by Paul Crompton on 11/23/16.
//  Copyright © 2016 Paul Crompton. All rights reserved.
//

import Foundation
import CoreData
import UIKit

struct Stats {
    
    var flashcards: [Flashcard]
    
    var correct: Int {
        get {
            var result = 0
            for flashcard in flashcards {
                result += Int(flashcard.correct)
            }
            return result
        }
    }
    
    var incorrect: Int {
        get {
            var result = 0
            for flashcard in flashcards {
                result += Int(flashcard.incorrect)
            }
            return result
        }
    }
    
    var plusMinus: Int {
        get {
            return correct - incorrect
        }
    }
    
    var totalTries: Int {
        get {
            return correct + incorrect
        }
    }
    
    var percentage: Double? {
        get {
            if totalTries == 0 {
                return nil
            } else {
                return Double(correct)/Double(totalTries) * 100
            }
        }
    }
}
