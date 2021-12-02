//
//  User+CoreDataProperties.swift
//  
//
//  Created by Amir on 2021-11-29.
//
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func createFetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var id: String?
    @NSManaged public var name: String?
    @NSManaged public var vaccineCard: NSSet?
    @NSManaged public var testResult: NSSet?  
}

// MARK: Generated accessors for vaccineCard
extension User {

    @objc(addVaccineCardObject:)
    @NSManaged public func addToVaccineCard(_ value: VaccineCard)

    @objc(removeVaccineCardObject:)
    @NSManaged public func removeFromVaccineCard(_ value: VaccineCard)

    @objc(addVaccineCard:)
    @NSManaged public func addToVaccineCard(_ values: NSSet)

    @objc(removeVaccineCard:)
    @NSManaged public func removeFromVaccineCard(_ values: NSSet)

}

// MARK: Generated accessors for testResult
extension User {

    @objc(addTestResultObject:)
    @NSManaged public func addToTestResult(_ value: TestResult)

    @objc(removeTestResultObject:)
    @NSManaged public func removeFromTestResult(_ value: TestResult)

    @objc(addTestResult:)
    @NSManaged public func addToTestResult(_ values: NSSet)

    @objc(removeTestResult:)
    @NSManaged public func removeFromTestResult(_ values: NSSet)

}
