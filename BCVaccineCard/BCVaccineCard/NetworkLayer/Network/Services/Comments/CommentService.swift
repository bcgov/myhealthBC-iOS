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
    
    private var endpoints: UrlAccessor {
        return UrlAccessor()
    }
    
    public func newComment(message: String, commentID: String, hdid: String, type: CommentType, completion: @escaping ()->Void) {
        if NetworkConnection.shared.hasConnection {
            postComment(message: message, commentID: commentID, date: Date(), hdid: hdid, type: type) { result in
                guard let result = result else {
                    StorageService.shared.storeLocalComment(text: message, commentID: commentID)
                    return completion()
                }
                print(result)
                // TODO
                return completion()
            }
        } else {
            StorageService.shared.storeLocalComment(text: message, commentID: commentID)
            return completion()
        }
        
    }
    
    func findCommentsToSync() -> [Comment] {
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
    
    func postComment(message: String, commentID: String, date: Date, hdid: String, type: CommentType,completion: @escaping (PostCommentResponseResult?)->Void) {
        let model = postCommentObject(message: message, commentID: commentID, date: date, hdid: hdid, type: type)
        postComment(object: model, completion: completion)
    }
    
    private func postComment(object: PostComment, completion: @escaping(PostCommentResponseResult?)->Void) {
        guard let token = authManager.authToken, let hdid = authManager.hdid else {return}
        BaseURLWorker.shared.setBaseURL {
            guard BaseURLWorker.shared.isOnline == true else {return completion(nil)}
            
            let headers = [
                Constants.AuthenticationHeaderKeys.authToken: "Bearer \(token)",
                Constants.AuthenticationHeaderKeys.hdid: hdid
            ]
            
            let requestModel = NetworkRequest<PostComment, PostCommentResponse>(url: endpoints.authenticatedComments(hdid: hdid), type: .Post, parameters: object, headers: headers) { result in
                    print(result)
                completion(result?.resourcePayload)
            }
            
            network.request(with: requestModel)
        }
    }
}

extension CommentService {
    enum CommentType: String {
        case medication = "Med"
        case laboratoryOrder = "la" // TODO
        case immunization = "im" // TODO
        case healthVisit = "vis" // TODO
        case specialAuthorityDrug = "sa" //TODO
        case covid = "covid" //Todo
    }
    
    fileprivate func postCommentObject(message: String, commentID: String, date: Date, hdid: String, type: CommentType) -> PostComment {
        return PostComment(text: message, parentEntryID: commentID, userProfileID: hdid, entryTypeCode:  type.rawValue, createdDateTime: date.gatewayDateAndTimeWithMSAndTimeZone)
    }
}

extension HealthRecord {
    fileprivate func submitComment(text: String, hdid: String, completion: @escaping ()->Void) {
        let service = CommentService(network: CustomNetwork(), authManager: AuthManager())
        service.newComment(message: text,commentID: commentId, hdid: hdid, type: commentType, completion: completion)
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
        }
    }
}
extension HealthRecordsDetailDataSource.Record {
    func submitComment(text: String, hdid: String, completion: @escaping ()->Void) {
        toHealthRecord()?.submitComment(text: text, hdid: hdid, completion: completion)
    }
    
    func toHealthRecord() -> HealthRecord? {
        switch type {
        case .covidImmunizationRecord:
            return nil
        case .covidTestResultRecord:
            return nil
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
        }
        
    }
}
