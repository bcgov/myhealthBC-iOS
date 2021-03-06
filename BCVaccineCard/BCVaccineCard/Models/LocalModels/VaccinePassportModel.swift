//
//  VaccinePassportModel.swift
//  ClientVaxPass-POC
//
//  Created by Connor Ogilvie on 2021-09-10.
//

import UIKit
import BCVaccineValidator

enum VaccineStatus: String, Codable {
    case fully = "fully", partially = "partially", notVaxed = "none"
    
    var getTitle: String {
        switch self {
        case .fully: return .vaccinated.sentenceCase()
        case .partially: return .partiallyVaccinated.sentenceCase()
        case .notVaxed: return .noRecordFound.sentenceCase()
        }
    }
    
    var getColor: UIColor {
        switch self {
        case .fully: return AppColours.green
        case .partially: return AppColours.partiallyVaxedBlue
        case .notVaxed: return .darkGray //Note: If this gets used, we will need to change the color to the actual grey
        }
    }
}

enum Source: String, Codable {
    case healthGateway = "healthGateway", scanner = "scanner", imported = "imported"
}

public struct LocallyStoredVaccinePassportModel: Codable, Equatable {
    let id: String? // stored id in core data.
    let code: String
    let birthdate: String
    let hash: String
    var vaxDates: [String]
    let name: String
    let issueDate: Double
    let status: VaccineStatus // Use code to derive when possible
    let source: Source
    var fedCode: String?
    let phn: String?
    
    func transform() -> AppVaccinePassportModel {
        return AppVaccinePassportModel(codableModel: self)
    }
    
    func isNewer(than other: LocallyStoredVaccinePassportModel) -> Bool {
        let currentIssueDate = Date.init(timeIntervalSince1970: issueDate)
        let otherIssueDate = Date.init(timeIntervalSince1970: other.issueDate)
        
        return currentIssueDate > otherIssueDate
    }
}

struct AppVaccinePassportModel: Equatable {
    let codableModel: LocallyStoredVaccinePassportModel
    
    var issueDate: String? {
        let date = Date.init(timeIntervalSince1970: codableModel.issueDate)
        return Date.Formatter.issuedOnDateTime.string(from: date)
    }
    
    var id: String? {
        return codableModel.hash
    }
    
    func transform() -> LocallyStoredVaccinePassportModel {
        return self.codableModel
    }
    
    func getFormattedIssueDate() -> String {
        guard let issueDate = issueDate else { return "" }
        return .issuedOn + issueDate
    }
}


extension CodeValidationResult {
    func toLocal(federalPass: String? = nil, source: Source? = .imported) -> LocallyStoredVaccinePassportModel? {
        return result?.toLocal(federalPass: federalPass, source: source)
    }
}

extension ScanResultModel {
    func toLocal(federalPass: String? = nil, phn: String? = nil, source: Source? = .imported) -> LocallyStoredVaccinePassportModel {
        var status: VaccineStatus
        switch self.status {
        case .Fully:
            status = .fully
        case .Partially:
            status = .partially
        case .None:
            status = .notVaxed
        }
        let vadDates: [String] = immunizations.compactMap({$0.date})
        
        let hash = payload.fhirBundleHash() ?? "\(name)-\(birthdate)"
      
        return LocallyStoredVaccinePassportModel(id: nil, code: code, birthdate: birthdate, hash: hash, vaxDates: vadDates, name: name, issueDate: issueDate, status: status, source: source ?? .imported, fedCode: federalPass, phn: phn)
        
    }
}
