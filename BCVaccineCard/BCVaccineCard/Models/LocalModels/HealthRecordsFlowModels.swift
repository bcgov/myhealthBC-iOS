//
//  HealthRecordsFlowModels.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-11-30.
//

import Foundation

// MARK: This is the data source used in the collection view on the base health records screen
struct HealthRecordsDataSource {
    let patient: Patient
    var numberOfRecords: Int
    var authenticated: Bool
}


struct HealthRecord {
    public enum Record {
        case CovidTest(CovidLabTestResult)
        case CovidImmunization(VaccineCard)
        case Medication(Perscription)
        case LaboratoryOrder(LaboratoryOrder)
        case Immunization(Immunization)
        case HealthVisit(HealthVisit)
        case SpecialAuthorityDrug(SpecialAuthorityDrug)
    }
    
    public let type: Record
    public let patient: Patient
    public let patientName: String
    public let birthDate: Date?
    
    init(type: HealthRecord.Record) {
        self.type = type
        switch type {
        case .CovidTest(let test):
            let results = test.resultArray
            patient = test.patient!
            birthDate = test.patient?.birthday
            if let first = results.first {
                patientName = first.patientDisplayName ?? ""
                
            } else {
                patientName = ""
            }
        case .CovidImmunization(let card):
            patient = card.patient!
            patientName = card.name ?? ""
            birthDate = card.patient?.birthday
        case .Medication(let prescription):
            patient = prescription.patient!
            patientName = prescription.patient?.name ?? ""
            birthDate = prescription.patient?.birthday
        case .LaboratoryOrder(let labOrder):
            patient = labOrder.patient!
            patientName = patient.name ?? ""
            birthDate = patient.birthday
        case .Immunization(let immunization):
            patient = immunization.patient!
            patientName = patient.name ?? ""
            birthDate = patient.birthday
        case .HealthVisit(let object):
            patient = object.patient!
            patientName = patient.name ?? ""
            birthDate = patient.birthday
        case .SpecialAuthorityDrug(let object):
            patient = object.patient!
            patientName = patient.name ?? ""
            birthDate = patient.birthday
        }
    }
}

extension HealthRecord {
    var commentId: String {
        switch type {
        case .CovidTest(let object):
            return object.id ?? ""
        case .CovidImmunization(_):
            return ""
        case .Medication(let medication):
            return medication.prescriptionIdentifier ?? ""
        case .LaboratoryOrder(let labTest):
            return labTest.labPdfId ?? ""
        case .Immunization(let object):
            return ""
        case .HealthVisit(let object):
            return object.id ?? ""
        case .SpecialAuthorityDrug(let object):
            return object.referenceNumber ?? ""
        }
    }
    
//    var sortDate: Date {
//        switch type {
//        case .CovidTest(let obj):
//            return
//        case .CovidImmunization(let obj):
//            return
//        case .Medication(let obj):
//            return
//        case .LaboratoryOrder(let obj):
//            return
//    }
}

// MARK: Helpers
extension HealthRecord {
    
    /// Convert to a HealthRecordsDetailDataSource
    /// - Returns: Detail Data Source
    func detailDataSource() -> HealthRecordsDetailDataSource? {
        switch type {
        case .CovidTest(let test):
            return HealthRecordsDetailDataSource(type: .covidTestResultRecord(model: test))
        case .CovidImmunization(let covidImmunization):
            guard let model = covidImmunization.toLocal() else {return nil}
            return HealthRecordsDetailDataSource(type: .covidImmunizationRecord(model: model, immunizations: covidImmunization.immunizations))
        case .Medication(let prescription):
            return HealthRecordsDetailDataSource(type: .medication(model: prescription))
        case .LaboratoryOrder(let labOrder):
            return HealthRecordsDetailDataSource(type: .laboratoryOrder(model: labOrder))
        case .Immunization(let immunization):
            return HealthRecordsDetailDataSource(type: .immunization(model: immunization))
        case .HealthVisit(let object):
            return HealthRecordsDetailDataSource(type: .healthVisit(model: object))
        case .SpecialAuthorityDrug(let object):
            return HealthRecordsDetailDataSource(type: .specialAuthorityDrug(model: object))
        }
    }
    
