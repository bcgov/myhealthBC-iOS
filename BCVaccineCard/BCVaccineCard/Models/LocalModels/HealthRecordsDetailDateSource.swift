//
//  HealthRecordsDetailDateSource.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-11-30.
// NOTE: This model is used in the health records flow

import UIKit

struct HealthRecordsDetailDataSource {
    enum RecordType {
        case covidImmunizationRecord(model: LocallyStoredVaccinePassportModel)
        case covidTestResult(model: LocallyStoredCovidTestResultModel)
        
        var getTitle: String {
            switch self {
            case .covidImmunizationRecord: return .covid19mRNATitle
            case .covidTestResult: return .covid19TestResultTitle
            }
        }
        
        var getStatus: String {
            switch self {
            case .covidImmunizationRecord(let model): return model.status.getTitle
            case .covidTestResult(let model): return model.status.getTitle
            }
        }
        
        var getDate: String? {
            switch self {
            case .covidImmunizationRecord(let model): return model.vaxDates.last
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
    
    // TODO: Create data source here
    let type: RecordType
    
    var sortingDate: Double {
        switch type {
        case .covidImmunizationRecord(let model): return model.issueDate
        case .covidTestResult(let model): return model.response?.collectionDateTime?.timeIntervalSince1970 ?? Date().timeIntervalSince1970 // TODO: Should likely do something else here
        }
    }
    
    var getTextSets: [[TextListModel]] {
        var set: [[TextListModel]] = []
        switch type {
        case .covidTestResult(let model):
//            let testSet = [
//                TextListModel(header: TextListModel.TextProperties(text: <#T##String#>, bolded: <#T##Bool#>), subtext: TextListModel.TextProperties(text: <#T##String#>, bolded: <#T##Bool#>))
//            ]
            print("TODO")
            return set
        case .covidImmunizationRecord(let model):
            // TODO: Basically, we will be getting each immunization record, creating an array of TextListModel, then adding each one to the set (which is array of array of TextListModel)
//            for immunizationRecord in model.immunizations {
//                // setup here
//            }
            print("TODO")
            return set
        }
    }
}

