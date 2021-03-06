//
//  CovidLabTestResult+CoreDataProperties.swift
//  
//
//  Created by Amir on 2022-01-17.
//
//

import Foundation
import CoreData


extension CovidLabTestResult {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CovidLabTestResult> {
        return NSFetchRequest<CovidLabTestResult>(entityName: "CovidLabTestResult")
    }

    @NSManaged public var createdAt: Date?
    @NSManaged public var id: String?
    @NSManaged public var authenticated: Bool
    @NSManaged public var patient: Patient?
    @NSManaged public var results: NSSet?
    @NSManaged public var pdf: String?

}

// MARK: Generated accessors for results
extension CovidLabTestResult {

    @objc(addResultsObject:)
    @NSManaged public func addToResults(_ value: TestResult)

    @objc(removeResultsObject:)
    @NSManaged public func removeFromResults(_ value: TestResult)

    @objc(addResults:)
    @NSManaged public func addToResults(_ values: NSSet)

    @objc(removeResults:)
    @NSManaged public func removeFromResults(_ values: NSSet)

}
