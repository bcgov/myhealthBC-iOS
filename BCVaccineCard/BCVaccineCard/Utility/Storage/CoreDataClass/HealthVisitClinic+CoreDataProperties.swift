//
//  HealthVisitClinic+CoreDataProperties.swift
//  
//
//  Created by Amir on 2022-07-12.
//
//

import Foundation
import CoreData


extension HealthVisitClinic {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<HealthVisitClinic> {
        return NSFetchRequest<HealthVisitClinic>(entityName: "HealthVisitClinic")
    }

    @NSManaged public var name: String?
    @NSManaged public var healthVisit: HealthVisitClinic?

}
