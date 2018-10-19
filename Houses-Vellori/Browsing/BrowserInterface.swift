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

enum CellType: String, CaseIterable {
    case grid = "HouseCell"
    case wide = "HzHouseCell"
    
    var aspectRatio: CGFloat {
        return self == .grid ? 1 : 3
    }
    
    var columns: CGFloat {
        return self == .grid ? 3 : 1
    }
}

@objc enum ListType: Int {
    case alphabetical
    case length
    case loved
}

class BrowserInterface: UICollectionViewController {
    
    var searchTerm: String?
    var cellType = CellType.grid
    var listType: ListType = .alphabetical
    
    var fetchedResultController: NSFetchedResultsController<House>? {
        didSet {
            fetchedResultController?.delegate = self
            try? fetchedResultController?.performFetch()
            items = self.fetchedResultController?.fetchedObjects
            collectionView.reloadData()
        }
    }
    
    var items: [House]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        start()
    }
    
    func start() {
        collectionViewLayout.invalidateLayout()
        let fetch: NSFetchRequest<House>!
        switch  listType {
        case .alphabetical:
            fetch = AlphabeticalFetch(searchTerm: searchTerm).fetchRequest()
        case .length:
            fetch = CounterAlphabeticalFetch(searchTerm: searchTerm).fetchRequest()
        case .loved:
            fetch = LovedFetch(searchTerm: searchTerm).fetchRequest()
        }
        fetchedResultController = NSFetchedResultsController(fetchRequest: fetch,
                                                             managedObjectContext: CoreData.viewContext,
                                                             sectionNameKeyPath: nil,
                                                             cacheName: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let selectedIndex = collectionView.indexPathsForSelectedItems?.first,
            let selectedHouse = items?[selectedIndex.row] else {
                assertionFailure()
                return
        }
        if let detail = segue.destination as? DetailViewController {
            detail.house = selectedHouse
        }
    }
}

extension BrowserInterface: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        items = self.fetchedResultController?.fetchedObjects
        collectionView.reloadData()
    }
}

extension Array where Array.Element == () -> () {
    func executeAll() {
        for block in self {
            block()
        }
    }
}

extension BrowserInterface {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items?.count ?? 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellType.rawValue, for: indexPath) as! HouseCell
        let data: House? = fetchedResultController?.fetchedObjects?[indexPath.row]
        cell.update(object: data)
        assert(data != nil)
        return cell
    }
}

extension BrowserInterface: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width/cellType.columns,
                      height: collectionView.frame.size.width/cellType.columns/cellType.aspectRatio)
    }
}


class HouseCell: UICollectionViewCell {
    @IBOutlet var shortName: UILabel!
    @IBOutlet var loveSight: UIView!
    
    func update(object: House?) {
        shortName.text = object?.shortName ?? ""
        loveSight.isHidden = object?.loved == false
    }
}


extension BrowserInterface {
    func toggleGrid() {
        let allCases = CellType.allCases
        let nextIndex = (allCases.firstIndex(of: cellType) ?? 0) + 1
        cellType = allCases.indices.contains(nextIndex) ? allCases[nextIndex] : allCases[0]
    }
    
    /// Update or remove search term
    ///
    /// - Parameter term: remove if nil
    func updateSearchTerm(with term: String?) {
        searchTerm = term
    }
    
    func restart() {
        start()
        collectionView.reloadData()
    }
}

struct MainBlock {
    var block: () -> ()
    func operation() -> Operation {
        return BlockOperation(block: {
            DispatchQueue.main.sync {
                self.block()
            }
        })
    }
}

extension BrowserInterface: SectionSelectorDelegate {
    func didSelect(listType: ListType) {
        self.listType = listType
        restart()
    }
}

struct AlphabeticalFetch {
    var searchTerm: String?
    
    func fetchRequest() -> NSFetchRequest<House> {
        let fetch: NSFetchRequest<House> = House.fetchRequest()
        let sort = NSSortDescriptor(key: #keyPath(House.shortName), ascending: true, selector: #selector(NSString.localizedCaseInsensitiveCompare(_:)))
        fetch.sortDescriptors = [sort]
        if let searchTerm = searchTerm {
            let predicate = NSPredicate(format: "title desc contains[cd] %@", searchTerm)
            fetch.predicate = predicate
        }
        return fetch
    }
}

struct CounterAlphabeticalFetch {
    var searchTerm: String?
    
    func fetchRequest() -> NSFetchRequest<House> {
        let fetch: NSFetchRequest<House> = House.fetchRequest()
        let sort = NSSortDescriptor(key: #keyPath(House.shortName), ascending: false, selector: #selector(NSString.localizedCaseInsensitiveCompare(_:)))
        fetch.sortDescriptors = [sort]
        if let searchTerm = searchTerm {
            let predicate = NSPredicate(format: "title desc contains[cd] %@", searchTerm)
            fetch.predicate = predicate
        }
        return fetch
    }
}

struct LovedFetch {
    var searchTerm: String?
    
    func fetchRequest() -> NSFetchRequest<House> {
        let fetch: NSFetchRequest<House> = House.fetchRequest()
        let sort = NSSortDescriptor(key: #keyPath(House.shortName), ascending: true, selector: #selector(NSString.localizedCaseInsensitiveCompare(_:)))
        
        fetch.sortDescriptors = [sort]
        var mpredicate = [NSPredicate]()
        if let searchTerm = searchTerm {
            let predicate = NSPredicate(format: "title desc contains[cd] %@", searchTerm)
            mpredicate.append(predicate)
        }
        mpredicate.append(NSPredicate(format: "loved == YES"))
        fetch.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: mpredicate)
        
        return fetch
    }
}
