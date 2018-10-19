//
//  Detail.swift
//  Houses-Vellori
//
//  Created by André Vellori on 18/10/2018.
//  Copyright © 2018 André Vellori. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class DetailViewController: UIViewController {
    @IBOutlet weak var stackView: UIStackView!
    var observation: NSKeyValueObservation?
    
    var house: House! {
        didSet {
            observation = house.observe(\.loved) { (object, change) in
                self.setup()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    func setup() {
        guard let house = house else {
            assertionFailure("Forgot something?")
            return
        }
        for view in stackView.arrangedSubviews {
            view.removeFromSuperview()
        }
        title = house.shortName
        stackView.addArrangedSubview(UILabel.labelWithText(text: house.title!))
        
        let button = UIButton(type: .custom)
        button.setTitle(LoveLabel(house: house).getLabel(), for: .normal)
        stackView.addArrangedSubview(button)
        button.setTitleColor(UIColor.black, for: .normal)
        button.addTarget(self, action: #selector(love), for: .touchUpInside)
        
        stackView.addArrangedSubview(UILabel.labelWithText(text: house.desc!))
    }
    
    @objc func love() {
        guard let house = house else {
            return
        }
        let context = CoreData.newContext()
        guard let someHouse = try? context.existingObject(with: house.objectID) as? House else {
            return
        }
        someHouse?.loved.toggle()
        try? context.save()
    }
}

private extension UILabel {
    static func labelWithText(text: String) -> UILabel {
        let label = UILabel(frame: CGRect.zero)
        label.text = text
        label.numberOfLines = 0
        return label
    }
}

struct LoveLabel {
    var house: House
    
    func getLabel() -> String {
        return house.loved ? "No more love 💔" : "I ❤️ it"
    }
}
