//
//  StorageService+Immunizations.swift
//  BCVaccineCard
//
//  Created by Amir on 2021-12-01.
//

import Foundation
import Foundation
import BCVaccineValidator

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
    
    fileprivate func storeImmunizationRecord(record: immunizationRecord, card: VaccineCard) {
        guard let context = managedContext else {return}
        let model = ImmunizationRecord(context: context)
        // TODO: Add this field when its added to the payload
        model.snomed = record.snomed
        // TODO: format record.date and add here
        model.date = Date()
        model.provider = record.provider
        model.lotNumber = record.lotNumber
        model.vaccineCard = card
        do {
            try context.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
            return
        }
    }
}
