//
//  SpecialAuthorityDrug+CoreDataProperties.swift
//  
//
//  Created by Amir on 2022-07-12.
//
//

import Foundation
import CoreData


extension SpecialAuthorityDrug {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SpecialAuthorityDrug> {
        return NSFetchRequest<SpecialAuthorityDrug>(entityName: "SpecialAuthorityDrug")
    }

    @NSManaged public var authenticated: Bool
    @NSManaged public var referenceNumber: String?
    @NSManaged public var drugName: String?
    @NSManaged public var requestStatus: String?
    @NSManaged public var prescriberFirstName: String?
    @NSManaged public var prescriberLastName: String?
    @NSManaged public var requestedDate: Date?
    @NSManaged public var effectiveDate: Date?
    @NSManaged public var expiryDate: Date?
    @NSManaged public var patient: Patient?

}
