//
//  Storage+Comments.swift
//  BCVaccineCard
//
//  Created by Amir on 2022-03-03.
//

import Foundation
import CoreData

protocol StorageCommentManager {
    func storeComments(in: AuthenticatedCommentResponseObject, completion: @escaping([Comment])->Void)
    func storeComment(remoteObject: AuthenticatedCommentResponseObject.Comment, completion: @escaping(Comment?)->Void)
    
    func fetchComments() -> [Comment]
    func storeLocalComment(text: String, commentID: String, hdid: String, typeCode: String) -> Comment?
}

extension StorageService: StorageCommentManager {
    func storeComments(in object: AuthenticatedCommentResponseObject, completion: @escaping([Comment])->Void) {
        
        let comments: [AuthenticatedCommentResponseObject.Comment] = object.resourcePayload.flatMap({$0.value})
       
        guard !comments.isEmpty else {
            Logger.log(string: "No Comments", type: .storage)
            return
        }
        var storedComments: [Comment] = []
        let group = DispatchGroup()
        for comment in comments {
            group.enter()
            storeComment(remoteObject: comment, completion: { result in
                if let stored = result {
                    storedComments.append(stored)
                }
                group.leave()
            })
        }
        group.notify(queue: .main) {
            self.notify(event: StorageEvent(event: .Save, entity: .Comments, object: storedComments))
            return completion(storedComments)
        }
        
        
    }
    
    func storeComment(remoteObject object: AuthenticatedCommentResponseObject.Comment, completion: @escaping(Comment?)->Void) {
        guard let id = object.parentEntryID else {
            Logger.log(string: "Can't store comment: No id", type: .storage)
            return
        }
        
        guard let context = managedContext else {
            return
        }
        
        let applicableRecords = findRecordsForComment(id: id)
        guard !applicableRecords.isEmpty else {
            Logger.log(string: "Could not find record for comment with id \(String(describing: id))", type: .storage)
            return
        }
        
        let storageCommentObject = genCommentObject(in: object, context: context)
        
        let result = store(comment: storageCommentObject, for: applicableRecords, context: context)
        return completion(result)
    }
    
   
    func storeLocalComment(text: String, commentID: String, hdid: String, typeCode: String) -> Comment? {
        let applicableRecords = findRecordsForComment(id: commentID)
        guard let context = managedContext else {
            return nil
        }
        let comment = Comment(context: context)
        let now = Date()
        comment.createdDateTime = now
        comment.updatedDateTime = now
        comment.text = text
        comment.parentEntryID = commentID
        comment.userProfileID = hdid
        comment.entryTypeCode = typeCode
        
        do {
            try context.save()
        } catch let error as NSError {
            print(error)
            Logger.log(string: "Could not save. \(error), \(error.userInfo)", type: .storage)
        }
        guard !applicableRecords.isEmpty else {
            Logger.log(string: "Could not find record for comment with id \(String(describing: commentID))", type: .storage)
            return nil
        }
        return store(comment: comment, for: applicableRecords, context: context)
    }
    
    func storeSubmittedComment(object: PostCommentResponseResult) -> Comment? {
        guard let parentEntryId = object.parentEntryID else {return nil}
        let applicableRecords = findRecordsForComment(id: parentEntryId)
        guard let context = managedContext else {
            return nil
        }
        let comment = Comment(context: context)
        comment.id = object.id
        comment.text = object.text
        comment.userProfileID = object.userProfileID
        comment.entryTypeCode = object.entryTypeCode
        comment.parentEntryID = object.parentEntryID
        comment.version = Int64(object.version ?? 0)
        comment.createdDateTime = object.createdDateTime?.getGatewayDate()
        comment.createdBy = object.createdBy
        comment.updatedDateTime = object.updatedDateTime?.getGatewayDate()
        comment.updatedBy = object.updatedBy
        
        
        do {
            try context.save()
        } catch let error as NSError {
            print(error)
            Logger.log(string: "Could not save. \(error), \(error.userInfo)", type: .storage)
        }
        guard !applicableRecords.isEmpty else {
            Logger.log(string: "Could not find record for comment with id \(String(describing: object.parentEntryID))", type: .storage)
            return nil
        }
        return store(comment: comment, for: applicableRecords, context: context)
    }
    
    fileprivate func store(comment: Comment, for records: [HealthRecord], context: NSManagedObjectContext) -> Comment? {
        guard comment.parentEntryID != nil && comment.parentEntryID != "" else {
            Logger.log(string: "Invalid comment", type: .storage)
            return nil
        }
        for record in records {
            switch record.type {
            case .CovidTest(let covidTest):
                covidTest.addToComments(comment)
            case .CovidImmunization(_):
                break
            case .Medication(let medication):
                medication.addToComments(comment)
            case .LaboratoryOrder(let labOrder):
                labOrder.addToComments(comment)
            case .Immunization(_):
                break
            case .HealthVisit(let healthVisit):
                healthVisit.addToComments(comment)
            case .SpecialAuthorityDrug(let saDrug):
                saDrug.addToComments(comment)
            case .HospitalVisit(let hospitalVisit):
                hospitalVisit.addToComments(comment)
            case .ClinicalDocument(let clinicalDoc):
                clinicalDoc.addToComments(comment)
            }
        }
        do {
            try context.save()
            return comment
        } catch let error as NSError {
            print(error)
            Logger.log(string: "Could not save. \(error), \(error.userInfo)", type: .storage)
            return nil
        }
    }
    
    
    fileprivate func genCommentObject(in object: AuthenticatedCommentResponseObject.Comment, context: NSManagedObjectContext) -> Comment {
        let comment = Comment(context: context)
        if let versionInt = object.version {
            comment.version = Int64(versionInt)
        }
        if let createdDateTime = Date.Formatter.gatewayDateAndTimeWithMSAndTimeZone.date(from: object.createdDateTime ?? "") {
            comment.createdDateTime = createdDateTime
        }
        if let updatedDateTime = Date.Formatter.gatewayDateAndTimeWithMSAndTimeZone.date(from: object.updatedDateTime ?? "") {
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
        let applicableRecords = getHeathRecords().filter({$0.commentId == id})
        if applicableRecords.isEmpty {
            Logger.log(string: "Could not match comment id with a health record", type: .storage)
        }
        return applicableRecords
    }
    
    func fetchComments() -> [Comment] {
        guard let context = managedContext else {return []}
        do {
            let results = try context.fetch(Comment.fetchRequest())
            return results
        } catch let error as NSError {
            Logger.log(string: "Could not save. \(error), \(error.userInfo)", type: .storage)
            return []
        }
    }
}

