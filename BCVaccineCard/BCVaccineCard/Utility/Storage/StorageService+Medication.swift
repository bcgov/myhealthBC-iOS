//
//  StorageService+Medication.swift
//  BCVaccineCard
//
//  Created by Amir on 2022-02-09.
//

import Foundation
import CoreData
protocol StorageMedicationManager {
    
    // MARK: Store
    func storePrescription(
        patient: Patient,
        object: AuthenticatedMedicationStatementResponseObject.ResourcePayload,
        initialProtectedMedFetch: Bool,
        completion: @escaping(Perscription?)->Void
    )
    
    func storePrescription(
        context: NSManagedObjectContext,
        patient: Patient,
        id: String,
        prescriptionIdentifier: String?,
        prescriptionStatus: String?,
        dispensedDate: Date?,
        practitionerSurname: String?,
        directions: String?,
        dateEntered: Date?,
        pharmacy: Pharmacy?,
        medication: Medication?,
        initialProtectedMedFetch: Bool,
        completion: @escaping(Perscription?)->Void
    )
    
    func storeMedication(
        context: NSManagedObjectContext,
        gateWayResponse: AuthenticatedMedicationStatementResponseObject.ResourcePayload.MedicationSummary,
        initialProtectedMedFetch: Bool,
        completion: @escaping(Medication?)->Void
    )
    
    func storeMedication(
        context: NSManagedObjectContext,
        din: String?,
        brandName: String?,
        genericName: String?,
        quantity: Double?,
        maxDailyDosage: Int?,
        drugDiscontinuedDate: Date?,
        form: String?,
        manufacturer: String?,
        strength: String?,
        strengthUnit: String?,
        isPin: Bool?,
        initialProtectedMedFetch: Bool,
        completion: @escaping(Medication?)->Void
    )
    
    func storePharmacy(
        context: NSManagedObjectContext,
        gateWayResponse: AuthenticatedMedicationStatementResponseObject.ResourcePayload.DispensingPharmacy,
        initialProtectedMedFetch: Bool,
        completion: @escaping(Pharmacy?)->Void
    )
    
    func storePharmacy(
        context: NSManagedObjectContext,
        pharmacyID: String?,
        name: String?,
        addressLine1: String?,
        addressLine2: String?,
        city: String?,
        province: String?,
        postalCode: String?,
        countryCode: String?,
        phoneNumber: String?,
        faxNumber: String?,
        initialProtectedMedFetch: Bool,
        completion: @escaping(Pharmacy?)->Void
    )
    
    // MARK: Delete
    func deletePrescription(id: String, sendDeleteEvent: Bool)
    func deletePharmacy(id: String, sendDeleteEvent: Bool)
    //    func deleteMedication(id: String, sendDeleteEvent: Bool)
    
    // MARK: Fetch
    func fetchPrescriptions()-> [Perscription]
    func fetchPrescription(id: String)-> Perscription?
    func fetchPharmacy(id: String)-> Pharmacy?
    //    func fetchMedication(id: String)-> Medication?
}

extension StorageService: StorageMedicationManager {
    
    // MARK: Store
    
