//
//  ClefStatsViewController.swift
//  Play That Note
//
//  Created by Paul Crompton on 11/19/16.
//  Copyright © 2016 Paul Crompton. All rights reserved.
//

import UIKit
import CoreData

class ClefStatsViewController: CoreDataViewController, UITableViewDataSource, UITableViewDelegate {

    var flashcards: [Flashcard]? {
        didSet {
            tableView.reloadData()
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchStoredFlashcards()
    }
    
    func fetchStoredFlashcards() {
        let fetchRequst = NSFetchRequest<NSManagedObject>(entityName: "Flashcard")
        fetchRequst.sortDescriptors = [NSSortDescriptor(key: "clef", ascending: true), NSSortDescriptor(key: "pitchIndex", ascending: true)]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequst, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController?.delegate = self
        executeSearch()
        
        flashcards = fetchedResultsController?.fetchedObjects as? [Flashcard]
    }
    
    func getStats(for clef: Clef) -> (Int, Int) {
        var correct = 0
        var incorrect = 0
        if let flashcards = flashcards {
            for flashcard in flashcards {
                if clef.rawValue == flashcard.clef {
                    correct += Int(flashcard.correct)
                    incorrect += Int(flashcard.incorrect)
                }
            }
        }
        return (correct, incorrect)
    }
    
    func getFlashcards(for clef: Clef) -> [Flashcard] {
        var flashcardsForClef = [Flashcard]()
        if let flashcards = flashcards {
            for flashcard in flashcards {
                if let flashcardClef = flashcard.clef {
                    if flashcardClef == clef.rawValue {
                        flashcardsForClef.append(flashcard)
                    }
                }
            }
        }
        return flashcardsForClef
    }
    
    
    @IBAction func doneButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ClefCell") as? ClefTableViewCell else {
            fatalError("Unable to instantiate cell")
        }
       
        switch indexPath.row {
        case 0:
            cell.clef = Clef.treble
        case 1:
            cell.clef = Clef.bass
        case 2:
            cell.clef = Clef.alto
        case 3:
            cell.clef = Clef.tenor
        default:
            cell.clef = nil
        }
        if let clef = cell.clef {
            cell.textLabel?.text = "\(clef.rawValue.capitalized) Clef"
            let stats = getStats(for: clef)
            let percentage: Double
            if (stats.0 + stats.1) != 0 {
                percentage = Double(stats.0)/Double(stats.0 + stats.1)*100
            } else {
                percentage = 0.0
            }
            cell.detailTextLabel?.text = "\(Int(percentage))%"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let statsVC = storyboard?.instantiateViewController(withIdentifier: "StatsViewController") as! StatsViewController
        let cell = tableView.cellForRow(at: indexPath) as! ClefTableViewCell
        if let clef = cell.clef {
            statsVC.clef = clef
            statsVC.flashcards = getFlashcards(for: clef)
            show(statsVC, sender: self)
        }
    }
}
