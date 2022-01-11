//
//  StorageService+Immunizations.swift
//  BCVaccineCard
//
//  Created by Amir on 2021-12-01.
//

import Foundation
import Foundation
import BCVaccineValidator

//fileprivate extension String {
//    func vaxDate() -> Date? {
//        let dateFormatter = Date.Formatter.yearMonthDay
//        return dateFormatter.date(from:self)
//    }
//}
//
//extension StorageService {
//    
//    func createImmunizationRecords(for card: VaccineCard, completion: @escaping([ImmunizationRecord])->Void) {
//        guard let qrCode = card.code, let context = managedContext else {return completion([])}
//        BCVaccineValidator.shared.validate(code: qrCode) { result in
//            guard let result = result.result else {return}
//            var immunizations: [ImmunizationRecord] = []
//            for record in result.immunizations {
//                let model = ImmunizationRecord(context: context)
//                model.snomed = record.snomed
//                if let dateString = record.date, let date = Date.Formatter.yearMonthDay.date(from: dateString) {
//                    model.date = date
//                }
//                model.provider = record.provider
//                model.lotNumber = record.lotNumber
//                model.date = record.date?.vaxDate()
//                model.snomed = record.snomed
//                model.vaccineCard = card
//                immunizations.append(model)
//            }
//        }
//    }
//    
//    func storeImmunizaionRecords(in card: VaccineCard, completion: @escaping([ImmunizationRecord])->Void) {
//        guard let qrCode = card.code else {return}
//        BCVaccineValidator.shared.validate(code: qrCode) { result in
//            guard let result = result.result else {return}
//            var immunizations: [ImmunizationRecord] = []
//            for record in result.immunizations {
//                if let storedObject = self.storeImmunizationRecord(record: record, card: card) {
//                    immunizations.append(storedObject)
//                }
//            }
//        }
//    }
//    
//    fileprivate func storeImmunizationRecord(record: COVIDImmunizationRecord, card: VaccineCard) -> ImmunizationRecord? {
//        guard let context = managedContext else {return nil}
//        let model = ImmunizationRecord(context: context)
//        model.snomed = record.snomed
//        if let dateString = record.date, let date = Date.Formatter.yearMonthDay.date(from: dateString) {
//            model.date = date
//        }
//        model.provider = record.provider
//        model.lotNumber = record.lotNumber
//        model.date = record.date?.vaxDate()
//        model.snomed = record.snomed
//        model.vaccineCard = card
//        do {
//            try context.save()
//            notify(event: StorageEvent(event: .Save, entity: .ImmunizationRecord, object: model))
//            return model
//        } catch let error as NSError {
//            print("Could not save. \(error), \(error.userInfo)")
//            return nil
//        }
//    }
//}
