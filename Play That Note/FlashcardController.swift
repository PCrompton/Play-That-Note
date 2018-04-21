//
//  FlashcardController.swift
//  Play That Note
//
//  Created by Paul Crompton on 4/19/18.
//  Copyright © 2018 Paul Crompton. All rights reserved.
//

import UIKit
import CoreData

class FlashcardController: CoreDataController {

    static var flashcards: [Flashcard]?
    
    var fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Flashcard")
    
    static let shared = FlashcardController(fetchedResultsController: NSFetchedResultsController<NSManagedObject>())
    
    
}
