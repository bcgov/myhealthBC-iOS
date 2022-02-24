//
//  LaboratoryTest+CoreDataProperties.swift
//  
//
//  Created by Amir Shayegh on 2022-02-22.
//
//

import Foundation
import CoreData


extension LaboratoryTest {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LaboratoryTest> {
        return NSFetchRequest<LaboratoryTest>(entityName: "LaboratoryTest")
    }

    @NSManaged public var batteryType: String?
    @NSManaged public var obxID: String?
    @NSManaged public var outOfRange: Bool
    @NSManaged public var loinc: String?
    @NSManaged public var testStatus: String?
    @NSManaged public var laboratoryOrder: LaboratoryOrder?

}
