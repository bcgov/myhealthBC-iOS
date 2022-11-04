//
//  ImmunizationTargetDisease+CoreDataProperties.swift
//  
//
//  Created by Amir Shayegh on 2022-08-23.
//
//

import Foundation
import CoreData


extension ImmunizationTargetDisease {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ImmunizationTargetDisease> {
        return NSFetchRequest<ImmunizationTargetDisease>(entityName: "ImmunizationTargetDisease")
    }

    @NSManaged public var code: String?
    @NSManaged public var name: String?
    @NSManaged public var recomendation: ImmunizationRecommendation?

}
