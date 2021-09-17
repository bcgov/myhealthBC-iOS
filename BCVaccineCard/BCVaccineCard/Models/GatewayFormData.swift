//
//  GatewayFormData.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-09-17.
//

import UIKit

struct GatewayFormData {
    enum CellType {
        case text(type: TextCellType), form(type: FormTableViewCellField)
    }
    
    let type: CellType
    var cellStringData: String?
    var isFormDataValid: Bool? = nil
}

