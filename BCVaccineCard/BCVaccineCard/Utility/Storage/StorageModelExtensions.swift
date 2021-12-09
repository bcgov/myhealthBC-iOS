//
//  Helpers.swift
//  BCVaccineCard
//
//  Created by Amir on 2021-12-02.
//

import Foundation
/**
 Keeping these extensions here instead of model files generated by xcode, so that the models can be updated without losing these helpers
 */

// MARK: Users
extension User {
    public var userId: String {
        return id ?? ""
    }
    
    public var vaccineCardArray: [VaccineCard] {
        let set = vaccineCard as? Set<VaccineCard> ?? []
        return set.sorted {
            $0.sortOrder < $1.sortOrder
        }
    }
    
    public var testResultArray: [CovidLabTestResult] {
        let set = covidTestResults as? Set<CovidLabTestResult> ?? []
        return set.sorted {
            $0.mainResult?.collectionDateTime ?? Date() > $1.mainResult?.collectionDateTime ?? Date()
        }
    }
}

// MARK: VaccineCard
extension VaccineCard {
    public var federalPassData: Data? {
        guard let stringData = federalPass else { return nil}
        return Data(base64URLEncoded: stringData)
    }
    
    var id: String? {
        return firHash
    }
    
    public var immunizations: [ImmunizationRecord] {
        let set = immunizationRecord as? Set<ImmunizationRecord> ?? []
        return set.sorted {
            $0.date ?? Date() < $1.date ?? Date()
        }
    }
    
    public var getCovidImmunizations: [ImmunizationRecord] {
        guard let array = immunizationRecord?.allObjects as? [ImmunizationRecord] else { return [] }
        return array
    }

}

extension Array where Element == VaccineCard {
    func immunizations() -> [ImmunizationRecord] {
        var result: [ImmunizationRecord] = []
        for card in self {
            result.append(contentsOf: card.immunizations)
        }
        return result
    }
    
    /// Convert to health record object
    /// - Returns: Array of HealthRecord objects
    func toHealthRecord() -> [HealthRecord] {
        return self.map({HealthRecord(type: .CovidImmunization($0))})
    }
}

extension VaccineCard {
    public func toLocal() -> LocallyStoredVaccinePassportModel? {
        guard let qrCode = code, let dates = vaxDates, let issueDate = issueDate, let birthdate = birthdate, let firHash = firHash else {return nil}
        let status: VaccineStatus = vaxDates?.count ?? 0 > 1 ? .fully : (vaxDates?.count ?? 0 == 1 ? .partially : .notVaxed)
        return LocallyStoredVaccinePassportModel(code: qrCode, birthdate: birthdate, hash: firHash, vaxDates: dates, name: name ?? "", issueDate: issueDate.timeIntervalSince1970, status: status, source: .imported, fedCode: federalPass, phn: phn)
    }
}

// MARK: CovidLabTestResult
extension CovidLabTestResult {
    public var resultArray: [TestResult] {
        let set = results as? Set<TestResult> ?? []
        return set.sorted {
            $0.resultDateTime ?? Date() > $1.resultDateTime ?? Date()
        }
    }
    
    var status: CovidTestResult? {
        return resultArray.first?.status
    }
    
    var mainResult: TestResult? {
        // TODO: Criteria for selecting main result to use the status of
        return resultArray.first
    }
    
    func toLocal() -> LocallyStoredCovidTestResultModel? {
        let response: GatewayTestResultResponse = GatewayTestResultResponse(records: resultArray.compactMap({$0.toGatewayRecord()}))
        return LocallyStoredCovidTestResultModel(response: response, status: status ?? .indeterminate)
    }
}

// MARK: TestResult
extension TestResult {
    
    var status: CovidTestResult {
        return CovidTestResult.init(rawValue: self.testOutcome ?? "") ?? CovidTestResult.init(rawValue: self.testStatus ?? "") ?? .indeterminate
    }
    
    func toGatewayRecord() -> GatewayTestResultResponseRecord? {
        return GatewayTestResultResponseRecord(patientDisplayName: self.patientDisplayName, lab: self.lab, reportId: self.reportId, collectionDateTime: self.collectionDateTime, resultDateTime: self.resultDateTime, testName: self.testName, testType: self.testType, testStatus: self.testStatus, testOutcome: self.testOutcome, resultTitle: self.resultTitle, resultDescription: self.resultDescription, resultLink: self.resultLink)
    }
}

//extension Array where Element == TestResult {
//    /// Convert to health record object
//    /// - Returns: Array of HealthRecord objects
//    func toHealthRecord() -> [HealthRecord] {
//        return self.map({HealthRecord(type: .Test($0))})
//    }
//}
