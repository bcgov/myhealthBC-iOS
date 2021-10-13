//
//  Resource.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-10-11.
//

import UIKit

struct ResourceDataSource: Equatable {
    enum CellType: Equatable {
        case text(type: TextCellType, font: UIFont), resource(type: Resource)
    }
    
    let type: CellType
    var cellStringData: String? = nil
}

struct Resource: Equatable {
    let image: UIImage
    let text: String
    let link: String
}
