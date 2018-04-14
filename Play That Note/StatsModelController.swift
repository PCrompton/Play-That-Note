//
//  StatsModelController.swift
//  Play That Note
//
//  Created by Paul Crompton on 11/25/16.
//  Copyright © 2016 Paul Crompton. All rights reserved.
//

import Foundation
import CoreData
import UIKit
import Pitchy

class StatsModelController {
    let stack = (UIApplication.shared.delegate as! AppDelegate).stack
    var fetchedResultsController: NSFetchedResultsController<NSManagedObject>?
    
    // MARK: CoreData Functions
    func fetchSavedFlashcards(with predicates: [NSPredicate]?) -> [Flashcard] {
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
    
    func fetchSavedFlashcards(for clef: Clef, lowest: Int32?, highest: Int32?) -> [Flashcard] {
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
    
    
    func executeSearch() {
        if let fc = fetchedResultsController {
            do {
                try fc.performFetch()
            } catch let e as NSError{
                fatalError("Fetch Request Failed with Error: \(e)")
            }
        }
    }
    
    func createFlashcards(clef: Clef, lowest: Note, highest: Note) -> [Flashcard] {
        var flashcards = [Flashcard]()
        for i in lowest.index...highest.index {
            let note = try! Note(index: i)
            let flashcard = Flashcard(with: clef, note: note.string, pitchIndex: Int32(i), insertInto: stack.context)
            flashcards.append(flashcard)
            if note.letter.rawValue.count == 1 {
                if note.letter != .C && note.letter != .F {
                    let flatFlashcard = Flashcard(with: clef, note: "\(note.letter.rawValue)b\(note.octave)", pitchIndex: Int32(i-1), insertInto: stack.context)
                    flashcards.append(flatFlashcard)
                }
            }
        }
        return flashcards
    }
    
    func filter(for flashcards: [Flashcard], range: MusicSettings.Range.ClefRange, omitAccidentals: Bool) -> [Flashcard] {
        var newFlashcards = [Flashcard]()
        for flashcard in flashcards {
            let pitchIndex = Int(flashcard.pitchIndex)
            if pitchIndex >= range.lowestIndex
                && pitchIndex <= range.highestIndex {
                if omitAccidentals && (flashcard.note?.count)! > 2 {
                    continue
                } else {
                    newFlashcards.append(flashcard)
                }
            }
        }
        return newFlashcards
    }
    
    func deleteAllFlashcards() {
        let flashcards = fetchSavedFlashcards(with: nil)
        stack.delete(objects: flashcards)
    }
    
    // MARK: Stats functions
    func getStatsTotals() -> Stats {
        let flashcards = fetchSavedFlashcards(with: nil)
        return getStats(for: flashcards)
    }
    
    func getStats(for flashcards: [Flashcard]) -> Stats {
        return Stats(flashcards: flashcards)
    }
    
    func getStats(for clef: Clef, lowest: Int32?, highest: Int32?) -> Stats {
        let flashcards = fetchSavedFlashcards(for: clef, lowest: lowest, highest: highest)
        return getStats(for: flashcards)
    }
}
