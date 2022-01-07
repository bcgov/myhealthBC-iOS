//
//  Patient+CoreDataProperties.swift
//  
//
//  Created by Amir on 2022-01-05.
//
//

import Foundation
import CoreData


extension Patient {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Patient> {
        return NSFetchRequest<Patient>(entityName: "Patient")
    }

    @NSManaged public var phn: String?
    @NSManaged public var name: String?
    @NSManaged public var birthday: Date?
    @NSManaged public var firstName: String?
    @NSManaged public var lastName: String?
    @NSManaged public var covidTestResults: NSSet?
    @NSManaged public var vaccineCard: NSSet?

}

// MARK: Generated accessors for covidTestResults
extension Patient {

    @objc(addCovidTestResultsObject:)
    @NSManaged public func addToCovidTestResults(_ value: CovidLabTestResult)

    @objc(removeCovidTestResultsObject:)
    @NSManaged public func removeFromCovidTestResults(_ value: CovidLabTestResult)

    @objc(addCovidTestResults:)
    @NSManaged public func addToCovidTestResults(_ values: NSSet)

    @objc(removeCovidTestResults:)
    @NSManaged public func removeFromCovidTestResults(_ values: NSSet)

}

// MARK: Generated accessors for vaccineCard
extension Patient {

    @objc(addVaccineCardObject:)
    @NSManaged public func addToVaccineCard(_ value: VaccineCard)

    @objc(removeVaccineCardObject:)
    @NSManaged public func removeFromVaccineCard(_ value: VaccineCard)

    @objc(addVaccineCard:)
    @NSManaged public func addToVaccineCard(_ values: NSSet)

    @objc(removeVaccineCard:)
    @NSManaged public func removeFromVaccineCard(_ values: NSSet)

}
