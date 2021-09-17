//
//  GatewayFormData.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-09-17.
//

import UIKit

struct GatewayFormData: Equatable {
    enum CellType: Equatable {
        case text(type: TextCellType), form(type: FormTableViewCellField)
    }
    
    let type: CellType
    var cellStringData: String?
}

