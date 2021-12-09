//
//  StorageService+HealthRecords.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-11-30.
//

import Foundation
import BCVaccineValidator

extension StorageService {
    
    func getHeathRecords(for userId: String? = AuthManager().userId(), completion: @escaping( [HealthRecord])-> Void) {
        let tests = fetchTestResults().map({HealthRecord(type: .Test($0))})
        let vaccineCards = fetchVaccineCards().map({HealthRecord(type: .CovidImmunization($0))})
        return completion(tests + vaccineCards)
    }
}
