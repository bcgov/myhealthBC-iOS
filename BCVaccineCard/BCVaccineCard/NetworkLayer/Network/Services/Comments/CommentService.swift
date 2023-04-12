//
//  Synchronizer.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2022-08-31.
//

import Foundation
import UIKit
import Alamofire


struct CommentService {
    
    let network: Network
    let authManager: AuthManager
    let configService: MobileConfigService
    
    fileprivate static var blockSync: Bool = false
    
    var endpoints: UrlAccessor {
        return UrlAccessor()
    }
    
    public func fetchAndStore(for patient: Patient, completion: @escaping ([Comment])->Void) {
        // TODO delete existing?
        network.addLoader(message: .SyncingRecords)
        fetch(for: patient) { response in
            guard let response = response else {
                network.removeLoader()
                return completion([])
            }
            StorageService.shared.storeComments(in: response, completion: { comments in
                network.removeLoader()
                completion(comments)
            })
        }
    }
    
    public func newComment(message: String, commentID: String, hdid: String, type: CommentType, completion: @escaping (Comment?)->Void) {
        if NetworkConnection.shared.hasConnection {
            postComment(message: message, commentID: commentID, date: Date(), hdid: hdid, type: type) { result in
                guard let result = result else {
                    let comment = StorageService.shared.storeLocalComment(text: message, commentID: commentID, hdid: hdid, typeCode: type.rawValue)
                    return completion(comment)
                }
                let comment = StorageService.shared.storeSubmittedComment(object: result)
                return completion(comment)
            }
        } else {
            let comment = StorageService.shared.storeLocalComment(text: message, commentID: commentID, hdid: hdid, typeCode: type.rawValue)
            return completion(comment)
        }
        
    }
    
    public func updateComment(message: String, commentID: String, oldComment: Comment, hdid: String, type: CommentType, completion: @escaping (Comment?)->Void) {
        if NetworkConnection.shared.hasConnection {
            editComment(message: message, commentID: commentID, date: Date(), hdid: hdid, type: type) { result in
                guard let result = result else {
                    let comment = StorageService.shared.updateLocalComment(oldComment: oldComment, text: message, commentID: commentID, hdid: hdid, typeCode: type.rawValue)
                    return completion(comment)
                }
                let comment = StorageService.shared.updateSubmittedComment(oldComment: oldComment, object: result)
                return completion(comment)
            }
        } else {
            let comment = StorageService.shared.updateLocalComment(oldComment: oldComment, text: message, commentID: commentID, hdid: hdid, typeCode: type.rawValue)
            return completion(comment)
        }
        
    }
    
    // TODO: Update this to use delete logic, currently using update logic
    public func deleteComment(comment: Comment, commentID: String, hdid: String, type: CommentType, completion: @escaping (Comment?)->Void) {
        if NetworkConnection.shared.hasConnection {
            deleteComment(commentToDelete: comment, commentID: commentID, hdid: hdid, type: type) { result in
                guard let result = result else {
                    let comment = StorageService.shared.deleteLocalComment(comment: comment, commentID: commentID, hdid: hdid, typeCode: type.rawValue)
                    return completion(comment)
                }
                let comment = StorageService.shared.deleteSubmittedComment(object: result)
                return completion(comment)
            }
        } else {
            let comment = StorageService.shared.deleteLocalComment(comment: comment, commentID: commentID, hdid: hdid, typeCode: type.rawValue)
            return completion(comment)
        }
        
    }
    // TODO: Will have to find a way to make this work with edited comments, to distinguish between post, put and delete for comments adjusted offline
    public func submitUnsyncedComments(completion: @escaping()->Void) {
        if CommentService.blockSync {return completion()}
        CommentService.blockSync = true
        let comments = findCommentsToSync()
        // Must be online and authenticated
        guard !comments.isEmpty, NetworkConnection.shared.hasConnection, authManager.isAuthenticated else {
            CommentService.blockSync = false
            return completion()
        }
        incrementLoadCounter()
        let dispatchGroup = DispatchGroup()
        for comment in comments {
            dispatchGroup.enter()
            post(comment: comment) { res in
                if let result = res {
                    StorageService.shared.delete(object: comment)
                    if let storedComment = StorageService.shared.storeSubmittedComment(object: result) {
                        self.notify(event: StorageService.StorageEvent(event: .Synced, entity: .Comments, object: storedComment))
                    }
                }
                dispatchGroup.leave()
            }
        }
        dispatchGroup.notify(queue: .main) {
            decrementLoadCounter()
            CommentService.blockSync = false
            return completion()
        }
    }
    
