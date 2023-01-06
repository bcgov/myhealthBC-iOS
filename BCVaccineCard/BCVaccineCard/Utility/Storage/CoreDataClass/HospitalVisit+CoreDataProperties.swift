//
//  HospitalVisit+CoreDataProperties.swift
//  
//
//  Created by Amir Shayegh on 2023-01-05.
//
//

import Foundation
import CoreData


extension HospitalVisit {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<HospitalVisit> {
        return NSFetchRequest<HospitalVisit>(entityName: "HospitalVisit")
    }

    @NSManaged public var id: String?
    @NSManaged public var encounterDate: Date?
    @NSManaged public var specialtyDescription: String?
    @NSManaged public var practitionerName: String?
    @NSManaged public var authenticated: Bool
    @NSManaged public var clinic: HospitalVisitClinic?
    @NSManaged public var patient: Patient?
    @NSManaged public var comments: Comment?

}
