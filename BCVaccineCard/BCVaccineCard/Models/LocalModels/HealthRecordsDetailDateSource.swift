//
//  HealthRecordsDetailDateSource.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-11-30.
// NOTE: This model is used in the health records flow

import UIKit

struct HealthRecordsDetailDataSource {
    struct Record {
        enum RecordType {
            case covidImmunizationRecord(model: LocallyStoredVaccinePassportModel, immunizations: [CovidImmunizationRecord])
            case covidTestResultRecord(model: TestResult)
            case medication(model: Perscription)
            case laboratoryOrder(model: LaboratoryOrder, tests: [LaboratoryTest])
            case immunization(model: Immunization)
            case healthVisit(model: HealthVisit)
            case specialAuthorityDrug(model: SpecialAuthorityDrug)
        }
        let id: String
        let name: String
        let type: RecordType
        let status: String?
        let date: String?
        let listStatus: String
        
        var comments: [Comment] {
            switch type {
            case .covidImmunizationRecord:
                return []
            case .covidTestResultRecord:
                return []
            case .medication(let medication):
                return medication.commentsArray
            case .laboratoryOrder:
                // TODO: when supporting lab order comments
                return []
            case .immunization:
                return []
            case .healthVisit:
                return []
            case .specialAuthorityDrug:
                return []
            }
        }
        
        var includesSeparatorUI: Bool {
            switch self.type {
            case .covidImmunizationRecord, .covidTestResultRecord, .laboratoryOrder, .immunization: return true
            case .medication, .specialAuthorityDrug, .healthVisit: return false
            }
        }
        
    }
    
    enum RecordType {
        case covidImmunizationRecord(model: LocallyStoredVaccinePassportModel, immunizations: [CovidImmunizationRecord])
        case covidTestResultRecord(model: CovidLabTestResult)
        case medication(model: Perscription)
        case laboratoryOrder(model: LaboratoryOrder)
        case immunization(model: Immunization)
        case healthVisit(model: HealthVisit)
        case specialAuthorityDrug(model: SpecialAuthorityDrug)
    }
    
    let id: String?
    let name: String
    let type: RecordType
    let title: String
    let detailNavTitle: String
    let image: UIImage?
    
    let records: [Record]
    
    
    var mainRecord: Record? {
        switch type {
        case .covidImmunizationRecord(_, _):
            return records.first
        case .covidTestResultRecord(let model):
            guard let mainResultModel = model.mainResult else {return nil}
            let record = HealthRecordsDetailDataSource.genRecord(testResult: mainResultModel, parentResult: model)
            return records.first(where: {$0.id == record.id})
        case .medication(model: _):
            return records.first
        case .laboratoryOrder(model: let model):
            if records.isEmpty {
                Logger.log(string: "No Records in lab order \(String(describing: model.id))", type: .general)
                return nil
            } else {
                return records.first
            }
        case .immunization:
            return records.first
        case .healthVisit:
            return records.first
        case .specialAuthorityDrug:
            return records.first
        }
    }
    
    var isAuthenticated: Bool {
        switch type {
        case .covidImmunizationRecord(let model, _):
            return StorageService.shared.fetchVaccineCard(code: model.code)?.authenticated ?? false
        case .covidTestResultRecord(let model):
            return model.authenticated
        case .medication(model: let model):
            return model.authenticated
        case .laboratoryOrder(model: let model):
            return model.authenticated
        case .immunization(model: let model):
            return model.authenticated
        case .healthVisit(model: let model):
            return model.authenticated
        case .specialAuthorityDrug(model: let model):
            return model.authenticated
        }
    }
    
    var containsProtectedWord: Bool {
        switch type {
        case
                .covidImmunizationRecord,
                .covidTestResultRecord,
                .laboratoryOrder,
                .healthVisit,
                .specialAuthorityDrug,
                .immunization:
            return false
        case .medication:
            return true
        }
    }
    
