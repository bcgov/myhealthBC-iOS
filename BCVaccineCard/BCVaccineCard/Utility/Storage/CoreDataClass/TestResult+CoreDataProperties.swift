//
//  TestResult+CoreDataProperties.swift
//  
//
//  Created by Amir on 2021-12-09.
//
//

import Foundation
import CoreData


extension TestResult {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TestResult> {
        return NSFetchRequest<TestResult>(entityName: "TestResult")
    }

    @NSManaged public var collectionDateTime: Date?
    @NSManaged public var id: String?
    @NSManaged public var lab: String?
    @NSManaged public var patientDisplayName: String?
    @NSManaged public var reportId: String?
    @NSManaged public var resultDateTime: Date?
    @NSManaged public var resultDescription: [String]?
    @NSManaged public var resultLink: String?
    @NSManaged public var resultTitle: String?
    @NSManaged public var testName: String?
    @NSManaged public var testOutcome: String?
    @NSManaged public var testStatus: String?
    @NSManaged public var testType: String?
    @NSManaged public var parentTest: CovidLabTestResult?

}