    private func decrementLoadCounter() {
        DispatchQueue.main.async {
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                appDelegate.decrementLoader()
            }
        }
        
    }
    
    private func incrementLoadCounter() {
        DispatchQueue.main.async {
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                appDelegate.incrementLoader(message: .SyncingRecords)
            }
        }
    }
    
    private func findCommentsToSync() -> [Comment] {
        let comments = StorageService.shared.fetchComments()
        var unsynced = comments.filter({$0.id == nil})
        let synced = comments.filter({$0.id != nil})
        
        // removed unsynced comments that may have been synced
        unsynced.removeAll { unSyncedElement in
            synced.contains(where: {$0.id == unSyncedElement.id && $0.text == unSyncedElement.text && $0.createdDateTime == unSyncedElement.createdDateTime})
        }
        
        // Now unsynced contains comments that need to be uploaded
        return unsynced
    }
    
    // MARK: POST
    
    private func post(comment: Comment, completion: @escaping(PostCommentResponseResult?)->Void) {
        let type = CommentType.init(rawValue: comment.entryTypeCode ?? "") ?? .medication
        postComment(message: comment.text ?? "", commentID: comment.parentEntryID ?? "", date: comment.createdDateTime ?? Date(), hdid: comment.userProfileID ?? "", type: type, completion: completion)
    }
    
    private func postComment(message: String, commentID: String, date: Date, hdid: String, type: CommentType,completion: @escaping (PostCommentResponseResult?)->Void) {
        let model = postCommentObject(message: message, commentID: commentID, date: date, hdid: hdid, type: type)
        postComment(object: model, completion: completion)
    }
    
    private func postComment(object: PostComment, completion: @escaping(PostCommentResponseResult?)->Void) {
        guard let token = authManager.authToken, let hdid = authManager.hdid else {return}
        configService.fetchConfig { response in
            guard let config = response,
                  config.online,
                  let baseURLString = config.baseURL,
                  let baseURL = URL(string: baseURLString)
            else {
                return completion(nil)
            }
            let headers = [
                Constants.AuthenticationHeaderKeys.authToken: "Bearer \(token)",
                Constants.AuthenticationHeaderKeys.hdid: hdid
            ]
            
            let requestModel = NetworkRequest<PostComment, PostCommentResponse>(url: endpoints.comments(base: baseURL, hdid: hdid), type: .Post, parameters: object, headers: headers) { result in
                return completion(result?.resourcePayload)
            }
            
            network.request(with: requestModel)
        }
    }
    // TODO: Test out put and delete requests to make sure swagger docs aren't wrong, may need to verify
    // MARK: PUT
    
    private func edit(comment: Comment, completion: @escaping(PostCommentResponseResult?)->Void) {
        let type = CommentType.init(rawValue: comment.entryTypeCode ?? "") ?? .medication
        editComment(message: comment.text ?? "", commentID: comment.parentEntryID ?? "", date: comment.createdDateTime ?? Date(), hdid: comment.userProfileID ?? "", type: type, completion: completion)
    }
    
    private func editComment(message: String, commentID: String, date: Date, hdid: String, type: CommentType, completion: @escaping (PostCommentResponseResult?)->Void) {
        let model = postCommentObject(message: message, commentID: commentID, date: date, hdid: hdid, type: type)
        editComment(object: model, completion: completion)
    }
    
    private func editComment(object: PostComment, completion: @escaping(PostCommentResponseResult?)->Void) {
        guard let token = authManager.authToken, let hdid = authManager.hdid else {return}
        configService.fetchConfig { response in
            guard let config = response,
                  config.online,
                  let baseURLString = config.baseURL,
                  let baseURL = URL(string: baseURLString)
            else {
                return completion(nil)
            }
            let headers = [
                Constants.AuthenticationHeaderKeys.authToken: "Bearer \(token)",
                Constants.AuthenticationHeaderKeys.hdid: hdid
            ]
            
            let requestModel = NetworkRequest<PostComment, PostCommentResponse>(url: endpoints.comments(base: baseURL, hdid: hdid), type: .Put, parameters: object, headers: headers) { result in
                return completion(result?.resourcePayload)
            }
            
            network.request(with: requestModel)
        }
    }
    
    // MARK: Delete Comment
    private func delete(comment: Comment, completion: @escaping(PostCommentResponseResult?)->Void) {
        let type = CommentType.init(rawValue: comment.entryTypeCode ?? "") ?? .medication
        deleteComment(commentToDelete: comment, commentID: comment.parentEntryID ?? "", hdid: comment.userProfileID ?? "", type: type, completion: completion)
    }
    
    private func deleteComment(commentToDelete: Comment, commentID: String, hdid: String, type: CommentType, completion: @escaping (PostCommentResponseResult?)->Void) {
        let model = postCommentObject(message: commentToDelete.text ?? "", commentID: commentID, date: commentToDelete.createdDateTime ?? Date(), hdid: hdid, type: type)
        deleteComment(object: model, completion: completion)
    }
    
    private func deleteComment(object: PostComment, completion: @escaping(PostCommentResponseResult?)->Void) {
        guard let token = authManager.authToken, let hdid = authManager.hdid else {return}
        configService.fetchConfig { response in
            guard let config = response,
                  config.online,
                  let baseURLString = config.baseURL,
                  let baseURL = URL(string: baseURLString)
            else {
                return completion(nil)
            }
            let headers = [
                Constants.AuthenticationHeaderKeys.authToken: "Bearer \(token)",
                Constants.AuthenticationHeaderKeys.hdid: hdid
            ]
            
            let requestModel = NetworkRequest<PostComment, PostCommentResponse>(url: endpoints.comments(base: baseURL, hdid: hdid), type: .Delete, parameters: object, headers: headers) { result in
                return completion(result?.resourcePayload)
            }
            
            network.request(with: requestModel)
        }
    }
    
    func notify(event: StorageService.StorageEvent<Any>) {
        Logger.log(string: "StorageEvent \(event.entity) - \(event.event)", type: .storage)
        NotificationCenter.default.post(name: .storageChangeEvent, object: event)
    }

}

