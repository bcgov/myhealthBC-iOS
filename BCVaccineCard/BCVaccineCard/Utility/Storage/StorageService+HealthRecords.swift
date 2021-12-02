//
//  StorageService+HealthRecords.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-11-30.
//

import Foundation
import BCVaccineValidator


/*
Test {
* PHN
* DOB
* DOT
* TEST ID
* TESTS: [RECORDS]
}
*/
extension StorageService {
    
    func getHeathRecords(for userId: String? = AuthManager().userId()) -> [HealthRecord] {
        guard let context = managedContext else {return []}
        do {
            let users = try context.fetch(User.createFetchRequest())
            guard let user = users.filter({$0.userId == userId}).first else {return []}
            
            let tests = user.testResultArray.map({HealthRecord(type: .Test($0))})
            let vaccineCards = user.vaccineCardArray.map({HealthRecord(type: .CovidImmunization($0))})
            return tests + vaccineCards
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return []
        }
    }
}
