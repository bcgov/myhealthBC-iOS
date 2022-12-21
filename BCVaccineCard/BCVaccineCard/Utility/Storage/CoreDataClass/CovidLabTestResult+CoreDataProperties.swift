//
//  CovidLabTestResult+CoreDataProperties.swift
//  
//
//  Created by Amir Shayegh on 2022-12-07.
//
//

import Foundation
import CoreData


extension CovidLabTestResult {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CovidLabTestResult> {
        return NSFetchRequest<CovidLabTestResult>(entityName: "CovidLabTestResult")
    }

    @NSManaged public var authenticated: Bool
    @NSManaged public var createdAt: Date?
    @NSManaged public var id: String?
    @NSManaged public var orderId: String?
    @NSManaged public var pdf: String?
    @NSManaged public var reportAvailable: Bool
    @NSManaged public var patient: Patient?
    @NSManaged public var results: NSSet?
    @NSManaged public var comments: NSSet?

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

// MARK: Generated accessors for comments
extension CovidLabTestResult {

    @objc(addCommentsObject:)
    @NSManaged public func addToComments(_ value: Comment)

    @objc(removeCommentsObject:)
    @NSManaged public func removeFromComments(_ value: Comment)

    @objc(addComments:)
    @NSManaged public func addToComments(_ values: NSSet)

    @objc(removeComments:)
    @NSManaged public func removeFromComments(_ values: NSSet)

}