    let deleteAlertTitle: String
    let deleteAlertMessage: String
    
    
    init(type: RecordType) {
        self.type = type
        self.records = HealthRecordsDetailDataSource.genRecords(type: type)
        switch type {
        case .covidImmunizationRecord(let model, _):
            id = model.id
            title = .covid19vaccination
            detailNavTitle = .vaccinationRecord
            name = model.name
            image = UIImage(named: "blue-bg-vaccine-record-icon")
            deleteAlertTitle = .deleteRecord
            deleteAlertMessage = .deleteCovidHealthRecord
        case .covidTestResultRecord(let model):
            id = model.id
            title = .covid19TestResultTitle
            detailNavTitle = .covid19TestResultTitle
            name = model.resultArray.first?.patientDisplayName ?? ""
            image = UIImage(named: "blue-bg-test-result-icon")
            deleteAlertTitle = .deleteTestResult
            deleteAlertMessage = .deleteTestResultMessage
        case .medication(model: let model):
            id = model.id
            title = model.medication?.brandName ?? "Statins"
            detailNavTitle = model.medication?.brandName ?? "Statins"
            name = model.patient?.name ?? ""
            image = UIImage(named: "blue-bg-medication-record-icon")
            deleteAlertTitle = "N/A" // Note: We can't delete an auth medical record, so this won't be necessary
            deleteAlertMessage = "Shouldn't see this" // Showing these values for testing purposes
        case .laboratoryOrder(model: let model):
            id = model.id
            title = model.commonName ?? ""
            detailNavTitle = "Lab test"
            name = model.patient?.name ?? ""
            image = UIImage(named: "blue-bg-laboratory-record-icon")
            deleteAlertTitle = "N/A" // Can't delete an authenticated lab result
            deleteAlertMessage = "Should not see this" // Showing for testing purposes
            if title == "" {
                print("--")
            }
        case .immunization(model: let model):
            id = model.id
            title = model.immunizationDetails?.name ?? ""
            detailNavTitle = model.immunizationDetails?.name ?? ""
            name = model.patient?.name ?? ""
            image = UIImage(named: "blue-bg-vaccine-record-icon")
            deleteAlertTitle = "N/A" // Can't delete an authenticated Immunization
            deleteAlertMessage = "Should not see this" // Showing for testing purposes
            if title == "" {
                print("--")
            }
        case .healthVisit(model: let model):
            id = model.id
            title = model.specialtyDescription ?? ""
            detailNavTitle = model.clinic?.name ?? ""
            name = model.patient?.name ?? ""
            image = UIImage(named: "blue-bg-health-visit-icon")
            deleteAlertTitle = "N/A" // Can't delete an authenticated Immunization
            deleteAlertMessage = "Should not see this" // Showing for testing purposes
            if title == "" {
                print("--")
            }
        case .specialAuthorityDrug(model: let model):
            id = model.referenceNumber
            title = model.drugName ?? ""
            detailNavTitle = model.drugName ?? ""
            name = model.patient?.name ?? ""
            image = UIImage(named: "blue-bg-special-authority-icon")
            deleteAlertTitle = "N/A" // Can't delete an authenticated Immunization
            deleteAlertMessage = "Should not see this" // Showing for testing purposes
            if title == "" {
                print("--")
            }
        }
    }
}

// MARK: Gen Records section
extension HealthRecordsDetailDataSource {
    private static func genRecords(type: RecordType)-> [Record] {
        var result: [Record] = []
        
        switch type {
        case .covidImmunizationRecord(let model, let immunizations):
            result.append(genRecord(vaccineModel: model, immunizations: immunizations))
            return result
        case .covidTestResultRecord(let model):
            for item in model.resultArray {
                result.append(genRecord(testResult: item, parentResult: model))
            }
            return result
        case .medication(model: let model):
            result.append(genRecord(prescription: model))
            return result
        case .laboratoryOrder(model: let model):
            result.append(genRecord(labOrder: model))
            return result
        case .immunization(model: let model):
            result.append(genRecord(immunization: model))
            return result
        case .healthVisit(model: let model):
            result.append(genRecord(healthVisit: model))
            return result
        case .specialAuthorityDrug(model: let model):
            result.append(genRecord(specialAuthorityDrug: model))
            return result
        }
    }
    
