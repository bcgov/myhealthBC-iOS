//
//  VaccinePassportModel.swift
//  ClientVaxPass-POC
//
//  Created by Connor Ogilvie on 2021-09-10.
//

import UIKit

enum VaccineStatus: String, Codable {
    case fully = "fully", partially = "partially", notVaxed = "none"
    
    var getTitle: String {
        switch self {
        case .fully: return Constants.Strings.MyCardFlow.HasCards.fullyVaccinated
        case .partially: return Constants.Strings.MyCardFlow.HasCards.partiallyVaccinated
        case .notVaxed: return Constants.Strings.MyCardFlow.HasCards.noRecordFound
        }
    }
    
    var getColor: UIColor {
        switch self {
        case .fully: return AppColours.vaccinatedGreen
        case .partially: return AppColours.partiallyVaxedBlue
        case .notVaxed: return .darkGray //Note: If this gets used, we will need to change the color to the actual grey
        }
    }
}

struct LocallyStoredVaccinePassportModel: Codable, Equatable {
    let code: String
    let birthdate: String
    let name: String
    let status: VaccineStatus
    
    func transform() -> AppVaccinePassportModel {
        return AppVaccinePassportModel(codableModel: self)
    }
}

struct AppVaccinePassportModel: Equatable {
    let codableModel: LocallyStoredVaccinePassportModel
    var image: UIImage? {
        return codableModel.code.generateQRCode()
    }
    
    func transform() -> LocallyStoredVaccinePassportModel {
        return self.codableModel
    }
}
