//
//  VaccineCard+CoreDataProperties.swift
//
//
//  Created by Amir on 2021-11-30.
//
//

import Foundation
import CoreData
import BCVaccineValidator

extension VaccineCard {

    @nonobjc public class func createFetchRequest() -> NSFetchRequest<VaccineCard> {
        return NSFetchRequest<VaccineCard>(entityName: "VaccineCard")
    }

    @NSManaged public var code: String?
    @NSManaged public var issueDate: NSNumber?
    @NSManaged public var name: String?
    @NSManaged public var sortOrder: Int64
    @NSManaged public var birthdate: String?
    @NSManaged public var federalPass: String?
    @NSManaged public var vaxDates: [String]?
    @NSManaged public var phn: String?
    @NSManaged public var user: User?
    @NSManaged public var firHash: String?
    @NSManaged public var immunizationRecord: NSSet?
    
    
    public var federalPassData: Data? {
        guard let stringData = federalPass else { return nil}
        return Data(base64URLEncoded: stringData)
    }
    
    var id: String? {
        return firHash
    }
    
    public var immunizations: [ImmunizationRecord] {
        let set = immunizationRecord as? Set<ImmunizationRecord> ?? []
        return set.sorted {
            $0.date ?? Date() < $1.date ?? Date()
        }
    }
    
    public var getCovidImmunizations: [ImmunizationRecord] {
        guard let array = immunizationRecord?.allObjects as? [ImmunizationRecord] else { return [] }
        return array
    }
    
    public func toLocal() -> LocallyStoredVaccinePassportModel? {
        guard let qrCode = code, let dates = vaxDates, let issueDate = issueDate, let birthdate = birthdate, let firHash = firHash else {return nil}
        return LocallyStoredVaccinePassportModel(code: qrCode, birthdate: birthdate, hash: firHash, vaxDates: dates, name: name ?? "", issueDate: Double(issueDate), status: .fully, source: .imported, fedCode: federalPass, phn: phn)
    }

}

// MARK: Generated accessors for immunizationRecord
extension VaccineCard {

    @objc(addImmunizationRecordObject:)
    @NSManaged public func addToImmunizationRecord(_ value: ImmunizationRecord)

    @objc(removeImmunizationRecordObject:)
    @NSManaged public func removeFromImmunizationRecord(_ value: ImmunizationRecord)

    @objc(addImmunizationRecord:)
    @NSManaged public func addToImmunizationRecord(_ values: NSSet)

    @objc(removeImmunizationRecord:)
    @NSManaged public func removeFromImmunizationRecord(_ values: NSSet)

}
