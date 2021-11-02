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
//        static func == (lhs: FormDataSource.CellType, rhs: FormDataSource.CellType) -> Bool {
//            switch (lhs, rhs) {
//            case (let .text(lhsType, _), let .text(rhsType, _)):
//                return (lhsType) == (rhsType)
//            case (let .form(lhsType), let .form(rhsType)):
//                return (lhsType) == (rhsType)
//            case (let .clickableText(lhsLinkedStrings), let .clickableText(rhsLinkedStrings)):
//                return (lhsLinkedStrings) == (rhsLinkedStrings)
//            default:
//                return false
//            }
//        }
        case text(type: TextCellType, font: UIFont)
        case form(type: FormTextFieldType)
        case clickableText(text: String, linkedStrings: [LinkedStrings])
    }
    
    let type: CellType
    var cellStringData: String?
    
    func isTextField() -> Bool {
        switch type {
        case .text: return false
        case .form: return true
        case .clickableText: return false
        }
    }
    
    func transform() -> TextFieldData? {
        switch self.type {
        case .text: return nil
        case .form(type: let type):
            return TextFieldData(type: type, text: self.cellStringData)
        case .clickableText: return nil
        }
    }
}

struct TextFieldData: Equatable {
    let type: FormTextFieldType
    let text: String?
}

