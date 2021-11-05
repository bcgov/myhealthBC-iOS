//
//  GatewayFormData.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-09-17.
//

import UIKit

// MARK: This model is for the table view data source of the gateway screen
//struct FormDataSource: Equatable {
//    enum SpecificCell {
//        case introText
//        case phnForm
//        case dobForm
//        case dovForm
//        case rememberCheckbox
//        case clickablePrivacyPolicy
//    }
//    enum CellType: Equatable {
//        case text(type: TextCellType, font: UIFont)
//        case form(type: FormTextFieldType)
//        case checkbox(text: String)
//        case clickableText(text: String, linkedStrings: [LinkedStrings])
//    }
//
//    let type: CellType
//    var cellStringData: String?
//    let specificCell: SpecificCell
//
//    func isTextField() -> Bool {
//        switch type {
//        case .text: return false
//        case .form: return true
//        case .checkbox: return false
//        case .clickableText: return false
//        }
//    }
//
//    func transform() -> TextFieldData? {
//        switch self.type {
//        case .text: return nil
//        case .form(type: let type):
//            return TextFieldData(type: type, text: self.cellStringData)
//        case .checkbox: return nil
//        case .clickableText: return nil
//        }
//    }
//}

//struct TextFieldData: Equatable {
//    let type: FormTextFieldType
//    let text: String?
//}



struct FormData: Equatable {
    struct Configuration: Equatable {
        var text: String? = nil
        var font: UIFont? = nil
        var linkedStrings: [LinkedStrings]? = nil
        let isTextField: Bool
    }
    enum TableViewCellType {
        case text(type: TextCellType)
        case form(type: FormTextFieldType)
        case checkbox
        case clickableText
    }
    enum SpecificCell {
        case introText
        case phnForm
        case dobForm
        case dovForm
        case rememberCheckbox
        case clickablePrivacyPolicy
        
        var getCellType: TableViewCellType {
            switch self {
            case .introText:
                return .text(type: .plainText)
            case .phnForm:
                return .form(type: .personalHealthNumber)
            case .dobForm:
                return .form(type: .dateOfBirth)
            case .dovForm:
                return .form(type: .dateOfVaccination)
            case .rememberCheckbox:
                return .checkbox
            case .clickablePrivacyPolicy:
                return .clickableText
            }
        }
        
        var isTextField: Bool {
            switch self {
            case .phnForm: return true
            case .dobForm: return true
            case .dovForm: return true
            default: return false
            }
        }
    }
    
    func transform() -> TextFieldData? {
        switch self.specificCell {
        case .phnForm: return TextFieldData(type: .personalHealthNumber, text: self.configuration.text)
        case .dobForm: return TextFieldData(type: .dateOfBirth, text: self.configuration.text)
        case .dovForm: return TextFieldData(type: .dateOfVaccination, text: self.configuration.text)
        default: return nil
        }
    }
    
    static func getSpecificCellFromFormTextField(_ formTextField: FormTextFieldType) -> SpecificCell {
        switch formTextField {
        case .personalHealthNumber: return .phnForm
        case .dateOfBirth: return .dobForm
        case .dateOfVaccination: return .dovForm
        }
    }
    
    var specificCell: SpecificCell
    var configuration: Configuration
    var isFieldVisible: Bool
}

struct TextFieldData: Equatable {
    let type: FormTextFieldType
    let text: String?
}
