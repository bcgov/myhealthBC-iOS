//
//  User+CoreDataProperties.swift
//  
//
//  Created by Amir Shayegh on 2021-10-27.
//
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func createFetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var id: String?
    @NSManaged public var name: String?
    @NSManaged public var vaccineCard: NSSet?
    
    public var userId: String {
        return id ?? ""
    }
    
    public var vaccineCardArray: [VaccineCard] {
        let set = vaccineCard as? Set<VaccineCard> ?? []
        return set.sorted {
            $0.name ?? "" < $1.name ?? ""
        }
//        return set.sorted {
//            $0.sortOrder ?? 99 < $1.sortOrder ?? 99
//        }
    }

}

// MARK: Generated accessors for vaccineCard
extension User {

    @objc(addVaccineCardObject:)
    @NSManaged public func addToVaccineCard(_ value: VaccineCard)

    @objc(removeVaccineCardObject:)
    @NSManaged public func removeFromVaccineCard(_ value: VaccineCard)

    @objc(addVaccineCard:)
    @NSManaged public func addToVaccineCard(_ values: NSSet)

    @objc(removeVaccineCard:)
    @NSManaged public func removeFromVaccineCard(_ values: NSSet)

}
