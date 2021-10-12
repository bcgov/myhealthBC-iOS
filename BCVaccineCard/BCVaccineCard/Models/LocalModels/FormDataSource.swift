//
//  GatewayFormData.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-09-17.
//

import UIKit

// MARK: This model is for the table view data source of the gateway screen
struct FormDataSource: Equatable {
    enum CellType: Equatable {
        case text(type: TextCellType, font: UIFont), form(type: FormTextFieldType)
    }
    
    let type: CellType
    var cellStringData: String?
    
    func isTextField() -> Bool {
        switch type {
        case .text: return false
        case .form: return true
        }
    }
    
    func transform() -> TextFieldData? {
        switch self.type {
        case .text: return nil
        case .form(type: let type):
            return TextFieldData(type: type, text: self.cellStringData)
        }
    }
}

struct TextFieldData: Equatable {
    let type: FormTextFieldType
    let text: String?
}

