//
//  StorageService+Immunizations.swift
//  BCVaccineCard
//
//  Created by Amir on 2021-12-01.
//

import Foundation
import Foundation
import BCVaccineValidator

fileprivate extension String {
    func vaxDate() -> Date? {
        let dateFormatter = Date.Formatter.yearMonthDay
        return dateFormatter.date(from:self)
    }
}

extension StorageService {
    
    func storeImmunizaionRecords(card: VaccineCard) {
        guard let qrCode = card.code else {return}
        BCVaccineValidator.shared.validate(code: qrCode) { result in
            guard let result = result.result else {return}
            for record in result.immunizations {
                self.storeImmunizationRecord(record: record, card: card)
            }
        }
    }
    
    fileprivate func storeImmunizationRecord(record: COVIDImmunizationRecord, card: VaccineCard) {
        guard let context = managedContext else {return}
        let model = ImmunizationRecord(context: context)
        // TODO: Add this field when its added to the payload
        model.snomed = record.snomed
        // TODO: format record.date and add here
        model.date = Date()
        model.provider = record.provider
        model.lotNumber = record.lotNumber
        model.date = record.date?.vaxDate()
        model.snomed = record.snomed
        model.vaccineCard = card
        do {
            try context.save()
            notify(event: StorageEvent(event: .Save, entity: .ImmunizationRecord, object: model))
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
            return
        }
    }
}
