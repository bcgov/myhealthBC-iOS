//
//  Setting.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-09-20.
//

import UIKit

struct Setting {
    enum CellType {
        case text(text: String),
             privacy(text: String, image: UIImage),
             analytics(title: String, subtitle: String, isOn: Bool)
    }
    let cell: CellType
    let isClickable: Bool
}
