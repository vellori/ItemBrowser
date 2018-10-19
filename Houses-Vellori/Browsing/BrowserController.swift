//
//  BrowsingController.swift
//  Houses-Vellori
//
//  Created by André Vellori on 17/10/2018.
//  Copyright © 2018 André Vellori. All rights reserved.
//

import Foundation
import UIKit

class BrowsingController: UIViewController {
    var browserInterface: BrowserInterface!
    @IBOutlet weak var sectionSelector: SectionsSelector!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let browserInterface = segue.destination as? BrowserInterface {
                self.browserInterface = browserInterface
        }
        if let sectionDelegate = segue.destination as? SectionSelectorDelegate {
            sectionSelector.delegate = sectionDelegate
        }
    }
    
    @IBAction func toggleGrid() {
        browserInterface.toggleGrid()
        browserInterface.restart()
    }
    
}
