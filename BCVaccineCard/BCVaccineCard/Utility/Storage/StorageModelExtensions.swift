//
//  Helpers.swift
//  BCVaccineCard
//
//  Created by Amir on 2021-12-02.
//

import Foundation
import BCVaccineValidator
/**
 Keeping these extensions here instead of model files generated by xcode, so that the models can be updated without losing these helpers
 */

// MARK: Users
extension Patient {
    
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
    
    public var birthDateString: String {
        return birthdate?.birthdayYearDateString ?? ""
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
    
    
    /// Convert array of vaccine cards to local model.
    /// Its async because we need to process the statuses of the cards using validator
    /// - Parameter completion: Processed cards
    func toAppVaccinePassportModel(completion: @escaping([AppVaccinePassportModel])->Void) {
        recursivelyProcessStored(cards: self, processed: []) { processed in
            return completion(processed)
        }
    }
    
    private func recursivelyProcessStored(cards: [VaccineCard], processed: [AppVaccinePassportModel], completion: @escaping([AppVaccinePassportModel]) -> Void) {
        if cards.isEmpty {
            return completion(processed)
        }
        var processedCards = processed
        var remainingCards = cards
        guard let cardToProcess = remainingCards.popLast(),
              let code = cardToProcess.code else {
                  return recursivelyProcessStored(cards: remainingCards, processed: processed, completion: completion)
              }
        // TODO: Will need to get vax dates from the processed result and add to model below
        BCVaccineValidator.shared.validate(code: code) { result in
            if let model = result.toLocal(federalPass: cardToProcess.federalPass, phn: cardToProcess.phn) {
                processedCards.append(AppVaccinePassportModel(codableModel: model))
                self.recursivelyProcessStored(cards: remainingCards, processed: processedCards, completion: completion)
            } else {
                self.recursivelyProcessStored(cards: remainingCards, processed: processedCards, completion: completion)
            }
        }
    }
}

extension VaccineCard {
    public func toLocal() -> LocallyStoredVaccinePassportModel? {
        guard let qrCode = code, let dates = vaxDates, let issueDate = issueDate, let birthdate = birthdate, let firHash = firHash else {return nil}
        let status: VaccineStatus = vaxDates?.count ?? 0 > 1 ? .fully : (vaxDates?.count ?? 0 == 1 ? .partially : .notVaxed)
        return LocallyStoredVaccinePassportModel(id: id, code: qrCode, birthdate: birthDateString, hash: firHash, vaxDates: dates, name: name ?? "", issueDate: issueDate.timeIntervalSince1970, status: status, source: .imported, fedCode: federalPass, phn: phn)
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
    
    var resultType: CovidTestResult? {
        return resultArray.first?.resultType
    }
    
    var mainResult: TestResult? {
        // TODO: Criteria for selecting main result to use the status of
        return resultArray.first
    }
    
    func toLocal() -> LocallyStoredCovidTestResultModel? {
        let resourcePayload = GatewayTestResultResponse.ResourcePayload(loaded: true, retryin: 0, records: resultArray.compactMap({$0.toGatewayRecord()}))
        let response: GatewayTestResultResponse = GatewayTestResultResponse(resourcePayload: resourcePayload, totalResultCount: nil, pageIndex: nil, pageSize: nil, resultStatus: nil, resultError: nil)
//        let response: GatewayTestResultResponse = GatewayTestResultResponse(records: resultArray.compactMap({$0.toGatewayRecord()}))
        return LocallyStoredCovidTestResultModel(response: response, resultType: resultType ?? .indeterminate)
    }
}

// MARK: TestResult
extension TestResult {
            // Logic here is basically as follows:
            // Below are the possible outcomes:
    ///        Test Status:
    ///        - Pending
    ///        - Final
    ///        - StatusChange
    ///
    ///        Test Outcome:
    ///        - NotSet - (Pending) - unknown
    ///        - Other - unknown
    ///        - Indeterminate
    ///        - Negative
    ///        - Positive
    ///        - Cancelled
    
            // So - if the test result is "NotSet" or "Other", and status is pending, then for our purposes, result is pending. If said case but not pending, then indeterminate
    var resultType: CovidTestResult {
        var testOutcome = GatewayTestResultResponseRecord.ResponseOutcomeTypes.init(rawValue: self.testOutcome ?? "") ?? .indeterminate
        let testStatus = GatewayTestResultResponseRecord.ResponseStatusTypes.init(rawValue: self.testStatus ?? "") ?? .pending
        if testOutcome == .notSet || testOutcome == .other {
            testOutcome = testStatus == .pending ? .pending : .indeterminate
        }
        let rawValue = testOutcome.rawValue
        return CovidTestResult.init(rawValue: rawValue) ?? .indeterminate
    }
    
    func toGatewayRecord() -> GatewayTestResultResponseRecord? {
        return GatewayTestResultResponseRecord(patientDisplayName: self.patientDisplayName, lab: self.lab, reportId: self.reportId, collectionDateTime: self.collectionDateTime?.gatewayDateAndTime, resultDateTime: self.resultDateTime?.gatewayDateAndTime, testName: self.testName, testType: self.testType, testStatus: self.testStatus, testOutcome: self.testOutcome, resultTitle: self.resultTitle, resultDescription: self.resultDescription, resultLink: self.resultLink)
    }
}

//extension Array where Element == TestResult {
//    /// Convert to health record object
//    /// - Returns: Array of HealthRecord objects
//    func toHealthRecord() -> [HealthRecord] {
//        return self.map({HealthRecord(type: .Test($0))})
//    }
//}
