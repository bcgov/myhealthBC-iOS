//
//  TextTag.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2023-07-11.
//

import UIKit

class TextTag: UIView {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var container: UIView!
    
    
    func configure(text: String, fontSize: Double) {
        self.translatesAutoresizingMaskIntoConstraints = false
//        self.heightAnchor.constraint(equalToConstant: 24).isActive = true
//        self.widthAnchor.constraint(equalToConstant: 120).isActive = true
        label.text = text
        style(fontSize: fontSize)
    }
    
    func style(fontSize: Double) {
        container.layer.cornerRadius = 4
        label.textColor = AppColours.appBlue
        label.font = UIFont.bcSansBoldWithSize(size: fontSize)
        container.backgroundColor = UIColor(red: 0.914, green: 0.925, blue: 0.937, alpha: 1)
    }

}
