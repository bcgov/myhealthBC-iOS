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
        case .fully: return .vaccinated
        case .partially: return .partiallyVaccinated
        case .notVaxed: return .noRecordFound
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

enum Source: String, Codable {
    case healthGateway = "healthGateway", scanner = "scanner", imported = "imported"
}

public struct LocallyStoredVaccinePassportModel: Codable, Equatable {
    let code: String
    let birthdate: String
    var vaxDates: [String]
    let name: String
    let issueDate: Double
    let status: VaccineStatus
    let source: Source
    var fedCode: String?
    let phn: String?
    
    func transform() -> AppVaccinePassportModel {
        return AppVaccinePassportModel(codableModel: self)
    }
}

struct AppVaccinePassportModel: Equatable {
    let codableModel: LocallyStoredVaccinePassportModel
    var image: UIImage? {
        // TODO: After testing has been completed, can remove the default value - this is just for the locally stored values
        return codableModel.code.generateQRCode() ?? codableModel.code.toImage()
    }
    var issueDate: String? {
        let date = Date.init(timeIntervalSince1970: codableModel.issueDate)
        return Date.Formatter.issuedOnDateTime.string(from: date)
    }
    var id: String? {
        return codableModel.name + codableModel.birthdate
    }
    
    func transform() -> LocallyStoredVaccinePassportModel {
        return self.codableModel
    }
    
    func getFormattedIssueDate() -> String {
        guard let issueDate = issueDate else { return "" }
        return .issuedOn + issueDate
    }
}
