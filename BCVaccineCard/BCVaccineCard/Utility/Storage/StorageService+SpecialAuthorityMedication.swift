//
//  StorageService+SpecialAuthorityMedication.swift
//  HealthGatewayTest
//
//  Created by Amir on 2022-07-12.
//

import Foundation

extension StorageService {
    func getGatewayDate(from dateString: String?) -> Date? {
        let formatted: Date?
        if let timezoneDate = Date.Formatter.gatewayDateAndTimeWithTimeZone.date(from: dateString ?? "") {
            formatted = timezoneDate
        } else if let nozoneDate = Date.Formatter.gatewayDateAndTime.date(from: dateString ?? "") {
            formatted = nozoneDate
        } else {
            formatted = nil
        }
        return formatted
    }
}
protocol StorageSpecialAuthorityMedicationManager {
    // MARK: Store
    func storeSpecialAuthorityMedication(
        patient: Patient,
        object: AuthenticatedSpecialAuthorityDrugsResponseModel.SpecialAuthorityDrug,
        authenticated: Bool
    ) -> SpecialAuthorityDrug?
    

    // MARK: Fetch
    func fetchSpecialAuthorityMedications()-> [SpecialAuthorityDrug]
}
extension StorageService: StorageSpecialAuthorityMedicationManager {
    func storeSpecialAuthorityMedication(patient: Patient, object: AuthenticatedSpecialAuthorityDrugsResponseModel.SpecialAuthorityDrug, authenticated: Bool) -> SpecialAuthorityDrug? {
        
        return storeSpecialAuthorityMedication(authenticated: authenticated, referenceNumber: object.requestedDate, drugName: object.drugName, requestStatus: object.requestStatus, prescriberFirstName: object.prescriberFirstName, prescriberLastName: object.prescriberLastName, requestedDate: getGatewayDate(from: object.requestedDate), effectiveDate: getGatewayDate(from: object.effectiveDate), expiryDate: getGatewayDate(from: object.expiryDate), patient: patient)
    }
    
    private func storeSpecialAuthorityMedication(
    authenticated: Bool,
    referenceNumber: String?,
    drugName: String?,
    requestStatus: String?,
    prescriberFirstName: String?,
    prescriberLastName: String?,
    requestedDate: Date?,
    effectiveDate: Date?,
    expiryDate: Date?,
    patient: Patient?) -> SpecialAuthorityDrug? {
        guard let context = managedContext else {return nil}
        let object = SpecialAuthorityDrug(context: context)
        object.authenticated = authenticated
        object.referenceNumber = referenceNumber
        object.drugName = drugName
        object.requestStatus = requestStatus
        object.prescriberFirstName = prescriberFirstName
        object.prescriberLastName = prescriberLastName
        object.requestedDate = requestedDate
        object.effectiveDate = effectiveDate
        object.expiryDate = expiryDate
        object.patient = patient
        do {
            try context.save()
            self.notify(event: StorageEvent(event: .Save, entity: .SpecialAuthorityMedication, object: object))
            return object
        } catch let error as NSError {
            Logger.log(string: "Could not save. \(error), \(error.userInfo)", type: .storage)
            return nil
        }
    }
    
    func fetchSpecialAuthorityMedications() -> [SpecialAuthorityDrug] {
        guard let context = managedContext else {return []}
        do {
            return try context.fetch(SpecialAuthorityDrug.fetchRequest())
        } catch let error as NSError {
            Logger.log(string: "Could not save. \(error), \(error.userInfo)", type: .storage)
            return []
        }
    }
    

}
