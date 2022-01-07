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
        }
    }
    
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
        }
    }
    
    private static func genRecord(vaccineModel model: LocallyStoredVaccinePassportModel, immunizations: [ImmunizationRecord]) -> Record {
        let date: String? = model.vaxDates.last
        var fields: [[TextListModel]] = []
        for (index, imsModel) in immunizations.enumerated() {
            var stringDate = ""
            if let date = imsModel.date {
                let formatter = DateFormatter()
                formatter.dateFormat = "MMMM dd, yyyy"
                stringDate = formatter.string(from: date)
            }
            let product = Constants.vaccineInfo(snowMedCode: Int(imsModel.snomed ?? "1") ?? 1)?.displayName ?? ""
            let imsSet = [
                TextListModel(header: TextListModel.TextProperties(text: "Dose \(index + 1)", bolded: true), subtext: nil),
                // TODO: date format
                TextListModel(header: TextListModel.TextProperties(text: "Date:", bolded: false), subtext: TextListModel.TextProperties(text: stringDate, bolded: true)),
                TextListModel(header: TextListModel.TextProperties(text: "Product:", bolded: false), subtext: TextListModel.TextProperties(text: product, bolded: true)),
                TextListModel(header: TextListModel.TextProperties(text: "Provide / Clinic:", bolded: false), subtext: TextListModel.TextProperties(text: imsModel.provider ?? "N/A", bolded: true)),
                TextListModel(header: TextListModel.TextProperties(text: "Lot number:", bolded: false), subtext: TextListModel.TextProperties(text: imsModel.lotNumber ?? "N/A", bolded: true))
            ]
            fields.append(imsSet)
        }
        return Record(id: model.md5Hash() ?? UUID().uuidString, name: model.name, type: .covidImmunizationRecord(model: model, immunizations: immunizations), status: nil, date: date, fields: fields)
    }
    
    
    private static func genRecord(testResult: TestResult, parentResult: CovidLabTestResult) -> Record {
        let status: String = testResult.resultType.getTitle
        let date: String? = testResult.resultDateTime?.monthDayYearString
        var fields: [[TextListModel]] = []
        fields.append([
            TextListModel(header: TextListModel.TextProperties(text: "Date of Testing:", bolded: false), subtext: TextListModel.TextProperties(text: testResult.collectionDateTime?.issuedOnDateTime ?? "", bolded: true)),
            TextListModel(header: TextListModel.TextProperties(text: "Test Status:", bolded: false), subtext: TextListModel.TextProperties(text: testResult.testStatus ?? "Pending", bolded: true)),
            TextListModel(header: TextListModel.TextProperties(text: "Type Name:", bolded: false), subtext: TextListModel.TextProperties(text: testResult.testType ?? "", bolded: true)),
            TextListModel(header: TextListModel.TextProperties(text: "Provider / Clinic:", bolded: false), subtext: TextListModel.TextProperties(text: testResult.lab ?? "", bolded: true))
        ])
        return Record(id: testResult.id ?? UUID().uuidString, name: testResult.patientDisplayName ?? "", type: .covidTestResultRecord(model: testResult), status: status, date: date, fields: fields)
    }
}

