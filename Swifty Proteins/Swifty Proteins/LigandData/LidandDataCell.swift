//
//  LidandDataCell.swift
//  Swifty Proteins
//
//  Created by Nikolay Zhurba on 11.02.2020.
//  Copyright © 2020 mzhurba. All rights reserved.
//

import UIKit

class LidandDataCell: UITableViewCell {
    @IBOutlet private weak var propertyName: UILabel!
    @IBOutlet private weak var propertyValue: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    var property: (name: String?, value: String?) {
        get {
            return (propertyName.text, propertyValue.text)
        }
        set {
            propertyName.text = newValue.name
            propertyValue.text = newValue.value
            guard newValue.name == "Formula", let text = newValue.value else {
                return
            }
            propertyValue.setAttributedTextWithSubscripts(text: text, indicesOfSubscripts: text.indicesOfNumbers)
        }
    }

}
