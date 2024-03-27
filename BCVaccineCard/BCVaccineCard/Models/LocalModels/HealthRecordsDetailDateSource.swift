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
            case hospitalVisit(model: HospitalVisit)
            case clinicalDocument(model: ClinicalDocument)
            case diagnosticImaging(model: DiagnosticImaging)
            case cancerScreening(model: CancerScreening)
            case note(model: Note)
        }
        let id: String
        let name: String
        let type: RecordType
        let status: String?
        let date: String?
        let listStatus: String
        let commentID: String?
        let title: String?
        
        var displayable: Bool {
            switch type {
            case .hospitalVisit, .clinicalDocument:
                return title != nil
            default:
                return (title != nil) && (date != nil)
            }
        }
        
        var titleError: Bool {
            return title == nil
        }
        
        var dateParsingError: Bool {
            switch type {
            case .hospitalVisit, .clinicalDocument:
                return false
            default:
                return date == nil
            }
        }
        
        var comments: [Comment] {
            switch type {
            case .covidImmunizationRecord:
                return []
            case .covidTestResultRecord(let covidTestResultRecord):
                return covidTestResultRecord.parentTest?.commentsArray ?? []
            case .medication(let medication):
                return medication.commentsArray
            case .laboratoryOrder(let laboratoryOrder, _):
                return laboratoryOrder.commentsArray
            case .immunization:
                return []
            case .healthVisit(let healthVisit):
                return healthVisit.commentsArray
            case .specialAuthorityDrug(let specialAuthorityDrug):
                return specialAuthorityDrug.commentsArray
            case .hospitalVisit(model: let model):
                return model.commentsArray
            case .clinicalDocument(model: let model):
                return model.commentsArray
            case .diagnosticImaging(model: let model):
                return model.commentsArray
            case .cancerScreening(model: let model):
                return model.commentsArray
            case .note(model: let model):
                return []
            }
        }
        
        var includesSeparatorUI: Bool {
            switch self.type {
            case .covidImmunizationRecord, .covidTestResultRecord, .laboratoryOrder, .immunization: return true
            case .medication, .specialAuthorityDrug, .healthVisit, .hospitalVisit, .clinicalDocument, .diagnosticImaging, .cancerScreening, .note: return false
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
        case hospitalVisit(model: HospitalVisit)
        case clinicalDocument(model:ClinicalDocument)
        case diagnosticImaging(model: DiagnosticImaging)
        case cancerScreening(model: CancerScreening)
        case note(model: Note)
    }
    
    let id: String?
    let name: String
    let type: RecordType
    let title: String
    let detailNavTitle: String
    let image: UIImage?
    
    let records: [Record]
    
//    let shouldDisplay: Bool
    
    
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
        case .hospitalVisit(model: let model):
            return records.first
        case .clinicalDocument(model: let model):
            return records.first
        case .diagnosticImaging(model: let model):
            return records.first
        case .cancerScreening(model: let model):
            return records.first
        case .note:
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
        case .hospitalVisit(model: let model):
            return model.authenticated
        case .clinicalDocument(model: let model):
            return model.authenticated
        case .diagnosticImaging(model: let model):
            // Pretty sure we can't get diagnostic reports without being authenticated
            return true
        case .cancerScreening(model: let model):
            return true
        case .note(model: let model):
            return true
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
                .immunization,
                .hospitalVisit,
                .clinicalDocument,
                .diagnosticImaging,
                .cancerScreening,
                .note:
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
//            detailNavTitle = .vaccinationRecord
            detailNavTitle = .covid19vaccination
            name = model.name
            image = UIImage(named: "blue-bg-vaccine-record-icon")
            deleteAlertTitle = .deleteRecord
            deleteAlertMessage = .deleteCovidHealthRecord
        case .covidTestResultRecord(let model):
            id = model.id
            title = .covid19TestResultTitle
            detailNavTitle = .covid19TestResultTitle
            name = model.resultArray.first?.patientDisplayName ?? "-"
            image = UIImage(named: "blue-bg-laboratory-record-icon")
            deleteAlertTitle = .deleteTestResult
            deleteAlertMessage = .deleteTestResultMessage
        case .medication(model: let model):
            id = model.id
            title = model.medication?.brandName ?? "Statins"
            detailNavTitle = model.medication?.brandName ?? "Statins"
            name = model.patient?.name ?? "-"
            image = UIImage(named: "blue-bg-medication-record-icon")
            deleteAlertTitle = "N/A" // Note: We can't delete an auth medical record, so this won't be necessary
            deleteAlertMessage = "Shouldn't see this" // Showing these values for testing purposes
        case .laboratoryOrder(model: let model):
            id = model.id
            title = model.commonName ?? "-"
//            detailNavTitle = "Lab test"
            detailNavTitle = model.commonName ?? "-"
            name = model.patient?.name ?? "-"
            image = UIImage(named: "blue-bg-test-result-icon")
            deleteAlertTitle = "N/A" // Can't delete an authenticated lab result
            deleteAlertMessage = "Should not see this" // Showing for testing purposes
            
        case .immunization(model: let model):
            id = model.id
            title = model.immunizationDetails?.name ?? "-"
            detailNavTitle = model.immunizationDetails?.name ?? "-"
            name = model.patient?.name ?? "-"
            image = UIImage(named: "blue-bg-vaccine-record-icon")
            deleteAlertTitle = "N/A" // Can't delete an authenticated Immunization
            deleteAlertMessage = "Should not see this" // Showing for testing purposes
            
        case .healthVisit(model: let model):
            id = model.id
            title = model.specialtyDescription ?? "-"
//            detailNavTitle = model.clinic?.name ?? "-"
            detailNavTitle = model.specialtyDescription ?? "-"
            name = model.patient?.name ?? "-"
            image = UIImage(named: "blue-bg-health-visit-icon")
            deleteAlertTitle = "N/A" // Can't delete an authenticated Immunization
            deleteAlertMessage = "Should not see this" // Showing for testing purposes
            
        case .specialAuthorityDrug(model: let model):
            id = model.referenceNumber
            title = model.drugName ?? "-"
            detailNavTitle = model.drugName ?? "-"
            name = model.patient?.name ?? "-"
            image = UIImage(named: "blue-bg-special-authority-icon")
            deleteAlertTitle = "N/A" // Can't delete an authenticated Immunization
            deleteAlertMessage = "Should not see this" // Showing for testing purposes
        case .hospitalVisit(model: let model):
            // TODO: Confirm data
            id = model.encounterID
            title = model.facility ?? "-"
            detailNavTitle = model.facility ?? "-"
            name = model.patient?.name ?? "-"
            image = UIImage(named: "blue-bg-hospital-visits-icon")
            
            deleteAlertTitle = "N/A" // Can't delete an authenticated Immunization
            deleteAlertMessage = "Should not see this" // Showing for testing purposes
            // No Date check here
        case .clinicalDocument(model: let model):
            // TODO: Confirm data
            id = model.id
            title = model.name ?? "-"
            detailNavTitle = model.name ?? "-"
            name = model.patient?.name ?? "-"
            image = UIImage(named: "blue-bg-clinical-documents-icon")
            
            deleteAlertTitle = "N/A" // Can't delete an authenticated Immunization
            deleteAlertMessage = "Should not see this" // Showing for testing purposes
            // No Date check here
        case .diagnosticImaging(model: let model):
            id = model.id
            title = model.modality ?? "-"
            detailNavTitle = model.modality ?? "_"
            name = model.patient?.name ?? "-"
            image = UIImage(named: "blue-bg-diagnostic-imaging-icon")
            
            deleteAlertTitle = "N/A" // Can't delete an authenticated Immunization
            deleteAlertMessage = "Should not see this" // Showing for testing purposes
        case .cancerScreening(model: let model):
            id = model.id
            let text = model.eventType == "Result" ? "BC Cancer Screening Result Letter" : "BC Cancer Screening Reminder Letter"
            title = text
            let detailText = model.eventType == "Result" ? "BC Cancer screening result letter" : "BC Cancer screening reminder letter"
            detailNavTitle = detailText
            name = model.patient?.name ?? "-"
            image = UIImage(named: "blue-bg-cancer-screening-icon")
            
            deleteAlertTitle = "N/A" // Can't delete an authenticated Immunization
            deleteAlertMessage = "Should not see this" // Showing for testing purposes
        case .note(model: let model):
            id = model.id
            title = model.title ?? "-"
//            detailNavTitle = ""
            detailNavTitle = model.title ?? "-"
            name = model.createdBy ?? "-" // NOTE: This is HDID
            image = UIImage(named: "blue-bg-notes-icon")
            
            deleteAlertTitle = "N/A"
            deleteAlertMessage = "Should not see this"
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
        case .hospitalVisit(model: let model):
            result.append(genRecord(hospitalVisit: model))
            return result
        case .clinicalDocument(model: let model):
            result.append(genRecord(clinicalDocument: model))
            return result
        case .diagnosticImaging(model: let model):
            result.append(genRecord(diagnosticImaging: model))
            return result
        case .cancerScreening(model: let model):
            result.append(genRecord(cancerScreening: model))
            return result
        case . note(model: let model):
            result.append(genRecord(note: model))
            return result
        }
    }
    
    // MARK: Immunization Records
    private static func genRecord(vaccineModel model: LocallyStoredVaccinePassportModel, immunizations: [CovidImmunizationRecord]) -> Record {
        let date: String? = model.vaxDates.last
        let modifiedDate = Date.Formatter.yearMonthDay.date(from: date ?? "")?.monthDayYearString ?? date
        return Record(id: model.md5Hash() ?? UUID().uuidString, name: model.name, type: .covidImmunizationRecord(model: model, immunizations: immunizations), status: model.status.getTitle, date: modifiedDate, listStatus: model.status.getTitle, commentID: "-", title: .covid19vaccination)
    }
    
    // MARK: Covid Test Results
    private static func genRecord(testResult: TestResult, parentResult: CovidLabTestResult) -> Record {
        let status: String = testResult.resultType.getTitle
        let date: String? = testResult.collectionDateTime?.monthDayYearString
        return Record(id: testResult.id ?? UUID().uuidString, name: testResult.patientDisplayName ?? "", type: .covidTestResultRecord(model: testResult), status: status, date: date, listStatus: status, commentID: parentResult.orderId, title: .covid19TestResultTitle)
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
        return Record(id: prescription.id ?? UUID().uuidString, name: prescription.patient?.name ?? "", type: .medication(model: prescription), status: prescription.medication?.genericName, date: dateString, listStatus: prescription.medication?.genericName ?? "", commentID: prescription.prescriptionIdentifier, title: prescription.medication?.brandName ?? "Statins")
    }
    
    // MARK: Lab Orders
    private static func genRecord(labOrder:  LaboratoryOrder) -> Record {
        let dateString = labOrder.timelineDateTime?.monthDayYearString
        let labTests = labOrder.labTests
        
        return Record(id: labOrder.id ?? UUID().uuidString, name: labOrder.patient?.name ?? "", type: .laboratoryOrder(model: labOrder, tests: labTests), status: labOrder.orderStatus, date: dateString, listStatus: "\(labOrder.laboratoryTests?.count ?? 0) \(String.tests)", commentID: labOrder.labPdfId, title: labOrder.commonName)
    }
    
    // MARK: Immunization
    private static func genRecord(immunization: Immunization) -> Record {
        let dateString = immunization.dateOfImmunization?.monthDayYearString
        
        return Record(id: immunization.id ?? UUID().uuidString, name: immunization.patient?.name ?? "" , type: .immunization(model: immunization), status: immunization.status, date: dateString, listStatus: immunization.status ?? "", commentID: "imm", title: immunization.immunizationDetails?.name)
        
    }
    
    // MARK: Health Visit
    private static func genRecord(healthVisit: HealthVisit) -> Record {
        let dateString = healthVisit.encounterDate?.monthDayYearString
        
        return Record(id: healthVisit.id ?? UUID().uuidString, name: healthVisit.clinic?.name ?? "" , type: .healthVisit(model: healthVisit), status: healthVisit.practitionerName, date: dateString, listStatus: healthVisit.practitionerName ?? "", commentID: healthVisit.id, title: healthVisit.specialtyDescription)
        
    }
    
    // MARK: Special Authority drug
    private static func genRecord(specialAuthorityDrug: SpecialAuthorityDrug) -> Record {
        let dateString = specialAuthorityDrug.requestedDate?.monthDayYearString
        
        return Record(id: specialAuthorityDrug.referenceNumber ?? UUID().uuidString, name: specialAuthorityDrug.patient?.name ?? "" , type: .specialAuthorityDrug(model: specialAuthorityDrug), status: specialAuthorityDrug.requestStatus, date: dateString, listStatus: specialAuthorityDrug.requestStatus ?? "", commentID: specialAuthorityDrug.referenceNumber, title: specialAuthorityDrug.drugName)
        
    }
    
    // MARK: Hospital Visit
    private static func genRecord(hospitalVisit: HospitalVisit) -> Record {
        let dateString = hospitalVisit.admitDateTime?.monthDayYearString
        // TODO: confirm data
        return Record(id: hospitalVisit.encounterID ?? UUID().uuidString, name: hospitalVisit.healthService ?? "", type: .hospitalVisit(model: hospitalVisit), status: hospitalVisit.facility, date: dateString, listStatus: hospitalVisit.visitType ?? "", commentID: hospitalVisit.encounterID, title: hospitalVisit.facility)
        
    }
    
    // MARK: Clinical Documment
    private static func genRecord(clinicalDocument: ClinicalDocument) -> Record {
        let dateString = clinicalDocument.serviceDate?.monthDayYearString
        // TODO: confirm data
        return Record(id: clinicalDocument.id ?? UUID().uuidString, name: clinicalDocument.name ?? "", type: .clinicalDocument(model: clinicalDocument), status: clinicalDocument.type, date: dateString, listStatus: clinicalDocument.type ?? "", commentID: clinicalDocument.id, title: clinicalDocument.name)
        
    }
    
    // MARK: Diagnostic Imaging
    private static func genRecord(diagnosticImaging: DiagnosticImaging) -> Record {
        let dateString = diagnosticImaging.examDate?.monthDayYearString
        var status = ""
        if diagnosticImaging.isObjectUpdated == true {
            status = "Updated"
        }
        return Record(id: diagnosticImaging.id ?? UUID().uuidString, name: diagnosticImaging.modality ?? "", type: .diagnosticImaging(model: diagnosticImaging), status: status, date: dateString, listStatus: status, commentID: diagnosticImaging.id, title: diagnosticImaging.modality)
    }
    
    // MARK: Cancer Screening
    private static func genRecord(cancerScreening: CancerScreening) -> Record {
        // Note: Having to convert date to PST statically (done on the date itself in Storage save)
        let dateString = cancerScreening.eventType == "Result" ? cancerScreening.resultDateTime?.monthDayYearString : cancerScreening.eventDateTime?.monthDayYearString
        var status = cancerScreening.programName ?? ""
        
        let text = cancerScreening.eventType == "Result" ? "BC Cancer Screening Result Letter" : "BC Cancer Screening Reminder Letter"

        return Record(id: cancerScreening.id ?? UUID().uuidString, name: cancerScreening.itemType ?? "", type: .cancerScreening(model: cancerScreening), status: status, date: dateString, listStatus: status, commentID: cancerScreening.id, title: text)
    }
    
    // MARK: Note
    private static func genRecord(note: Note) -> Record {
        let dateString = note.journalDate?.yearMonthStringDayString
        // TODO: confirm data
        return Record(id: note.id ?? UUID().uuidString, name: note.title ?? "", type: .note(model: note), status: "", date: dateString, listStatus: "", commentID: note.id, title: note.title)
    }
}
