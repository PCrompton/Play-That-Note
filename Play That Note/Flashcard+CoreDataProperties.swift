//
//  Flashcard+CoreDataProperties.swift
//  Play That Note
//
//  Created by Paul Crompton on 11/16/16.
//  Copyright © 2016 Paul Crompton. All rights reserved.
//

import Foundation
import CoreData


extension Flashcard {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Flashcard> {
        return NSFetchRequest<Flashcard>(entityName: "Flashcard");
    }

    @NSManaged public var note: String?
    @NSManaged public var pitchIndex: Int32
    @NSManaged public var correct: Int32
    @NSManaged public var incorrect: Int32
    @NSManaged public var clef: String?

}
