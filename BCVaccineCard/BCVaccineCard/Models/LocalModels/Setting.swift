//
//  Setting.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-09-20.
//

import UIKit

struct Setting {
    enum CellType {
        case text(text: String), setting(text: String, image: UIImage)
    }
    let cell: CellType
    let isClickable: Bool
}
