//
//  GatewayNotification+CoreDataProperties.swift
//  
//
//  Created by Amir Shayegh on 2023-05-31.
//
//

import Foundation
import CoreData


extension GatewayNotification {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<GatewayNotification> {
        return NSFetchRequest<GatewayNotification>(entityName: "GatewayNotification")
    }

    @NSManaged public var id: String?
    @NSManaged public var categoryName: String?
    @NSManaged public var displayText: String?
    @NSManaged public var actionURL: String?
    @NSManaged public var actionType: String?
    @NSManaged public var scheduledDate: Date?
    @NSManaged public var patient: Patient?

}
