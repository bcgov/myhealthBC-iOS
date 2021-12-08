//
//  HealthRecordsDetailDateSource.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-11-30.
// NOTE: This model is used in the health records flow

import UIKit

/**
 /// Setup cell for a Vaccine Record
 /// - Parameter model: Local Model
 func setup(vaccinePassport model: LocallyStoredVaccinePassportModel) {
     self.bannerView = createView()
     let statusImage: UIImage? = model.status == .fully ? UIImage(named: "check-mark") : nil
     let textColor = UIColor.white
     let backgroundColor = model.status.getColor
     let statusColor = textColor
     let date = Date.init(timeIntervalSince1970: model.issueDate)
     let issueDate = "Issued on: \(date.yearMonthDayString)"
     bannerView?.setup(in: self,
                       type: .VaccineRecord,
                       name: model.name,
                       status: model.status.getTitle,
                       date: issueDate,
                       backgroundColor: backgroundColor,
                       textColor: textColor,
                       statusColor: statusColor,
                       statusIconImage: statusImage)
 }
 
 /// Setup for test results
 /// - Parameter model: Local Model
 func setup(testResult model: TestResult) {
     self.bannerView = createView()
     let textColor = UIColor.black
     let backgroundColor = model.status.getColor
     let statusColor = model.status.getStatusTextColor
     var issueDate = ""
     if let date = model.collectionDateTime {
         issueDate = "Tested on: \(date.yearMonthDayString)"
     }
     
     bannerView?.setup(in: self,
                       type: .CovidTest,
                       name: model.patientDisplayName ?? "",
                       status: model.status.getTitle,
                       date: issueDate,
                       backgroundColor: backgroundColor,
                       textColor: textColor,
                       statusColor: statusColor,
                       statusIconImage: nil)
     
 }
 */

struct HealthRecordsDetailDataSource {
    struct Record {
        enum RecordType {
            case covidImmunizationRecord(model: LocallyStoredVaccinePassportModel, immunizations: [ImmunizationRecord])
            case covidTestResultRecord(model: TestResult)
        }
        let name: String
        let type: RecordType
        let status: String
        let date: String?
        let fields: [[TextListModel]]
        
    }
    enum RecordType {
        case covidImmunizationRecord(model: LocallyStoredVaccinePassportModel, immunizations: [ImmunizationRecord])
        case covidTestResultRecord(model: CovidLabTestResult)
    }
    
    let type: RecordType
    let title: String
    let detailNavTitle: String
    let image: UIImage?
    let records: [Record]
    let name: String
    
    
    init(type: RecordType) {
        self.type = type
        self.records = HealthRecordsDetailDataSource.genRecords(type: type)
        switch type {
        case .covidImmunizationRecord(let model, _):
            title = .covid19mRNATitle
            detailNavTitle = .vaccinationRecord
            name = model.name
            image = UIImage(named: "blue-bg-vaccine-record-icon")
        case .covidTestResultRecord(let model):
            title = .covid19mRNATitle
            detailNavTitle = .covid19TestResultTitle
            name = model.resultArray.first?.patientDisplayName ?? ""
            image = UIImage(named: "blue-bg-test-result-icon")
        }
    }
    
    private static func genRecords(type: RecordType)-> [Record] {
        var result: [Record] = []
        
        switch type {
        case .covidImmunizationRecord(let model, let immunizations):
            let status: String = model.status.getTitle
            let date: String? = model.vaxDates.last
            let product = Constants.vaccineInfo(snowMedCode: 1)?.displayName ?? ""
            var fields: [[TextListModel]] = []
            for (index, imsModel) in immunizations.enumerated() {
                let product = Constants.vaccineInfo(snowMedCode: 1)?.displayName ?? ""
                let imsSet = [
                    TextListModel(header: TextListModel.TextProperties(text: "Dose \(index + 1)", bolded: true), subtext: nil),
                    // TODO: date format
                    TextListModel(header: TextListModel.TextProperties(text: "Date:", bolded: false), subtext: TextListModel.TextProperties(text: imsModel.date?.fullString ?? "", bolded: true)),
                    TextListModel(header: TextListModel.TextProperties(text: "Product:", bolded: false), subtext: TextListModel.TextProperties(text: product, bolded: true)),
                    TextListModel(header: TextListModel.TextProperties(text: "Provide / Clinic:", bolded: false), subtext: TextListModel.TextProperties(text: imsModel.provider ?? "", bolded: true)),
                    TextListModel(header: TextListModel.TextProperties(text: "Lot Number:", bolded: false), subtext: TextListModel.TextProperties(text: imsModel.lotNumber ?? "", bolded: true))
                ]
                fields.append(imsSet)
            }
            //            fields.append(imsSet)
            result.append(Record(name: model.name, type: .covidImmunizationRecord(model: model, immunizations: immunizations), status: status, date: date, fields: fields))
        case .covidTestResultRecord(let model):
            for item in model.resultArray {
                let status: String = item.status.getTitle
                let date: String? = item.resultDateTime?.monthDayYearString
                var fields: [[TextListModel]] = []
                fields.append([
                    TextListModel(header: TextListModel.TextProperties(text: "Name", bolded: false), subtext: TextListModel.TextProperties(text: item.patientDisplayName ?? "", bolded: true)),
                    TextListModel(header: TextListModel.TextProperties(text: "Date of Testing", bolded: false), subtext: TextListModel.TextProperties(text: item.collectionDateTime?.monthDayYearString ?? "", bolded: true)),
                    TextListModel(header: TextListModel.TextProperties(text: "Test Status", bolded: false), subtext: TextListModel.TextProperties(text: item.status.getTitle, bolded: true)),
                    TextListModel(header: TextListModel.TextProperties(text: "Test Result", bolded: false), subtext: TextListModel.TextProperties(text: item.status.getTitle, bolded: true)),
                    TextListModel(header: TextListModel.TextProperties(text: "Type Name", bolded: false), subtext: TextListModel.TextProperties(text: item.testType ?? "", bolded: true)),
                    TextListModel(header: TextListModel.TextProperties(text: "Provider / Clinic:", bolded: false), subtext: TextListModel.TextProperties(text: item.lab ?? "", bolded: true))
                ])
                result.append(Record(name: item.patientDisplayName ?? "", type: .covidTestResultRecord(model: item), status: status, date: date, fields: fields))
            }
            
        }
        return result
    }
}