    ///  Store All perscriptions from Health Gateway response.
    /// - Parameters:
    ///   - gatewayResponse: Object retrieved from API containing array of Perscriptions
    ///   - patient: patient to store object for
    ///   - completion:  returns array of stored perscriptions
    func storePrescriptions(in gatewayResponse: AuthenticatedMedicationStatementResponseObject, patient: Patient, initialProtectedMedFetch: Bool, completion: @escaping([Perscription])->Void) {
        /**
         Note the return is Async but function doesnt do anything async yet.
         This is in case the proccess is slow in the future and we want to handle it asynchronously.
         */
        
        guard let perscriptionObjects = gatewayResponse.resourcePayload else {return}
        var storedObjects: [Perscription] = []
        classQueue.async {
            let dispatchGroup = DispatchGroup()
            let queue = DispatchQueue(label: "prescriptions", qos: .userInitiated)
            for object in perscriptionObjects {
                dispatchGroup.enter()
                queue.async {
                    self.storePrescription(patient: patient, object: object, initialProtectedMedFetch: initialProtectedMedFetch, completion: { result in
                        if let storedObject = result {
                            storedObjects.append(storedObject)
                        } else {
                            Logger.log(string: "*Failed while storing perscription", type: .storage)
                        }
                        dispatchGroup.leave()
                    })
                }
            }
            dispatchGroup.notify(queue: .global(qos: .userInitiated)) {
                Logger.log(string: "Stored \(storedObjects.count) items", type: .storage)
                let _ = initialProtectedMedFetch ? self.notify(event: StorageEvent(event: .ProtectedMedicalRecordsInitialFetch, entity: .Perscription, object: storedObjects)) : self.notify(event: StorageEvent(event: .Save, entity: .Perscription, object: storedObjects))
                return completion(storedObjects)
            }
        }
        
    }
    
    func storePrescription(patient: Patient, object: AuthenticatedMedicationStatementResponseObject.ResourcePayload, initialProtectedMedFetch: Bool, completion: @escaping(Perscription?)->Void) {
        guard let context = managedContext else {return completion(nil)}

        let dispatchGroup = DispatchGroup()
        
        // Handle Medication
        dispatchGroup.enter()
        var medication: Medication? = nil
        if let medicationSummary = object.medicationSummary {
            storeMedication(context: context, gateWayResponse: medicationSummary, initialProtectedMedFetch: initialProtectedMedFetch, completion: { result in
                medication = result
                dispatchGroup.leave()
            })
        }
        // Handle Pharmacy
        dispatchGroup.enter()
        var pharmacy: Pharmacy? = nil
        if let dispensingPharmacy = object.dispensingPharmacy {
            if let pharmacyId = dispensingPharmacy.pharmacyID, let storedPharmacy = fetchPharmacy(id: pharmacyId) {
                pharmacy = storedPharmacy
            } else {
                storePharmacy(context: context, gateWayResponse: dispensingPharmacy, initialProtectedMedFetch: initialProtectedMedFetch, completion: { result in
                    pharmacy = result
                    dispatchGroup.leave()
                })
            }
        }
        
        dispatchGroup.notify(queue: .global(qos: .userInitiated)) {
            let id = UUID().uuidString
            // Store new record
            // This is due to API inconsistencies with date formatting
            var dispenseDate: Date?
            var dateEntered: Date?
            
            if let timezoneDate = Date.Formatter.gatewayDateAndTimeWithTimeZone.date(from: object.dispensedDate ?? "") {
                dispenseDate = timezoneDate
            } else if let nozoneDate = Date.Formatter.gatewayDateAndTime.date(from: object.dispensedDate ?? "") {
                dispenseDate = nozoneDate
            }
            
            if let timezoneDate = Date.Formatter.gatewayDateAndTimeWithTimeZone.date(from: object.dateEntered ?? "") {
                dateEntered = timezoneDate
            } else if let nozoneDate = Date.Formatter.gatewayDateAndTime.date(from: object.dateEntered ?? "") {
                dateEntered = nozoneDate
            }
            
            self.storePrescription(
                context: context,
                patient: patient,
                id: id,
                prescriptionIdentifier: object.prescriptionIdentifier,
                prescriptionStatus: object.prescriptionStatus,
                dispensedDate: dispenseDate,
                practitionerSurname: object.practitionerSurname,
                directions: object.directions,
                dateEntered: dateEntered,
                pharmacy: pharmacy,
                medication: medication,
                initialProtectedMedFetch: initialProtectedMedFetch,
                completion: completion
            )
        }
    }
    
