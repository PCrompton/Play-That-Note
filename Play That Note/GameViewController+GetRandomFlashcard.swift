//
//  GameViewController+GetRandomFlashcard.swift
//  Play That Note
//
//  Created by Paul Crompton on 4/16/18.
//  Copyright © 2018 Paul Crompton. All rights reserved.
//

import Foundation

extension GameViewController {
    func configureFlashcards() {
        let defaultRange = MusicSettings.Range.defaultRange(for: clef)!
        flashcards = statsModelController.fetchSavedFlashcards(for: clef, lowest: Int32(defaultRange.lowestIndex), highest: Int32(defaultRange.highestIndex))
        
        if flashcards.count == 0 {
            flashcards = statsModelController.createFlashcards(clef: clef, lowest: defaultRange.lowest, highest: defaultRange.highest)
            stack.save()
        }
        
        flashcards = statsModelController.filter(for: flashcards, range: MusicSettings.Range.range(for: clef)!, omitAccidentals: MusicSettings.Range.omitAccidentals(for: clef)!)
    }
    
    // Random Flashcard methods
    func getWeightIntervals(from flashcards: [Flashcard]) -> [Int] {
        var weightIntervals = [Int]()
        var index = 0
        for flashcard in flashcards {
            if index == 0 {
                weightIntervals.append(flashcard.weight)
            } else {
                weightIntervals.append(flashcard.weight + weightIntervals[index-1])
            }
            index += 1
        }
        return weightIntervals
    }
    
    func getFlashcardIndex(from weightIntervals: [Int]) -> Int? {
        let randomNumber = Int(arc4random_uniform(UInt32(weightIntervals.last!))) //gets random Int between 0 and number passed in
        var index = 0
        for interval in weightIntervals {
            if randomNumber <= interval {
                return index
            }
            index += 1
        }
        return nil
    }
    
    func startActivityIndicator() {
        DispatchQueue.main.async {
           self.flashCardActivityIndicator.startAnimating()
        }
    }
    
    func stopActivityIndicator() {
        DispatchQueue.main.async {
            self.flashCardActivityIndicator.stopAnimating()
        }
    }
    
    func getRandomflashcard() -> Flashcard {
        
        let weightIntervals = getWeightIntervals(from: flashcards)
        let index = getFlashcardIndex(from: weightIntervals)!
        let flashcard = flashcards[index]
        if flashcard === self.flashcard {
            return getRandomflashcard()
        }
       
        return flashcard
    }
}
