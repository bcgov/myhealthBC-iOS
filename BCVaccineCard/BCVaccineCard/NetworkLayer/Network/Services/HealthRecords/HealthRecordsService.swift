//
//  HealthRecordsService.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2022-10-24.
//

import UIKit

struct HealthRecordsService {
    
    let network: Network
    let authManager: AuthManager
    
    private var endpoints: UrlAccessor {
        return UrlAccessor()
    }
    
    public func fetchAndStoreHealthRecords(for dependent: Dependent, completion: @escaping ([HealthRecord])->Void) {
        guard let patient = dependent.info else {return completion([])}

        let dispatchGroup = DispatchGroup()
        var records: [HealthRecord] = []
        
        network.addLoader(message: .FetchingRecords)
        StorageService.shared.deleteHealthRecordsForDependent(dependent: dependent)
        
        dispatchGroup.enter()
        let vaccineCardService = VaccineCardService(network: network, authManager: authManager)

        vaccineCardService.fetchAndStore(for: patient) { result in
            if let covidCard = result {
                let covidRec = HealthRecord(type: .CovidImmunization(covidCard))
                records.append(covidRec)
            }
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        let covidTestsService = CovidTestsService(network: network, authManager: authManager)

        covidTestsService.fetchAndStore(for: patient) { result in
            let uwreapped = result.map({HealthRecord(type: .CovidTest($0))})
            records.append(contentsOf: uwreapped)
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        let immunizationsService = ImmnunizationsService(network: network, authManager: authManager)

        immunizationsService.fetchAndStore(for: patient) { result in
            let uwreapped = result.map({HealthRecord(type: .Immunization($0))})
            records.append(contentsOf: uwreapped)
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        let clinicalDocsService = ClinicalDocumentService(network: network, authManager: authManager)
        clinicalDocsService.fetchAndStore(for: patient) { result in
            let uwreapped = result.map({HealthRecord(type: .ClinicalDocument($0))})
            records.append(contentsOf: uwreapped)
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        let medicationService = MedicationService(network: network, authManager: authManager)
        medicationService.fetchAndStore(for: patient, protected: false) { result in
            let uwreapped = result.map({HealthRecord(type: .Medication($0))})
            records.append(contentsOf: uwreapped)
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        let labOrderService = LabOrderService(network: network, authManager: authManager)
        labOrderService.fetchAndStore(for: patient) { result in
            let uwreapped = result.map({HealthRecord(type: .LaboratoryOrder($0))})
            records.append(contentsOf: uwreapped)
            dispatchGroup.leave()
        }
        
        // TODO: other records here
        
        dispatchGroup.notify(queue: .main) {
            // Return completion
            network.removeLoader()
            return completion(records)
        }
    }
}
