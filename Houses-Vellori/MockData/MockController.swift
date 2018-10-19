//
//  MockController.swift
//  Houses-Vellori
//
//  Created by André Vellori on 17/10/2018.
//  Copyright © 2018 André Vellori. All rights reserved.
//

import Foundation
import CoreData

class MockController {
    var isDatabasePresent: Bool {
        get {
            let viewContext = CoreData.viewContext
            let fetch: NSFetchRequest<House> = House.fetchRequest()
            let count = try? viewContext.count(for: fetch)
            print("\(count ?? 0) in store")
            return count ?? 0 > 0
        }
    }
    
    func createDatabaseIfNeeded() {
        guard !isDatabasePresent else {
            return
        }
        print("Db creation in progress...")
        MockDataGeneration().create()
    }
}
