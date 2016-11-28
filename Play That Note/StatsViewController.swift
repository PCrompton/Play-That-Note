//
//  StatsViewController.swift
//  Play That Note
//
//  Created by Paul Crompton on 11/18/16.
//  Copyright © 2016 Paul Crompton. All rights reserved.
//

import UIKit
import CoreData

class StatsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: Properties
    var clef: Clef?
    var flashcards: [Flashcard]?
    var statsModelController = StatsModelController()
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Lifecycle Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        if let clef = clef {
            flashcards = statsModelController.fetchSavedFlashcards(for: clef, lowest: nil, highest: nil)
        } else {
            flashcards = statsModelController.fetchSavedFlashcards(with: nil)
        }
    }
    
    // MARK: IBActions
    @IBAction func doneButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: UITableViewDataSource Functions
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let flashcards = flashcards {
            return flashcards.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StatsCell") as! ClefTableViewCell
        guard let flashcards = flashcards else {
            print("no flashcards found")
            return cell
        }
        let flashcard = flashcards[indexPath.row]
        cell.clef = flashcard.clef.map { Clef(rawValue: $0) }!
        cell.textLabel?.text = "\(flashcard.clef!.capitalized) Clef, \(flashcard.note!)"
        cell.detailTextLabel?.text = "\(Int(flashcard.percentage))%"
        return cell
    }
    
    // MARK: TableViewDelegate Functions
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let flashcardVC = storyboard?.instantiateViewController(withIdentifier: "FlashcardViewController") as! FlashcardViewController
        flashcardVC.flashcard = flashcards?[indexPath.row]
        flashcardVC.clef = (tableView.cellForRow(at: indexPath) as! ClefTableViewCell).clef!
        show(flashcardVC, sender: self)
    }
}