extension CommentService {
    enum CommentType: String {
        case medication = "Med"
        case laboratoryOrder = "ALO"
        case immunization = "im" // TODO
        case healthVisit = "Enc"
        case specialAuthorityDrug = "SAR"
        case covid = "Lab"
        case hospitalVisit = "Hos"
        case clinicalDocument = "CDO"
    }
    
    fileprivate func postCommentObject(message: String, commentID: String, date: Date, hdid: String, type: CommentType) -> PostComment {
        return PostComment(
            text: message,
            parentEntryID: commentID,
            userProfileID: hdid,
            entryTypeCode:  type.rawValue,
            createdDateTime: date.commentServerDateTime
        )
    }
}

extension HealthRecord {
    fileprivate func submitComment(text: String, hdid: String, completion: @escaping (Comment?)->Void) {
        let service = CommentService(network: AFNetwork(), authManager: AuthManager(), configService: MobileConfigService(network: AFNetwork()))
        service.newComment(message: text, commentID: commentId, hdid: hdid, type: commentType, completion: completion)
    }
    
    fileprivate func updateComment(text: String, hdid: String, oldComment: Comment, completion: @escaping (Comment?)->Void) {
        let service = CommentService(network: AFNetwork(), authManager: AuthManager(), configService: MobileConfigService(network: AFNetwork()))
        service.updateComment(message: text, commentID: commentId, oldComment: oldComment, hdid: hdid, type: commentType, completion: completion)
    }
    // TODO: Fix this
    fileprivate func deleteComment(comment: Comment, hdid: String, completion: @escaping (Comment?)->Void) {
        let service = CommentService(network: AFNetwork(), authManager: AuthManager(), configService: MobileConfigService(network: AFNetwork()))
        service.deleteComment(comment: comment, commentID: commentId, hdid: hdid, type: commentType, completion: completion)
    }
    
    fileprivate var commentType: CommentService.CommentType {
        switch self.type {
        case .CovidTest(_):
            return .covid
        case .CovidImmunization(_):
            return .covid
        case .Medication(_):
            return .medication
        case .LaboratoryOrder(_):
            return .laboratoryOrder
        case .Immunization(_):
            return .immunization
        case .HealthVisit(_):
            return .healthVisit
        case .SpecialAuthorityDrug(_):
            return .specialAuthorityDrug
        case .HospitalVisit(_):
            return .hospitalVisit
        case .ClinicalDocument(_):
            return .clinicalDocument
        }
    }
}
extension HealthRecordsDetailDataSource.Record {
    func submitComment(text: String, hdid: String, completion: @escaping (Comment?)->Void) {
        toHealthRecord()?.submitComment(text: text, hdid: hdid, completion: completion)
    }
    
    func updateComment(text: String, hdid: String, oldComment: Comment, completion: @escaping (Comment?)->Void) {
        toHealthRecord()?.submitComment(text: text, hdid: hdid, completion: completion)
    }
    
    func deleteComment(comment: Comment, hdid: String, completion: @escaping (Comment?)->Void) {
        toHealthRecord()?.deleteComment(comment: comment, hdid: hdid, completion: completion)
    }
    
    func toHealthRecord() -> HealthRecord? {
        switch type {
        case .covidImmunizationRecord:
            return nil
        case .covidTestResultRecord(let model):
            guard let parent = model.parentTest else {return nil}
            return HealthRecord(type: .CovidTest(parent))
        case .medication(model: let model):
            return HealthRecord(type: .Medication(model))
        case .laboratoryOrder(model: let model, _):
            return HealthRecord(type: .LaboratoryOrder(model))
        case .immunization(model: let model):
            return HealthRecord(type: .Immunization(model))
        case .healthVisit(model: let model):
            return HealthRecord(type: .HealthVisit(model))
        case .specialAuthorityDrug(model: let model):
            return HealthRecord(type: .SpecialAuthorityDrug(model))
        case .hospitalVisit(model: let model):
            return HealthRecord(type: .HospitalVisit(model))
        case .clinicalDocument(model: let model):
            return HealthRecord(type: .ClinicalDocument(model))
        }
        
    }
    
    // TODO: Enable Comments for specific record types here
    var commentsEnabled: Bool {
        if !HealthRecordConstants.commentsEnabled { return false}
        switch self.type {
            case .medication, .covidTestResultRecord, .laboratoryOrder, .specialAuthorityDrug, .healthVisit, .hospitalVisit, .clinicalDocument : return true
            default: return false
        }
    }
}
