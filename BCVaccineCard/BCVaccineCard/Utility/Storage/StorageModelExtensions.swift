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
    // Should ideally make this more efficient
    public var prescriptionArray: [Perscription] {
        let set = prescriptions as? Set<Perscription> ?? []
        return set.filter { $0.medication?.isPharmacistAssessment == false }.sorted {
            $0.dispensedDate ?? Date() > $1.dispensedDate ?? Date()
        }
    }
    
    // Should ideally make this more efficient
    public var pharmacistArray: [Perscription] {
        let set = prescriptions as? Set<Perscription> ?? []
        return set.filter { $0.medication?.isPharmacistAssessment == true }.sorted {
            $0.dispensedDate ?? Date() > $1.dispensedDate ?? Date()
        }
    }
    
    public var immunizationArray: [Immunization] {
        let set = immunizations as? Set<Immunization> ?? []
        return set.sorted {
            $0.dateOfImmunization ?? Date() > $1.dateOfImmunization ?? Date()
        }
    }
    
    public var recommandationsArray: [ImmunizationRecommendation] {
        let set = recommendations as? Set<ImmunizationRecommendation> ?? []
        return set.sorted {
            $0.agentEligibleDate ?? Date() > $1.agentEligibleDate ?? Date()
        }
    }
    
    public var labOrdersArray: [LaboratoryOrder] {
        let set = laboratoryOrders as? Set<LaboratoryOrder> ?? []
        return set.sorted {
            $0.timelineDateTime ?? Date() > $1.timelineDateTime ?? Date()
        }
    }
    
    public var immunizationsArray: [Immunization] {
        let set = immunizations as? Set<Immunization> ?? []
        return Array(set)
    }
    
    public var healthVisitsArray: [HealthVisit] {
        let set = healthVisits as? Set<HealthVisit> ?? []
        return set.sorted {
            $0.encounterDate ?? Date() > $1.encounterDate ?? Date()
        }
    }
    
    public var hospitalVisitsArray: [HospitalVisit] {
        let set = hospitalVisits as? Set<HospitalVisit> ?? []
        return set.sorted {
            $0.admitDateTime ?? Date() > $1.admitDateTime ?? Date()
        }
    }
    
    public var clinicalDocumentsArray: [ClinicalDocument] {
        let set = clinicalDocuments as? Set<ClinicalDocument> ?? []
        return set.sorted {
            $0.serviceDate ?? Date() > $1.serviceDate ?? Date()
        }
    }
    
    public var specialAuthorityDrugsArray: [SpecialAuthorityDrug] {
        let set = specialAuthorityDrugs as? Set<SpecialAuthorityDrug> ?? []
        return set.sorted {
            $0.effectiveDate ?? Date() > $1.effectiveDate ?? Date()
        }
    }
    
    public var diagnosticImagingArray: [DiagnosticImaging] {
        let set = diagnosticImaging as? Set<DiagnosticImaging> ?? []
        return set.sorted {
            $0.examDate ?? Date() > $1.examDate ?? Date()
        }
    }
    
//    public var notesArray: [Note] {
//        let set = notes as? Set<Note> ?? []
//        return set.sorted {
//            $0.journalDate ?? Date() > $1.journalDate ?? Date()
//        }
//    }
    
    public func getComparableName() -> String? {
        guard let name = self.name else {
            return nil
        }
        return StorageService.getComparableName(from: name)
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
    
    public var immunizations: [CovidImmunizationRecord] {
        let set = immunizationRecord as? Set<CovidImmunizationRecord> ?? []
        return set.sorted {
            $0.date ?? Date() < $1.date ?? Date()
        }
    }
    
    public var birthDateString: String {
        return patient?.birthday?.yearMonthDayString ?? ""
    }
    
    public var getCovidImmunizations: [CovidImmunizationRecord] {
        guard let array = immunizationRecord?.allObjects as? [CovidImmunizationRecord] else { return [] }
        return array
    }

}

