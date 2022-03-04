//
//  Storage+Comments.swift
//  BCVaccineCard
//
//  Created by Amir on 2022-03-03.
//

import Foundation
import CoreData

protocol StorageCommentManager {
    func storeComments(in: AuthenticatedCommentResponseObject)
    func storeComment(remoteObject: AuthenticatedCommentResponseObject.ResourcePayload.Comment)
}

extension StorageService: StorageCommentManager {
    func storeComments(in object: AuthenticatedCommentResponseObject) {
        guard let payload = object.resourcePayload else {
            Logger.log(string: "Comments resouce payload is nil", type: .storage)
            return
        }
        var comments: [AuthenticatedCommentResponseObject.ResourcePayload.Comment] = []
        comments.append(contentsOf: payload.additionalProp1 ?? [])
        comments.append(contentsOf: payload.additionalProp2 ?? [])
        comments.append(contentsOf: payload.additionalProp3 ?? [])
        for comment in comments {
            storeComment(remoteObject: comment)
        }
        
        self.notify(event: StorageEvent(event: .Save, entity: .Comments, object: []))
    }
    
    func storeComment(remoteObject object: AuthenticatedCommentResponseObject.ResourcePayload.Comment) {
        guard let id = object.id else {
            Logger.log(string: "Can't store comment: No id", type: .storage)
            return
        }
        
        guard let context = managedContext else {
            return
        }
        
        let applicableRecords = findRecordsForComment(id: id)
        guard !applicableRecords.isEmpty else {
            Logger.log(string: "Could not find record for comment with id \(String(describing: object.id))", type: .storage)
            return
        }
        
        let storageCommentObject = genCommentObject(in: object, context: context)
        
        for record in applicableRecords {
            switch record.type {
            case .CovidTest(_):
                break
            case .CovidImmunization(_):
                break
            case .Medication(let medication):
                medication.addToComments(storageCommentObject)
            case .LaboratoryOrder(_):
                // TODO: When supporting lab order comments
                break
            }
        }
        do {
            try context.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
            return
        }
    }
    
    fileprivate func genCommentObject(in object: AuthenticatedCommentResponseObject.ResourcePayload.Comment, context: NSManagedObjectContext) -> Comment {
        let comment = Comment(context: context)
        if let versionInt = object.version {
            comment.version = Int64(versionInt)
        }
        if let createdDateTime = Date.Formatter.gatewayDateAndTime.date(from: object.createdDateTime ?? "") {
            comment.createdDateTime = createdDateTime
        }
        if let updatedDateTime = Date.Formatter.gatewayDateAndTime.date(from: object.updatedDateTime ?? "") {
            comment.updatedDateTime = updatedDateTime
        }
        comment.id = object.id
        comment.userProfileID = object.userProfileID
        comment.text = object.text
        comment.entryTypeCode = object.entryTypeCode
        comment.parentEntryID = object.parentEntryID
        comment.createdBy = object.createdBy
        comment.updatedBy = object.updatedBy
        return comment
    }
    
    fileprivate func findRecordsForComment(id: String) -> [HealthRecord] {
        // TODO: This can be refactored to be faster with request predicates
        let applicableRecords = getHeathRecords().filter { record in
            switch record.type {
                
            case .CovidTest(_):
                return false
            case .CovidImmunization(_):
                return false
            case .Medication(let medication):
                return medication.prescriptionIdentifier == id
            case .LaboratoryOrder(let labTest):
                // TODO: When supporting lab order comments
                return labTest.laboratoryReportID == id
            }
        }
        return applicableRecords
    }
}
