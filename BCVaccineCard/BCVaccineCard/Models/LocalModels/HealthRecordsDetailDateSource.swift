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
            case covidImmunizationRecord(model: LocallyStoredVaccinePassportModel, immunizations: [ImmunizationRecord])
            case covidTestResultRecord(model: TestResult)
            case medication(model: Perscription)
            case laboratoryOrder(model: [LaboratoryTest])
        }
        let id: String
        let name: String
        let type: RecordType
        let status: String?
        let date: String?
        let fields: [[TextListModel]]
        
    }
    enum RecordType {
        case covidImmunizationRecord(model: LocallyStoredVaccinePassportModel, immunizations: [ImmunizationRecord])
        case covidTestResultRecord(model: CovidLabTestResult)
        case medication(model: Perscription)
        case laboratoryOrder(model: LaboratoryOrder)
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
        case .covidImmunizationRecord(let model, _):
            return records.first
        case .covidTestResultRecord(let model):
            guard let mainResultModel = model.mainResult else {return nil}
            let record = HealthRecordsDetailDataSource.genRecord(testResult: mainResultModel, parentResult: model)
            return records.first(where: {$0.id == record.id})
        case .medication(model: let model):
            return records.first
        case .laboratoryOrder(model: let model):
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
            title = "Lab Test"
            detailNavTitle = "Lab test"
            name = model.patient?.name ?? ""
            image = UIImage(named: "blue-bg-laboratory-record-icon")
            deleteAlertTitle = "N/A" // Can't delete an authenticated lab result
            deleteAlertMessage = "Should not see this" // Showing for testing purposes
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
            let labTests = model.labTests
            result.append(genRecord(labTests: labTests))
            return result
        }
    }
    
    // MARK: Immunization Records
    private static func genRecord(vaccineModel model: LocallyStoredVaccinePassportModel, immunizations: [ImmunizationRecord]) -> Record {
        let date: String? = model.vaxDates.last
        var fields: [[TextListModel]] = []
        for (index, imsModel) in immunizations.enumerated() {
            var stringDate = ""
            if let date = imsModel.date {
                stringDate = date.issuedOnDate
            }
            let product = Constants.vaccineInfo(snowMedCode: Int(imsModel.snomed ?? "1") ?? 1)?.displayName ?? ""
            let imsSet = [
                TextListModel(header: TextListModel.TextProperties(text: "Dose \(index + 1)", bolded: true), subtext: nil),
                // TODO: date format
                TextListModel(header: TextListModel.TextProperties(text: "Date:", bolded: true), subtext: TextListModel.TextProperties(text: stringDate, bolded: false)),
                TextListModel(header: TextListModel.TextProperties(text: "Product:", bolded: true), subtext: TextListModel.TextProperties(text: product, bolded: false)),
                TextListModel(header: TextListModel.TextProperties(text: "Provide / Clinic:", bolded: true), subtext: TextListModel.TextProperties(text: imsModel.provider ?? "N/A", bolded: false)),
                TextListModel(header: TextListModel.TextProperties(text: "Lot number:", bolded: true), subtext: TextListModel.TextProperties(text: imsModel.lotNumber ?? "N/A", bolded: false))
            ]
            fields.append(imsSet)
        }
        let modifiedDate = Date.Formatter.yearMonthDay.date(from: date ?? "")?.monthDayYearString ?? date
        return Record(id: model.md5Hash() ?? UUID().uuidString, name: model.name, type: .covidImmunizationRecord(model: model, immunizations: immunizations), status: model.status.getTitle, date: modifiedDate, fields: fields)
    }
    
    // MARK: Covid Test Results
    private static func genRecord(testResult: TestResult, parentResult: CovidLabTestResult) -> Record {
        let status: String = testResult.resultType.getTitle
        let date: String? = testResult.resultDateTime?.monthDayYearString
        var fields: [[TextListModel]] = []
        fields.append([
            TextListModel(header: TextListModel.TextProperties(text: "Date of testing:", bolded: true), subtext: TextListModel.TextProperties(text: testResult.collectionDateTime?.issuedOnDate ?? "", bolded: false)),
            TextListModel(header: TextListModel.TextProperties(text: "Test status:", bolded: true), subtext: TextListModel.TextProperties(text: testResult.testStatus ?? "Pending", bolded: false)),
            TextListModel(header: TextListModel.TextProperties(text: "Type name:", bolded: true), subtext: TextListModel.TextProperties(text: testResult.testType ?? "", bolded: false)),
            TextListModel(header: TextListModel.TextProperties(text: "Provider / Clinic:", bolded: true), subtext: TextListModel.TextProperties(text: testResult.lab ?? "", bolded: false))
        ])
        if let resultDescription = testResult.resultDescription, !resultDescription.isEmpty {
            let tuple = self.handleResultDescriptionAndLinks(resultDescription: resultDescription, testResult: testResult)
            let resultDescriptionfield = TextListModel(header: TextListModel.TextProperties(text: "Result description:", bolded: true), subtext: TextListModel.TextProperties(text: tuple.text, bolded: false, links: tuple.links))
            fields[0].append(resultDescriptionfield)
        }
        return Record(id: testResult.id ?? UUID().uuidString, name: testResult.patientDisplayName ?? "", type: .covidTestResultRecord(model: testResult), status: status, date: date, fields: fields)
    }
    
    // Note this funcion is used to append "this page" text with link from API to end of result description. In the event where there is a positive test, there is no link, but there are links embedded in the text. For this, we use NSDataDetector to create links
    private static func handleResultDescriptionAndLinks(resultDescription: [String], testResult: TestResult) -> (text: String, links: [LinkedStrings]?) {
        var descriptionString = ""
        for (index, description) in resultDescription.enumerated() {
            descriptionString.append(description)
            if index < resultDescription.count - 1 {
                descriptionString.append("\n\n")
            }
        }
        if descriptionString.last != " " {
            descriptionString.append(" ")
        }
        var linkedStrings: [LinkedStrings]?
        if let link = testResult.resultLink, !link.isEmpty {
            let text = "this page"
            descriptionString.append(text)
            let linkedString = LinkedStrings(text: text, link: link)
            linkedStrings = []
            linkedStrings?.append(linkedString)
        }
        do {
            let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
            guard let matches = detector?.matches(in: descriptionString, options: [], range: NSRange(location: 0, length: descriptionString.utf16.count)) else { return (descriptionString, linkedStrings) }
            for match in matches {
                guard let range = Range(match.range, in: descriptionString) else { continue }
                let url = descriptionString[range]
                let linkString = String(url)
                let newLink = LinkedStrings(text: linkString, link: linkString)
                if linkedStrings == nil {
                    linkedStrings = []
                }
                linkedStrings?.append(newLink)
            }
        }
        return (descriptionString, linkedStrings)
    }
    
    // MARK: Medications
    private static func genRecord(prescription: Perscription) -> Record {
        let dateString = prescription.dispensedDate?.monthDayYearString
        
        var fields: [[TextListModel]] = []
        fields.append([
            TextListModel(header: TextListModel.TextProperties(text: "Practitioner:", bolded: true), subtext: TextListModel.TextProperties(text: prescription.practitionerSurname ?? "", bolded: false)),
            TextListModel(header: TextListModel.TextProperties(text: "Quantity:", bolded: true), subtext: TextListModel.TextProperties(text: String(prescription.medication?.quantity ?? 0), bolded: false)),
            TextListModel(header: TextListModel.TextProperties(text: "Strength:", bolded: true), subtext: TextListModel.TextProperties(text: (prescription.medication?.strength ?? "") + " " + (prescription.medication?.strengthUnit ?? ""), bolded: false)),
            TextListModel(header: TextListModel.TextProperties(text: "Form:", bolded: true), subtext: TextListModel.TextProperties(text: prescription.medication?.form ?? "", bolded: false)),
            TextListModel(header: TextListModel.TextProperties(text: "Manufacturer:", bolded: true), subtext: TextListModel.TextProperties(text: prescription.medication?.manufacturer ?? "", bolded: false)),
            TextListModel(header: TextListModel.TextProperties(text: "Din:", bolded: true), subtext: TextListModel.TextProperties(text: prescription.medication?.din ?? "", bolded: false)),
            TextListModel(header: TextListModel.TextProperties(text: "Filled at:", bolded: true), subtext: TextListModel.TextProperties(text: prescription.pharmacy?.name ?? "", bolded: false)),
            TextListModel(header: TextListModel.TextProperties(text: "Filled date:", bolded: true), subtext: TextListModel.TextProperties(text: dateString ?? "", bolded: false)),
            TextListModel(header: TextListModel.TextProperties(text: "Address:", bolded: true), subtext: TextListModel.TextProperties(text: prescription.pharmacy?.addressLine1 ?? "", bolded: false)),
            TextListModel(header: TextListModel.TextProperties(text: "Phone number:", bolded: true), subtext: TextListModel.TextProperties(text: prescription.pharmacy?.phoneNumber ?? "", bolded: false)),
            TextListModel(header: TextListModel.TextProperties(text: "Fax:", bolded: true), subtext: TextListModel.TextProperties(text: prescription.pharmacy?.faxNumber ?? "", bolded: false)),
            TextListModel(header: TextListModel.TextProperties(text: "Direction for use:", bolded: true), subtext: TextListModel.TextProperties(text: prescription.directions ?? "", bolded: false))
        ])
        
        // Notes:
        /// Unsure about status field - this is what it appears to be in designs though
        return Record(id: prescription.id ?? UUID().uuidString, name: prescription.patient?.name ?? "", type: .medication(model: prescription), status: prescription.medication?.genericName, date: dateString, fields: fields)
    }
    
    // MARK: Lab Orders
    private static func genRecord(labTests: [LaboratoryTest]) -> Record {
        let labOrder = labTests.first?.laboratoryOrder
        let dateString = labOrder?.collectionDateTime?.monthDayYearString
        var fields: [[TextListModel]] = []
        
        fields.append([
            TextListModel(header: TextListModel.TextProperties(text: "Collection date:", bolded: true), subtext: TextListModel.TextProperties(text: labOrder?.collectionDateTime?.labOrderDateTime ?? "", bolded: false)),
            TextListModel(header: TextListModel.TextProperties(text: "Ordering provider:", bolded: true), subtext: TextListModel.TextProperties(text: labOrder?.orderingProvider ?? "", bolded: false)),
            TextListModel(header: TextListModel.TextProperties(text: "Reporting Lab:", bolded: true), subtext: TextListModel.TextProperties(text: labOrder?.reportingSource ?? "", bolded: false))
        ])
        for (index, test) in labTests.enumerated() {
            let resultTuple = formatResultField(test: test)
            var section: [TextListModel] = [
                TextListModel(header: TextListModel.TextProperties(text: "Test name:", bolded: true), subtext: TextListModel.TextProperties(text: test.batteryType ?? "", bolded: false)),
                TextListModel(header: TextListModel.TextProperties(text: "Result:", bolded: true), subtext: TextListModel.TextProperties(text: resultTuple.text, bolded: resultTuple.bolded, textColor: resultTuple.color)),
                TextListModel(header: TextListModel.TextProperties(text: "Test status:", bolded: true), subtext: TextListModel.TextProperties(text: test.testStatus ?? "", bolded: false))
            ]
            if index == 0 {
                section.insert(TextListModel(header: TextListModel.TextProperties(text: "Test summary", bolded: true), subtext: nil), at: 0)
            }
            fields.append(section)
        }
        
        return Record(id: labOrder?.id ?? UUID().uuidString, name: labOrder?.patient?.name ?? "", type: .laboratoryOrder(model: labTests), status: "\(labOrder?.laboratoryTests?.count ?? 0) tests", date: dateString, fields: fields)
    }
    
    private static func formatResultField(test: LaboratoryTest) -> (text: String, color: TextListModel.TextProperties.CodableColors, bolded: Bool) {
        if test.testStatus == "Partial" || test.testStatus == "Cancelled" {
            return ("Pending", .black, false)
        } else {
            let text = test.outOfRange ? "Out of Range" : "In Range"
            let color: TextListModel.TextProperties.CodableColors = test.outOfRange ? .red : .green
            return (text, color, true)
        }
    }
}

