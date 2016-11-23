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
    static let stack = (UIApplication.shared.delegate as! AppDelegate).stack
    static var fetchedResultsController: NSFetchedResultsController<NSManagedObject>?
    
    static func fetchSavedFlashcards(with predicates: [NSPredicate]?) -> [Flashcard] {
      
        let fetchRequst = NSFetchRequest<NSManagedObject>(entityName: "Flashcard")
        fetchRequst.sortDescriptors = [NSSortDescriptor(key: "pitchIndex", ascending: true)]
        if let predicates = predicates {
            let andPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
            fetchRequst.predicate = andPredicate
        }

        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequst, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
        executeSearch()

        return fetchedResultsController?.fetchedObjects as! [Flashcard]
    }
    
    static func fetchSavedFlashcards(for clef: Clef, lowest: Int32?, highest: Int32?) -> [Flashcard] {
        var predicates = [NSPredicate]()
        let clefPredicate = NSPredicate(format: "clef = %@", argumentArray: [clef.rawValue])
        predicates.append(clefPredicate)
        if let lowest = lowest {
            let minPredicate = NSPredicate(format: "pitchIndex >= %@", argumentArray: [lowest])
            predicates.append(minPredicate)
        }
        if let highest = highest {
            let maxPredicate = NSPredicate(format: "pitchIndex <= %@", argumentArray: [highest])
            predicates.append(maxPredicate)
        }

        return fetchSavedFlashcards(with: predicates)
    }
    
    static func getStats(for flashcards: [Flashcard]) -> [String: Any?] {
        var results = [String: Any]()
        var rawStats = (0, 0)
        
        for flashcard in flashcards {
            rawStats.0 += Int(flashcard.correct)
            rawStats.1 += Int(flashcard.incorrect)
        }
        let total = rawStats.0 + rawStats.1
        
        results["correct"] = rawStats.0
        results["incorrect"] = rawStats.1
        results["totalAnswered"] = total
        results["plusMinus"] = rawStats.0 - rawStats.1
        if total != 0 {
            results["percentage"] = Double(rawStats.0/total)
        } else {
            results["percentage"] = nil
        }
        
        return results
    }
    
    private static func executeSearch() {
        if let fc = fetchedResultsController {
            do {
                try fc.performFetch()
            } catch let e as NSError{
               fatalError("Fetch Request Failed with Error: \(e)")
            }
        }
    }
}
