//
//  TestResult+CoreDataProperties.swift
//  
//
//  Created by Amir on 2021-11-29.
//
//

import Foundation
import CoreData


extension TestResult {

    @nonobjc public class func createFetchRequest() -> NSFetchRequest<TestResult> {
        return NSFetchRequest<TestResult>(entityName: "TestResult")
    }

    @NSManaged public var id: String?
    @NSManaged public var patientDisplayName: String?
    @NSManaged public var lab: String?
    @NSManaged public var reportId: String?
    @NSManaged public var collectionDateTime: Date?
    @NSManaged public var resultDateTime: Date?
    @NSManaged public var testName: String?
    @NSManaged public var testType: String?
    @NSManaged public var testStatus: String?
    @NSManaged public var testOutcome: String?
    @NSManaged public var resultTitle: String?
    @NSManaged public var resultDescription: String?
    @NSManaged public var resultLink: String?
    @NSManaged public var user: User?

}
