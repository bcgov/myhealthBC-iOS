//
//  OrganDonorStatus+CoreDataProperties.swift
//  
//
//  Created by Amir Shayegh on 2023-04-10.
//
//

import Foundation
import CoreData


extension OrganDonorStatus {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<OrganDonorStatus> {
        return NSFetchRequest<OrganDonorStatus>(entityName: "OrganDonorStatus")
    }

    @NSManaged public var status: String?
    @NSManaged public var statusMessage: String?
    @NSManaged public var fileId: String?
    @NSManaged public var patient: Patient?

}
