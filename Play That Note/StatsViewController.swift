//
//  StatsViewController.swift
//  Play That Note
//
//  Created by Paul Crompton on 11/18/16.
//  Copyright © 2016 Paul Crompton. All rights reserved.
//

import UIKit
import CoreData

class StatsViewController: CoreDataViewController, UITableViewDelegate, UITableViewDataSource {

    var flashcards: [Flashcard]?
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchStoredFlashcards()
    }
    
    func fetchStoredFlashcards() {
        let fetchRequst = NSFetchRequest<NSManagedObject>(entityName: "Flashcard")
        fetchRequst.sortDescriptors = [NSSortDescriptor(key: "pitchIndex", ascending: true)]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequst, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController?.delegate = self
        executeSearch()
        
        flashcards = fetchedResultsController?.fetchedObjects as? [Flashcard]
    }
    
    @IBAction func doneButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let flashcards = flashcards {
            return flashcards.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StatsCell")
        guard let flashcards = flashcards else {
            print("no flashcards found")
            return cell!
        }
        let flashcard = flashcards[indexPath.row]
        cell?.textLabel?.text = "\(flashcard.clef!.capitalized) Clef, \(flashcard.note!)"
        cell?.detailTextLabel?.text = "\(Int(flashcard.percentage))%"
        return cell!
    }

}
