//
//  MockDataGeneration.swift
//  Houses-Vellori
//
//  Created by André Vellori on 17/10/2018.
//  Copyright © 2018 André Vellori. All rights reserved.
//

import Foundation
import CoreData

/// Create some mock data. Here are a few assumptions:
/// We could fetch related words, but then I wouldn't know what to show in the description.. so that's why I don't fetch them in the detail controller
/// I cache some related words for performance reasons, assuming they are sorted already
/// The context is saved every time a new letter is faced
class MockDataGeneration {
    func create() {
        DispatchQueue.global().async {
            self.performCreation()
        }
    }
    
    private func performCreation() {
        guard let path = Bundle.main.path(forResource: "somedata", ofType: "txt") else {
            fatalError()
        }
        let context = CoreData.newContext()
        do {
            let data = try String(contentsOfFile: path, encoding: .utf8)
            let words = data.components(separatedBy: .newlines)
            var letterCache = [String: [String]]()
            for word in words where word.count > 0 {
                let object = House(context: context)
                object.shortName = "\(word)"
                object.title = "\"\(word)\" has \(word.count) letters"
                if let firstChar = word.first {
                    let firstLetter = String(firstChar).lowercased()
                    if letterCache[firstLetter] == nil {
                        letterCache.removeAll()
                        letterCache[firstLetter] = words.filter({ (word) -> Bool in
                            return word.lowercased().hasPrefix(firstLetter)
                        })
                    }
                    let relatedWords = letterCache[firstLetter]?.filter({ (rword) -> Bool in
                        return word != rword
                    })
                    object.desc = "Other words starting with \"\(firstLetter)\" are: \n" + (relatedWords?.joined(separator: "\n") ?? "None")
                } else {
                    object.desc = "You picked an interesting, and truly unique, word."
                }
            }
        } catch {
            assertionFailure("oooh maaan")
        }
        try? context.save()
        print("Data Loaded")
    }
}