    func storePrescription(
        context: NSManagedObjectContext,
        patient: Patient,
        id: String,
        prescriptionIdentifier: String?,
        prescriptionStatus: String?,
        dispensedDate: Date?,
        practitionerSurname: String?,
        directions: String?,
        dateEntered: Date?,
        pharmacy: Pharmacy?,
        medication: Medication?,
        initialProtectedMedFetch: Bool,
        completion: @escaping(Perscription?)->Void
    ) {
       
        let contextPatientObject = context.object(with: patient.objectID)
        guard let contextPatient = contextPatientObject as? Patient else {
            return completion(nil)
        }
        context.perform {
            let prescription = Perscription(context: context)
            prescription.id = id
            prescription.prescriptionIdentifier = prescriptionIdentifier
            prescription.status = prescriptionStatus
            prescription.dispensedDate = dispensedDate
            prescription.practitionerSurname = practitionerSurname
            prescription.directions = directions
            prescription.dateEntered = dateEntered
            prescription.patient = contextPatient
            prescription.authenticated = true
            prescription.pharmacy = pharmacy
            prescription.medication = medication
            do {
                try context.save()
                self.notify(event: StorageEvent(event: .Save, entity: .Perscription, object: prescription))
                return completion(prescription)
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
                return completion(nil)
            }
        }
    }
    
    func storeMedication(
        context: NSManagedObjectContext,
        gateWayResponse: AuthenticatedMedicationStatementResponseObject.ResourcePayload.MedicationSummary,
        initialProtectedMedFetch: Bool,
        completion: @escaping(Medication?)->Void
    ) {
        let drugDiscontinuedDate = Date.Formatter.gatewayDateAndTimeWithTimeZone.date(from: gateWayResponse.drugDiscontinuedDate ?? "")
        return storeMedication(
            context: context,
            din: gateWayResponse.din,
            brandName: gateWayResponse.brandName,
            genericName: gateWayResponse.genericName,
            quantity: gateWayResponse.quantity,
            maxDailyDosage: gateWayResponse.maxDailyDosage,
            drugDiscontinuedDate: drugDiscontinuedDate,
            form: gateWayResponse.form,
            manufacturer: gateWayResponse.manufacturer,
            strength: gateWayResponse.strength,
            strengthUnit: gateWayResponse.strengthUnit,
            isPin: gateWayResponse.isPin,
            initialProtectedMedFetch: initialProtectedMedFetch,
            completion: completion
        )
    }
    
    func storeMedication(
        context: NSManagedObjectContext,
        din: String?,
        brandName: String?,
        genericName: String?,
        quantity: Double?,
        maxDailyDosage: Int?,
        drugDiscontinuedDate: Date?,
        form: String?,
        manufacturer: String?,
        strength: String?,
        strengthUnit: String?,
        isPin: Bool?,
        initialProtectedMedFetch: Bool,
        completion: @escaping(Medication?)->Void
    ) {
        context.perform {
            let medication = Medication(context: context)
            medication.din = din
            medication.brandName = brandName
            medication.genericName = genericName
            medication.quantity = quantity ?? 0
            medication.maxDailyDosage = Int64(maxDailyDosage ?? 0)
            medication.drugDiscontinuedDate = drugDiscontinuedDate
            medication.form = form
            medication.manufacturer = manufacturer
            medication.strength = strength
            medication.strengthUnit = strengthUnit
            medication.isPin = isPin ?? false
            do {
                try context.save()
                self.notify(event: StorageEvent(event: .Save, entity: .Medication, object: medication))
                return completion(medication)
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
                return completion(nil)
            }
        }
    }
    
