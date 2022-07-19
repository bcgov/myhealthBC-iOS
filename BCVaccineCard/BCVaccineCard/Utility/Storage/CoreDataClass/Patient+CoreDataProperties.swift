//
//  Patient+CoreDataProperties.swift
//  
//
//  Created by Amir on 2022-07-07.
//
//

import Foundation
import CoreData


extension Patient {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Patient> {
        return NSFetchRequest<Patient>(entityName: "Patient")
    }

    @NSManaged public var authenticated: Bool
    @NSManaged public var authManagerDisplayName: String?
    @NSManaged public var birthday: Date?
    @NSManaged public var name: String?
    @NSManaged public var phn: String?
    @NSManaged public var covidTestResults: NSSet?
    @NSManaged public var immunizations: NSSet?
    @NSManaged public var laboratoryOrders: NSSet?
    @NSManaged public var prescriptions: NSSet?
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

// MARK: Generated accessors for immunizations
extension Patient {

    @objc(addImmunizationsObject:)
    @NSManaged public func addToImmunizations(_ value: Immunization)

    @objc(removeImmunizationsObject:)
    @NSManaged public func removeFromImmunizations(_ value: Immunization)

    @objc(addImmunizations:)
    @NSManaged public func addToImmunizations(_ values: NSSet)

    @objc(removeImmunizations:)
    @NSManaged public func removeFromImmunizations(_ values: NSSet)

}

// MARK: Generated accessors for laboratoryOrders
extension Patient {

    @objc(addLaboratoryOrdersObject:)
    @NSManaged public func addToLaboratoryOrders(_ value: LaboratoryOrder)

    @objc(removeLaboratoryOrdersObject:)
    @NSManaged public func removeFromLaboratoryOrders(_ value: LaboratoryOrder)

    @objc(addLaboratoryOrders:)
    @NSManaged public func addToLaboratoryOrders(_ values: NSSet)

    @objc(removeLaboratoryOrders:)
    @NSManaged public func removeFromLaboratoryOrders(_ values: NSSet)

}

// MARK: Generated accessors for prescriptions
extension Patient {

    @objc(addPrescriptionsObject:)
    @NSManaged public func addToPrescriptions(_ value: Perscription)

    @objc(removePrescriptionsObject:)
    @NSManaged public func removeFromPrescriptions(_ value: Perscription)

    @objc(addPrescriptions:)
    @NSManaged public func addToPrescriptions(_ values: NSSet)

    @objc(removePrescriptions:)
    @NSManaged public func removeFromPrescriptions(_ values: NSSet)

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
