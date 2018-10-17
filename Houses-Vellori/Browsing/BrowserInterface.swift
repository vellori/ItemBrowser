//
//  BrowserController.swift
//  Houses-Vellori
//
//  Created by André Vellori on 17/10/2018.
//  Copyright © 2018 André Vellori. All rights reserved.
//

import Foundation
import CoreData
import UIKit

enum CellType: String {
    case grid = "HouseCell"
    case wide = "HzHouseCell"
}

class BrowserController: UICollectionViewController {
    
    var searchTerm: String?
    var cellType = CellType.grid
    
    
    var fetchedResultController: NSFetchedResultsController<House>? {
        didSet {
            fetchedResultController?.delegate = self
            try? fetchedResultController?.performFetch()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        start()
    }
    
    func start() {
        let fetch: NSFetchRequest<House> = House.fetchRequest()
        let sort = NSSortDescriptor(key: #keyPath(House.shortName), ascending: true)
        fetch.sortDescriptors = [sort]
        fetchedResultController = NSFetchedResultsController(fetchRequest: fetch,
                                                             managedObjectContext: CoreData.viewContext,
                                                             sectionNameKeyPath: nil,
                                                             cacheName: nil)
    }
}

extension BrowserController: NSFetchedResultsControllerDelegate {
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultController?.fetchedObjects?.count ?? 0
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        // We could animate the changes
        collectionView.reloadData()
    }
}

extension BrowserController {
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellType.rawValue, for: indexPath) as! HouseCell
        let data: House? = fetchedResultController?.fetchedObjects?[indexPath.row]
        cell.update(object: data)
        assert(data != nil)
        return cell
    }
}


class HouseCell: UICollectionViewCell {
    @IBOutlet var shortName: UILabel!
    
    func update(object: House?) {
        shortName.text = object?.shortName ?? ""
    }
}
