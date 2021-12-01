//
//  HealthRecordsDetailDateSource.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-11-30.
// NOTE: This model is used in the health records flow

import UIKit
import BCVaccineValidator

struct HealthRecordsDetailDataSource {
    enum RecordType {
        case covidImmunizationRecord(model: LocallyStoredVaccinePassportModel, immunizations: [CovidImmunizationRecord])
        case covidTestResult(model: LocallyStoredCovidTestResultModel)
        
        var getTitle: String {
            switch self {
            case .covidImmunizationRecord: return .covid19mRNATitle
            case .covidTestResult: return .covid19TestResultTitle
            }
        }
        
        var getDetailNavTitle: String {
            switch self {
            case .covidImmunizationRecord: return .vaccinationRecord
            case .covidTestResult: return .covid19TestResultTitle
            }
        }
        
        var getStatus: String {
            switch self {
            case .covidImmunizationRecord(let model, _): return model.status.getTitle
            case .covidTestResult(let model): return model.status.getTitle
            }
        }
        
        var getDate: String? {
            switch self {
            case .covidImmunizationRecord(let model, _): return model.vaxDates.last
            case .covidTestResult(let model): return model.response?.resultDateTime?.monthDayYearString // TODO: Need to confirm formatting on this
            }
        }
        
        var getImage: UIImage? {
            switch self {
            case .covidImmunizationRecord: return UIImage(named: "blue-bg-vaccine-record-icon")
            case .covidTestResult: return UIImage(named: "blue-bg-test-result-icon")
            }
        }
    }
    
    let type: RecordType
    
    var sortingDate: Double {
        switch type {
        case .covidImmunizationRecord(let model, _): return model.issueDate
        case .covidTestResult(let model): return model.response?.collectionDateTime?.timeIntervalSince1970 ?? Date().timeIntervalSince1970 // TODO: Should likely do something else here
        }
    }
    
    var getTextSets: [[TextListModel]] {
        var set: [[TextListModel]] = []
        switch type {
        case .covidTestResult(let model):
            // TODO: Put in strings file
            let testSet = [
                TextListModel(header: TextListModel.TextProperties(text: "Name", bolded: false), subtext: TextListModel.TextProperties(text: model.response?.patientDisplayName ?? "", bolded: true)),
                TextListModel(header: TextListModel.TextProperties(text: "Date of Testing", bolded: false), subtext: TextListModel.TextProperties(text: model.response?.collectionDateTime?.monthDayYearString ?? "", bolded: true)),
                TextListModel(header: TextListModel.TextProperties(text: "Test Status", bolded: false), subtext: TextListModel.TextProperties(text: model.status.getTitle ?? "", bolded: true)),
                TextListModel(header: TextListModel.TextProperties(text: "Test Result", bolded: false), subtext: TextListModel.TextProperties(text: model.status.getTitle ?? "", bolded: true)),
                TextListModel(header: TextListModel.TextProperties(text: "Type Name", bolded: false), subtext: TextListModel.TextProperties(text: model.response?.testType ?? "", bolded: true)),
                TextListModel(header: TextListModel.TextProperties(text: "Provider / Clinic:", bolded: false), subtext: TextListModel.TextProperties(text: model.response?.lab ?? "", bolded: true))
            ]
            set.append(testSet)
            return set
        case .covidImmunizationRecord(let model, let immunizations):
            for (index, imsModel) in immunizations.enumerated() {
                let imsSet = [
                    TextListModel(header: TextListModel.TextProperties(text: "Dose \(index + 1)", bolded: true), subtext: nil),
                    TextListModel(header: TextListModel.TextProperties(text: "Date:", bolded: false), subtext: TextListModel.TextProperties(text: imsModel.date ?? "", bolded: true)),
                    TextListModel(header: TextListModel.TextProperties(text: "Product:", bolded: false), subtext: TextListModel.TextProperties(text: imsModel.vaccineCode ?? "", bolded: true)),
                    TextListModel(header: TextListModel.TextProperties(text: "Provide / Clinic:", bolded: false), subtext: TextListModel.TextProperties(text: imsModel.provider ?? "", bolded: true)),
                    TextListModel(header: TextListModel.TextProperties(text: "Lot Number:", bolded: false), subtext: TextListModel.TextProperties(text: imsModel.lotNumber ?? "", bolded: true))
                ]
                set.append(imsSet)
            }
            return set
        }
    }
}

