//
//  LabelWithInsets.swift
//  HotWaterWillBack
//
//  Created by Alexander Konovalov on 20.06.2021.
//

import UIKit

class LabelWithInsets: UILabel {
    
    let padding = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: padding))
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 10
    }
}