    // MARK: Immunization Records
    private static func genRecord(vaccineModel model: LocallyStoredVaccinePassportModel, immunizations: [CovidImmunizationRecord]) -> Record {
        let date: String? = model.vaxDates.last
        let modifiedDate = Date.Formatter.yearMonthDay.date(from: date ?? "")?.monthDayYearString ?? date
        return Record(id: model.md5Hash() ?? UUID().uuidString, name: model.name, type: .covidImmunizationRecord(model: model, immunizations: immunizations), status: model.status.getTitle, date: modifiedDate, listStatus: model.status.getTitle)
    }
    
    // MARK: Covid Test Results
    private static func genRecord(testResult: TestResult, parentResult: CovidLabTestResult) -> Record {
        let status: String = testResult.resultType.getTitle
        let date: String? = testResult.collectionDateTime?.monthDayYearString
        return Record(id: testResult.id ?? UUID().uuidString, name: testResult.patientDisplayName ?? "", type: .covidTestResultRecord(model: testResult), status: status, date: date, listStatus: status)
    }
    
    // MARK: Medications
    private static func genRecord(prescription: Perscription) -> Record {
        let dateString = prescription.dispensedDate?.monthDayYearString
        var address = ""
        if let addy = prescription.pharmacy?.addressLine1 {
            address = addy
        }
        if let city = prescription.pharmacy?.city {
            if address.count > 0 {
                address.append(", ")
                address.append(city)
            } else {
                address = city
            }
        }
        if let province = prescription.pharmacy?.province {
            if address.count > 0 {
                address.append(", ")
                address.append(province)
            } else {
                address = province
            }
        }
        
        // Notes:
        /// Unsure about status field - this is what it appears to be in designs though
        return Record(id: prescription.id ?? UUID().uuidString, name: prescription.patient?.name ?? "", type: .medication(model: prescription), status: prescription.medication?.genericName, date: dateString, listStatus: prescription.medication?.genericName ?? "")
    }
    
    // MARK: Lab Orders
    private static func genRecord(labOrder:  LaboratoryOrder) -> Record {
        let dateString = labOrder.timelineDateTime?.monthDayYearString
        let labTests = labOrder.labTests
      
        return Record(id: labOrder.id ?? UUID().uuidString, name: labOrder.patient?.name ?? "", type: .laboratoryOrder(model: labOrder, tests: labTests), status: labOrder.orderStatus, date: dateString, listStatus: "\(labOrder.laboratoryTests?.count ?? 0) tests")
    }
    
    // MARK: Immunization
    private static func genRecord(immunization: Immunization) -> Record {
        let dateString = immunization.dateOfImmunization?.monthDayYearString
        
        return Record(id: immunization.id ?? UUID().uuidString, name: immunization.patient?.name ?? "" , type: .immunization(model: immunization), status: immunization.status, date: dateString, listStatus: immunization.status ?? "")
      
    }
    
    // MARK: Health Visit
    private static func genRecord(healthVisit: HealthVisit) -> Record {
        let dateString = healthVisit.encounterDate?.monthDayYearString
        
        return Record(id: healthVisit.id ?? UUID().uuidString, name: healthVisit.clinic?.name ?? "" , type: .healthVisit(model: healthVisit), status: healthVisit.practitionerName, date: dateString, listStatus: healthVisit.practitionerName ?? "")
      
    }
    
    // MARK: Special Authority drug
    private static func genRecord(specialAuthorityDrug: SpecialAuthorityDrug) -> Record {
        let dateString = specialAuthorityDrug.requestedDate?.monthDayYearString
        
        return Record(id: specialAuthorityDrug.referenceNumber ?? UUID().uuidString, name: specialAuthorityDrug.patient?.name ?? "" , type: .specialAuthorityDrug(model: specialAuthorityDrug), status: specialAuthorityDrug.requestStatus, date: dateString, listStatus: specialAuthorityDrug.requestStatus ?? "")
      
    }
}

