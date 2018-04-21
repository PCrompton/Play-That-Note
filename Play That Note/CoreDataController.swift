//
//  CoreDataController.swift
//
//  Created by Paul Crompton on 10/23/16.
//  Copyright © 2016 Paul Crompton. All rights reserved.
//

import UIKit
import CoreData

class CoreDataController: NSObject, NSFetchedResultsControllerDelegate {

    // MARK: - Properties
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var fetchedResultsController: NSFetchedResultsController<NSManagedObject>?
    
    init(fetchedResultsController: NSFetchedResultsController<NSManagedObject>) {
        self.fetchedResultsController = fetchedResultsController
        super.init()
    }
    
    func executeSearch() -> [String: String]? {
        if let fc = fetchedResultsController {
            do {
                try fc.performFetch()
            } catch let e as NSError{
                return ["title": "Fetch Request Failed", "errorMessage": e.localizedDescription]
            }
        }
        return nil
    }
    
    func save() {
        appDelegate.stack.save()
    }
    
    func deleteAllRecords(for entity: String, in context: NSManagedObjectContext) {
        
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        
        do {
            try appDelegate.stack.context.execute(deleteRequest)
        } catch {
            print ("There was an error")
        }
        save()
    }
}
