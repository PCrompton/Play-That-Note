//
//  Flashcard+CoreDataClass.swift
//  Play That Note
//
//  Created by Paul Crompton on 11/16/16.
//  Copyright © 2016 Paul Crompton. All rights reserved.
//

import Foundation
import CoreData

@objc(Flashcard)
public class Flashcard: NSManagedObject {
    var totalAnswered: Int {
        return Int(self.correct + self.incorrect)
    }
    var percentage: Double {
        if totalAnswered != 0 {
            return Double(correct)/Double(totalAnswered)*100
        }
        return 0.0
    }
    var plusMinus: Int {
        return self.correct - self.incorrect
    }
    
    convenience init(with clef: Clef, note: String, pitchIndex: Int32, insertInto context: NSManagedObjectContext) {
        if let ent = NSEntityDescription.entity(forEntityName: "Flashcard", in: context) {
            self.init(entity: ent, insertInto: context)
            self.clef = clef.rawValue
            self.note = note
            self.pitchIndex = pitchIndex
            self.correct = 0
            self.incorrect = 0
        } else {
            fatalError("Unable to find Entity name!")
        }
    }
}
