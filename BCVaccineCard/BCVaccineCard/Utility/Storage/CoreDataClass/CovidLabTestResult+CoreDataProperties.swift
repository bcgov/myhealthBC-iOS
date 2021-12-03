//
//  CovidLabTestResult+CoreDataProperties.swift
//  
//
//  Created by Amir on 2021-12-02.
//
//

import Foundation
import CoreData


extension CovidLabTestResult {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CovidLabTestResult> {
        return NSFetchRequest<CovidLabTestResult>(entityName: "CovidLabTestResult")
    }

    @NSManaged public var id: String?
    @NSManaged public var phn: String?
    @NSManaged public var birthday: Date?
    @NSManaged public var testDate: Date?
    @NSManaged public var testId: String?
    @NSManaged public var results: NSSet?
    @NSManaged public var user: User?

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
