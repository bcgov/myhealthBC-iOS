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
        
        let dispatchGroup = DispatchGroup()
        var records: [HealthRecord] = []
        network.addLoader(message: .FetchingRecords)
        dispatchGroup.enter()
        let vaccineCardService = VaccineCardService(network: network, authManager: authManager)
        vaccineCardService.fetchAndStoreCovidProof(for: dependent) { vaccineCard in
            if let covidCard = vaccineCard {
                let covidRec = HealthRecord(type: .CovidImmunization(covidCard))
                records.append(covidRec)
            }
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        let covidTestsService = CovidTestsService(network: network, authManager: authManager)
        covidTestsService.fetchAndStoreCovidTests(for: dependent) { covidTests in
            let covidTestsRec = covidTests.map({HealthRecord(type: .CovidTest($0))})
            records.append(contentsOf: covidTestsRec)
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        let immunizationsService = ImmnunizationsService(network: network, authManager: authManager)
        immunizationsService.fetchAndStoreImmunizations(for: dependent) { immunizations in
            let immunizationsRec = immunizations.map({HealthRecord(type: .Immunization($0))})
            records.append(contentsOf: immunizationsRec)
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
