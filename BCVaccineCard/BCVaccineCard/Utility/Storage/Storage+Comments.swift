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
            return completion([])
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
            return completion(nil)
        }
        
        guard let context = managedContext else {
            return completion(nil)
        }
        
        let applicableRecords = findRecordsForComment(id: id)
        guard !applicableRecords.isEmpty else {
            Logger.log(string: "Could not find record for comment with id \(String(describing: id))", type: .storage)
            return completion(nil)
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
        comment.networkMethod = UnsynchedCommentMethod.post.rawValue
        
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
            case .DiagnosticImaging(let diagnosticImaging):
                diagnosticImaging.addToComments(comment)
            case .CancerScreening(let cancerScreening):
                cancerScreening.addToComments(comment)
            case .Note(let note):
                break
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
    
    func updateSubmittedComment(oldComment: Comment, object: PostCommentResponseResult) -> Comment? {
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
        return update(oldComment: oldComment, newComment: comment, for: applicableRecords, context: context)
    }
    
    func updateLocalComment(oldComment: Comment, text: String, commentID: String, hdid: String, typeCode: String) -> Comment? {
        let applicableRecords = findRecordsForComment(id: commentID)
        guard let context = managedContext else {
            return nil
        }
        let comment = Comment(context: context)
        let now = Date()
        comment.id = oldComment.id
        comment.createdDateTime = oldComment.createdDateTime
        comment.createdBy = oldComment.createdBy
        comment.updatedDateTime = now
        comment.updatedBy = oldComment.updatedBy
        comment.text = text
        comment.parentEntryID = commentID
        comment.userProfileID = hdid
        comment.entryTypeCode = typeCode
        comment.version = oldComment.version
        comment.networkMethod = UnsynchedCommentMethod.edit.rawValue
        
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
        return update(oldComment: oldComment, newComment: comment, for: applicableRecords, context: context)
    }
    
    func deleteSubmittedComment(object: PostCommentResponseResult, commentToDelete: Comment) -> Comment? {
        guard let parentEntryId = object.parentEntryID else {return nil}
        let applicableRecords = findRecordsForComment(id: parentEntryId)
        guard let context = managedContext else {
            return nil
        }
//        let comment = Comment(context: context)
//        comment.id = object.id
//        comment.text = object.text
//        comment.userProfileID = object.userProfileID
//        comment.entryTypeCode = object.entryTypeCode
//        comment.parentEntryID = object.parentEntryID
//        comment.version = Int64(object.version ?? 0)
//        comment.createdDateTime = object.createdDateTime?.getGatewayDate()
//        comment.createdBy = object.createdBy
//        comment.updatedDateTime = object.updatedDateTime?.getGatewayDate()
//        comment.updatedBy = object.updatedBy
        
        if commentToDelete.id == object.id && commentToDelete.text == object.text && commentToDelete.userProfileID == object.userProfileID && commentToDelete.parentEntryID == object.parentEntryID {
            return delete(comment: commentToDelete, for: applicableRecords, context: context, isHardDelete: true)
        } else {
            return nil
        }
        
        
//        do {
//            try context.save()
//        } catch let error as NSError {
//            print(error)
//            Logger.log(string: "Could not save. \(error), \(error.userInfo)", type: .storage)
//        }
//        guard !applicableRecords.isEmpty else {
//            Logger.log(string: "Could not find record for comment with id \(String(describing: object.parentEntryID))", type: .storage)
//            return nil
//        }
//        return delete(comment: comment, for: applicableRecords, context: context, isHardDelete: true)
    }
    
    func deleteLocalComment(comment: Comment, commentID: String, hdid: String, typeCode: String) -> Comment? {
        let applicableRecords = findRecordsForComment(id: commentID)
        guard let context = managedContext else {
            return nil
        }
        
        let commentToDelete = comment
        commentToDelete.networkMethod = UnsynchedCommentMethod.delete.rawValue
        commentToDelete.shouldHide = true
//        commentToDelete.id = nil
        
        do {
            try context.save()
        } catch let error as NSError {
            print(error)
            Logger.log(string: "Could not delete. \(error), \(error.userInfo)", type: .storage)
        }
        guard !applicableRecords.isEmpty else {
            Logger.log(string: "Could not find record for comment with id \(String(describing: commentID))", type: .storage)
            return nil
        }
        return delete(comment: comment, for: applicableRecords, context: context, isHardDelete: false)
    }
    
    fileprivate func update(oldComment: Comment, newComment: Comment, for records: [HealthRecord], context: NSManagedObjectContext) -> Comment? {
        guard newComment.parentEntryID != nil && newComment.parentEntryID != "" else {
            Logger.log(string: "Invalid comment", type: .storage)
            return nil
        }
        for record in records {
            switch record.type {
            case .CovidTest(let covidTest):
                covidTest.removeFromComments(oldComment)
                covidTest.addToComments(newComment)
            case .CovidImmunization(_):
                break
            case .Medication(let medication):
                medication.removeFromComments(oldComment)
                medication.addToComments(newComment)
            case .LaboratoryOrder(let labOrder):
                labOrder.removeFromComments(oldComment)
                labOrder.addToComments(newComment)
            case .Immunization(_):
                break
            case .HealthVisit(let healthVisit):
                healthVisit.removeFromComments(oldComment)
                healthVisit.addToComments(newComment)
            case .SpecialAuthorityDrug(let saDrug):
                saDrug.removeFromComments(oldComment)
                saDrug.addToComments(newComment)
            case .HospitalVisit(let hospitalVisit):
                hospitalVisit.removeFromComments(oldComment)
                hospitalVisit.addToComments(newComment)
            case .ClinicalDocument(let clinicalDoc):
                clinicalDoc.removeFromComments(oldComment)
                clinicalDoc.addToComments(newComment)
            case .DiagnosticImaging(let diagnostiImaging):
                diagnostiImaging.removeFromComments(oldComment)
                diagnostiImaging.addToComments(newComment)
            case .CancerScreening(let cancerScreening):
                cancerScreening.removeFromComments(oldComment)
                cancerScreening.addToComments(newComment)
            case .Note(let note):
                break
            }
        }
        do {
            try context.save()
            return newComment
        } catch let error as NSError {
            print(error)
            Logger.log(string: "Could not update. \(error), \(error.userInfo)", type: .storage)
            return nil
        }
    }
    
    fileprivate func delete(comment: Comment, for records: [HealthRecord], context: NSManagedObjectContext, isHardDelete: Bool) -> Comment? {
        guard comment.parentEntryID != nil && comment.parentEntryID != "" else {
            Logger.log(string: "Invalid comment", type: .storage)
            return nil
        }
        for record in records {
            switch record.type {
            case .CovidTest(let covidTest):
                covidTest.removeFromComments(comment)
            case .CovidImmunization(_):
                break
            case .Medication(let medication):
                medication.removeFromComments(comment)
            case .LaboratoryOrder(let labOrder):
                labOrder.removeFromComments(comment)
            case .Immunization(_):
                break
            case .HealthVisit(let healthVisit):
                healthVisit.removeFromComments(comment)
            case .SpecialAuthorityDrug(let saDrug):
                saDrug.removeFromComments(comment)
            case .HospitalVisit(let hospitalVisit):
                hospitalVisit.removeFromComments(comment)
            case .ClinicalDocument(let clinicalDoc):
                clinicalDoc.removeFromComments(comment)
            case .DiagnosticImaging(let diagnosticImaging):
                diagnosticImaging.removeFromComments(comment)
            case .CancerScreening(let cancerScreening):
                cancerScreening.removeFromComments(comment)
            case .Note(let note):
                break
            }
        }
        if isHardDelete {
            delete(object: comment)
        }
        return comment
    }
}

