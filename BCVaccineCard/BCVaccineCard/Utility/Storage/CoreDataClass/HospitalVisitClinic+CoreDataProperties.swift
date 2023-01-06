//
//  HospitalVisitClinic+CoreDataProperties.swift
//  
//
//  Created by Amir Shayegh on 2023-01-05.
//
//

import Foundation
import CoreData


extension HospitalVisitClinic {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<HospitalVisitClinic> {
        return NSFetchRequest<HospitalVisitClinic>(entityName: "HospitalVisitClinic")
    }

    @NSManaged public var name: String?
    @NSManaged public var hospitalVisit: HospitalVisit?

}