    var isAuthenticated: Bool {
        switch type {
        case .CovidTest(let test):
            return test.authenticated
        case .CovidImmunization(let covidImmunization):
            return covidImmunization.authenticated
        case .Medication(let prescription):
            return prescription.authenticated
        case .LaboratoryOrder(let labOrder):
            return labOrder.authenticated
        case .Immunization(let immunization):
            return immunization.authenticated
        case .HealthVisit(let object):
            return object.authenticated
        case .SpecialAuthorityDrug(let object):
            return object.authenticated
        }
    }
}

extension Array where Element == HealthRecord {
    
    /// Convert array of HealthRecord to HealthRecordsDataSource
    /// - Returns: Array of Detail Data Source
    func dataSource() -> [HealthRecordsDataSource] {
        var result: [HealthRecordsDataSource] = []
        for record in self {
            if let i = result.firstIndex(where: {$0.patient == record.patient}) {
                if record.isAuthenticated {
                    result[i].authenticated = true
                }
                result[i].numberOfRecords += 1
            } else {
                result.append(HealthRecordsDataSource(patient: record.patient, numberOfRecords: 1, authenticated: record.isAuthenticated))
            }
        }
        if let indexOfAuthenticated = result.firstIndex(where: {$0.authenticated}) {
            let element = result.remove(at: indexOfAuthenticated)
            result.insert(element, at: 0)
        }
        return result
    }
    
    func detailDataSource(patient: Patient) -> [HealthRecordsDetailDataSource] {
        let filtered = self.filter { $0.patient == patient }
        return filtered.compactMap({$0.detailDataSource()}).sorted(by: {first,second in
            let firstDate: Date?
            let secondDate: Date?
            switch first.type {
            case .covidImmunizationRecord(model: let model, immunizations: _):
                firstDate = Date(timeIntervalSince1970: model.issueDate)
            case .covidTestResultRecord(model: let model):
                firstDate = model.mainResult?.resultDateTime
            case .medication(model: let model):
                firstDate = model.dispensedDate
            case .laboratoryOrder(model: let model):
                firstDate = model.timelineDateTime
            case .immunization(model: let model):
                firstDate = model.dateOfImmunization
            case .healthVisit(model: let model):
                firstDate = model.encounterDate
            case .specialAuthorityDrug(model: let model):
                firstDate = model.requestedDate
            }
            switch second.type {
            case .covidImmunizationRecord(model: let model, immunizations: _):
                secondDate = Date(timeIntervalSince1970: model.issueDate)
            case .covidTestResultRecord(model: let model):
                secondDate = model.mainResult?.resultDateTime
            case .medication(model: let model):
                secondDate = model.dispensedDate
            case .laboratoryOrder(model: let model):
                secondDate = model.timelineDateTime
            case .immunization(model: let model):
                secondDate = model.dateOfImmunization
            case .healthVisit(model: let model):
                secondDate = model.encounterDate
            case .specialAuthorityDrug(model: let model):
                secondDate = model.requestedDate
            }
            return firstDate ?? Date() > secondDate ?? Date()
        })
    }
    
    func fetchDetailDataSourceWithID(id: String, recordType: GetRecordsView.RecordType) -> HealthRecordsDetailDataSource? {
        if let index = self.firstIndex(where: { record in
            switch record.type {
            case .CovidTest(let testResult):
                if recordType == .covidTestResult {
                    return testResult.id == id
                }
                return false
            case .CovidImmunization(let immunizationRecord):
                if recordType == .covidImmunizationRecord {
                    return immunizationRecord.id == id
                }
                return false
            case .Medication(let prescription):
                if recordType == .medication {
                    return prescription.id == id
                }
                return false
            case .LaboratoryOrder(let labOrder):
                if recordType == .laboratoryOrder {
                    return labOrder.id == id
                }
                return false
            case .Immunization(let immunization):
                if recordType == .immunization {
                    return immunization.id == id
                }
                return false
            case .HealthVisit(let object):
                if recordType == .healthVisit {
                    return object.id == id
                }
                return false
            case .SpecialAuthorityDrug(let object):
                if recordType == .SpecialAuthority {
                    return object.referenceNumber == id
                }
                return false
            }
        }) {
            return self[index].detailDataSource()
        }
        return nil
    }
}