    func storePharmacy(
        context: NSManagedObjectContext,
        gateWayResponse: AuthenticatedMedicationStatementResponseObject.ResourcePayload.DispensingPharmacy,
        initialProtectedMedFetch: Bool,
        completion: @escaping(Pharmacy?)->Void
    ) {
        storePharmacy(
            context: context,
                      pharmacyID: gateWayResponse.pharmacyID,
                      name: gateWayResponse.name,
                      addressLine1: gateWayResponse.addressLine1,
                      addressLine2: gateWayResponse.addressLine2,
                      city: gateWayResponse.city,
                      province: gateWayResponse.province,
                      postalCode: gateWayResponse.postalCode,
                      countryCode: gateWayResponse.countryCode,
                      phoneNumber: gateWayResponse.phoneNumber,
                      faxNumber: gateWayResponse.faxNumber,
                      initialProtectedMedFetch: initialProtectedMedFetch,
                      completion: completion
        )
    }
    
    func storePharmacy(
        context: NSManagedObjectContext,
        pharmacyID: String?,
        name: String?,
        addressLine1: String?,
        addressLine2: String?,
        city: String?,
        province: String?,
        postalCode: String?,
        countryCode: String?,
        phoneNumber: String?,
        faxNumber: String?,
        initialProtectedMedFetch: Bool,
        completion: @escaping(Pharmacy?)->Void
    ) {
        context.perform {
            let pharmacy = Pharmacy(context: context)
            pharmacy.id = pharmacyID
            pharmacy.name = name
            pharmacy.addressLine1 = addressLine1
            pharmacy.addressLine2 = addressLine2
            pharmacy.city = city
            pharmacy.province = province
            pharmacy.postalCode = postalCode
            pharmacy.countryCode = countryCode
            pharmacy.phoneNumber = phoneNumber
            pharmacy.faxNumber = faxNumber
            do {
                try context.save()
                let _ = initialProtectedMedFetch ? self.notify(event: StorageEvent(event: .ProtectedMedicalRecordsInitialFetch, entity: .Pharmacy, object: pharmacy)) : self.notify(event: StorageEvent(event: .Save, entity: .Pharmacy, object: pharmacy))
                return completion(pharmacy)
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
                return completion(nil)
            }
        }
    }
    
    // MARK: Fetch
    func fetchPrescriptions() -> [Perscription] {
        guard let context = managedContext else {return []}
        do {
            return try context.fetch(Perscription.fetchRequest())
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return []
        }
    }
    
    func fetchPrescription(id: String) -> Perscription? {
        let prescriptions = fetchPrescriptions()
        return prescriptions.first(where: {$0.id == id})
    }
    
    func fetchPharmacy(id: String) -> Pharmacy? {
        guard let context = managedContext else {return nil}
        do {
            let pharmacies = try context.fetch(Pharmacy.fetchRequest())
            return pharmacies.first(where: {$0.id == id})
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return nil
        }
    }
    
    //    func fetchMedication(id: String) -> Medication? {
    //        guard let context = managedContext else {return nil}
    //        do {
    //            let medications = try context.fetch(Medication.fetchRequest())
    //            return medications.first(where: {$0.id == id})
    //        } catch let error as NSError {
    //            print("Could not fetch. \(error), \(error.userInfo)")
    //            return nil
    //        }
    //    }
    
    // MARK: Delete
    func deletePrescription(id: String, sendDeleteEvent: Bool) {
        guard let object = fetchPrescription(id: id) else {return}
        delete(object: object)
        if sendDeleteEvent {
            self.notify(event: StorageEvent(event: .Delete, entity: .Perscription, object: object))
        }
    }
    
    func deletePharmacy(id: String, sendDeleteEvent: Bool) {
        guard let object = fetchPharmacy(id: id) else {return}
        delete(object: object)
        if sendDeleteEvent {
            self.notify(event: StorageEvent(event: .Delete, entity: .Pharmacy, object: object))
        }
    }
    
    //    func deleteMedication(id: String, sendDeleteEvent: Bool) {
    //        guard let object = fetchMedication(id: id) else {return}
    //        delete(object: object)
    //        if sendDeleteEvent {
    //            self.notify(event: StorageEvent(event: .Delete, entity: .Medication, object: object))
    //        }
    //    }
}
