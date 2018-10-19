//
//  Sections.swift
//  Houses-Vellori
//
//  Created by André Vellori on 17/10/2018.
//  Copyright © 2018 André Vellori. All rights reserved.
//

import Foundation
import UIKit

@objc protocol SectionSelectorDelegate: class {
    func didSelect(listType: ListType)
}

class SectionsSelector: NSObject {
    let sections = [
        Section(name: "Order A->Z", listType: .alphabetical),
        Section(name: "Order Z->A", listType: .length),
        Section(name: "See my beLoved", listType: .loved)
    ]
    
    
    @IBOutlet weak var delegate: SectionSelectorDelegate?
    
    @IBOutlet var stackView: UIStackView! {
        didSet {
            setup(stackView)
        }
    }
    
    func setup(_ stackView: UIStackView) {
        for (index, section) in sections.enumerated() {
            let button = UIButton(type: .custom)
            button.setTitle(section.name, for: .normal)
            button.setTitleColor(UIColor.black, for: .normal)
            button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)
            button.tag = index
            button.addTarget(self, action: #selector(newSection(_:)), for: .touchUpInside)
            stackView.addArrangedSubview(button)
        }
    }
    
    @objc func newSection(_ sender: UIView) {
        delegate?.didSelect(listType: sections[sender.tag].listType)
    }
}

struct Section {
    let name: String
    let listType: ListType
}



