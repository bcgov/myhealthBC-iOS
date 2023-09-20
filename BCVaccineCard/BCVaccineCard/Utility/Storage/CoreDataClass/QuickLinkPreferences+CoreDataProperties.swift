//
//  QuickLinkPreferences+CoreDataProperties.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2023-07-26.
//
//

import Foundation
import CoreData


extension QuickLinkPreferences {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<QuickLinkPreferences> {
        return NSFetchRequest<QuickLinkPreferences>(entityName: "QuickLinkPreferences")
    }

    @NSManaged public var quickLink: String?
    @NSManaged public var order: Int64
    @NSManaged public var patient: Patient?

}
