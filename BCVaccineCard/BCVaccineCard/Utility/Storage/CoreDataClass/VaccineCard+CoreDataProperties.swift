//
//  VaccineCard+CoreDataProperties.swift
//  
//
//  Created by Amir Shayegh on 2021-10-28.
//
// TODO: Will need to add vaxDates as an NSManaged property

import Foundation
import CoreData


extension VaccineCard {

    @nonobjc public class func createFetchRequest() -> NSFetchRequest<VaccineCard> {
        return NSFetchRequest<VaccineCard>(entityName: "VaccineCard")
    }

    @NSManaged public var code: String?
    @NSManaged public var name: String?
    @NSManaged public var sortOrder: Int64
    @NSManaged public var birthdate: String?
    @NSManaged public var federalPass: String?
    @NSManaged public var vaxDates: [String]?
    @NSManaged public var phn: String?
    @NSManaged public var user: User?
    
    
    public var federalPassData: Data? {
        guard let stringData = federalPass else { return nil}
        return Data(base64URLEncoded: stringData)
    }
    
    var id: String? {
        return (name ?? "") + (birthdate ?? "")
    }

}
