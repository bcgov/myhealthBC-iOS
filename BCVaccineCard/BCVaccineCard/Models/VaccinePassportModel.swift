//
//  VaccinePassportModel.swift
//  ClientVaxPass-POC
//
//  Created by Connor Ogilvie on 2021-09-10.
//

import UIKit

enum VaccineStatus: String, Codable {
    case fully = "fully", partially, notVaxed
    
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

struct VaccinePassportModel: Codable, Equatable {
    let imageName: String
    let phn: String
    let name: String
    let status: VaccineStatus
}
