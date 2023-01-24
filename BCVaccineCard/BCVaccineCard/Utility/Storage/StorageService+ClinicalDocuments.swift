//
//  StorageService+ClinicalDocuments.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2023-01-05.
//

import Foundation

protocol StorageClinicalDocumentsManager {
    
    // MARK: Store
    func storeClinicalDocuments(
        patient: Patient,
        objects: [ClinicalDocumentResponse],
        authenticated: Bool
    ) -> [ClinicalDocument]
    

    // MARK: Fetch
    func fetchClinicalDocuments()-> [ClinicalDocument]
}

extension StorageService: StorageClinicalDocumentsManager {
    func storeClinicalDocuments(patient: Patient, objects: [ClinicalDocumentResponse], authenticated: Bool) -> [ClinicalDocument] {
        var storedObjects: [ClinicalDocument] = []
        for document in objects {
            if let stored = storeClinicalDocument(id: document.id,
                                                  name: document.name,
                                                  fileID:  document.fileID,
                                                  type:  document.type,
                                                  facilityName: document.facilityName,
                                                  discipline: document.discipline,
                                                  serviceDate: document.serviceDate?.getGatewayDate(),
                                                  patient: patient,
                                                  authenticated: authenticated)
            {
                storedObjects.append(stored)
            }
            
        }
        return storedObjects
    }
    
    private func storeClinicalDocument(
        id: String?,
        name: String?,
        fileID: String?,
        type: String?,
        facilityName: String?,
        discipline: String?,
        serviceDate: Date?,
        patient: Patient?,
        authenticated: Bool
    ) -> ClinicalDocument? {
        guard let context = managedContext else {return nil}
        let document = ClinicalDocument(context: context)
        document.id = id
        document.name = name
        document.fileID = fileID
        document.type = type
        document.facilityName = facilityName
        document.discipline = discipline
        document.serviceDate = serviceDate
        document.patient = patient
        document.authenticated = authenticated
        do {
            try context.save()
            self.notify(event: StorageEvent(event: .Save, entity: .ClinicalDocument, object: document))
            return document
        } catch let error as NSError {
            Logger.log(string: "Could not save. \(error), \(error.userInfo)", type: .storage)
            return nil
        }
    }
    
    func fetchClinicalDocuments() -> [ClinicalDocument] {
        guard let context = managedContext else {return []}
        do {
            return try context.fetch(ClinicalDocument.fetchRequest())
        } catch let error as NSError {
            Logger.log(string: "Could not save. \(error), \(error.userInfo)", type: .storage)
            return []
        }
    }
  
}