extension Array where Element == VaccineCard {
    func immunizations() -> [CovidImmunizationRecord] {
        var result: [CovidImmunizationRecord] = []
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
            if let model = result.toLocal(federalPass: cardToProcess.federalPass) {
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
        guard let qrCode = code, let dates = vaxDates, let issueDate = issueDate, let firHash = firHash else {return nil}
        let status: VaccineStatus = vaxDates?.count ?? 0 > 1 ? .fully : (vaxDates?.count ?? 0 == 1 ? .partially : .notVaxed)
        return LocallyStoredVaccinePassportModel(id: id, code: qrCode, birthdate: birthDateString, hash: firHash, vaxDates: dates, name: name ?? "", issueDate: issueDate.timeIntervalSince1970, status: status, source: .imported, fedCode: federalPass, phn: patient?.phn)
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
    
    // FIXME: Note: This doesn't appear to be used anywhere - should we delete?
    func toLocal() -> LocallyStoredCovidTestResultModel? {
        let resourcePayload = GatewayTestResultResponse.ResourcePayload(loaded: true, retryin: 0, records: resultArray.compactMap({$0.toGatewayRecord()}), reportAvailable: false, id: nil)
        let response: GatewayTestResultResponse = GatewayTestResultResponse(resourcePayload: resourcePayload, totalResultCount: nil, pageIndex: nil, pageSize: nil, resultError: nil)
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
    
    var resultType: CovidTestResult {
        let testOutcomeReduced = self.testOutcome?.removeWhiteSpaceFormatting
        let testStatusReduced = self.testStatus?.removeWhiteSpaceFormatting
        var testOutcome = GatewayTestResultResponseRecord.ResponseOutcomeTypes.init(rawValue: testOutcomeReduced ?? "") ?? .indeterminate
        let testStatus = GatewayTestResultResponseRecord.ResponseStatusTypes.init(rawValue: testStatusReduced ?? "") ?? .pending
        if testStatus == .pending {
            testOutcome = .pending
        } else if testOutcome == .notSet || testOutcome == .other {
            testOutcome = .indeterminate
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

// MARK: Medication
extension Medication {
    var id: String {
        return din ?? (genericName ?? "")
    }
}

// MARK: Lab Order
extension LaboratoryOrder {
    public var labTests: [LaboratoryTest] {
        let set = laboratoryTests as? Set<LaboratoryTest> ?? []
        return set.sorted {
            $0.batteryType ?? "" < $1.batteryType ?? ""
        }
    }
    
    public var commentsArray: [Comment] {
        let set = comments as? Set<Comment> ?? []
        return set.sorted {
            $0.createdDateTime ?? Date() < $1.createdDateTime ?? Date()
        }
    }
}

// MARK: Special Authority Drugs
extension SpecialAuthorityDrug {
    public var commentsArray: [Comment] {
        let set = comments as? Set<Comment> ?? []
        return set.sorted {
            $0.createdDateTime ?? Date() < $1.createdDateTime ?? Date()
        }
    }
}

// MARK: Health Visit
extension HealthVisit {
    public var commentsArray: [Comment] {
        let set = comments as? Set<Comment> ?? []
        return set.sorted {
            $0.createdDateTime ?? Date() < $1.createdDateTime ?? Date()
        }
    }
}

// MARK: Covid lab results
extension CovidLabTestResult {
    public var commentsArray: [Comment] {
        let set = comments as? Set<Comment> ?? []
        return set.sorted {
            $0.createdDateTime ?? Date() < $1.createdDateTime ?? Date()
        }
    }
}

// MARK: Perscription
extension Perscription {
    public var commentsArray: [Comment] {
        let set = comments as? Set<Comment> ?? []
        return set.sorted {
            $0.createdDateTime ?? Date() < $1.createdDateTime ?? Date()
        }
    }
}

// MARK: Hospital Visit
extension HospitalVisit {
    public var commentsArray: [Comment] {
        let set = comments as? Set<Comment> ?? []
        return set.sorted {
            $0.createdDateTime ?? Date() < $1.createdDateTime ?? Date()
        }
    }
}

// MARK: ClinicalDocument
extension ClinicalDocument {
    public var commentsArray: [Comment] {
        let set = comments as? Set<Comment> ?? []
        return set.sorted {
            $0.createdDateTime ?? Date() < $1.createdDateTime ?? Date()
        }
    }
}

// MARK: DiagnosticImaging
extension DiagnosticImaging {
    public var commentsArray: [Comment] {
        let set = comments as? Set<Comment> ?? []
        return set.sorted {
            $0.createdDateTime ?? Date() < $1.createdDateTime ?? Date()
        }
    }
}

// MARK: Comment
extension Comment {
    public var prescriptions: [Perscription] {
        let set = prescription as? Set<Perscription> ?? []
        return Array(set)
    }
}

// MARK: ImmunizationDetails
extension ImmunizationDetails {
    public var agents: [ImmunizationAgent] {
        let set = immunizationAgents as? Set<ImmunizationAgent> ?? []
        return Array(set)
    }
}

// MARK: Recommendations
extension ImmunizationRecommendation {
    public var targetDiseasesArray: [ImmunizationTargetDisease] {
        let set = targetDiseases as? Set<ImmunizationTargetDisease> ?? []
        return Array(set)
    }
}


// MARK: Dependents
extension Patient {
    
    public var dependentsArray: [Dependent] {
        let set = dependents as? Set<Dependent> ?? []
        return Array(set).sorted
    }
    
    public var dependentsInfo: [Patient] {
        return dependentsArray.compactMap({$0.info})
    }
    
    func hasDepdendentWith(phn: String) -> Bool {
        return self.dependentsInfo.contains(where: { $0.phn != nil && $0.phn == phn})
    }
    
    func isDependent() -> Bool {
        return dependencyInfo != nil
    }
}

extension Array where Element == Dependent {
    var sorted: [Dependent] {
        let alphabetized = self.sorted { $0.info?.name ?? "" < $1.info?.name ?? "" }
        return alphabetized.sorted(by: {
            $0.info?.birthday ?? Date() > $1.info?.birthday ?? Date()
        })
    }
    
    var under12: [Dependent] {
        return self.filter { item in
            if let info = item.info, let birthday = info.birthday, let age = birthday.ageInYears, age > 12 {
                return false
            } else {
                return true
            }
        }.sorted
    }
    
    var over12: [Dependent] {
        return self.filter { item in
            if let info = item.info, let birthday = info.birthday, let age = birthday.ageInYears, age > 12 {
                return true
            } else {
                return false
            }
        }.sorted
    }
}
