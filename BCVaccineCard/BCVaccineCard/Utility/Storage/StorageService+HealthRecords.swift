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
        guard let context = managedContext else {return completion([])}
        do {
            let tests = fetchTestResults().map({HealthRecord(type: .Test($0))})
            let vaccineCards = fetchVaccineCards().map({HealthRecord(type: .CovidImmunization($0))})
            return completion(tests + vaccineCards)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return completion([])
        }
    }
}
