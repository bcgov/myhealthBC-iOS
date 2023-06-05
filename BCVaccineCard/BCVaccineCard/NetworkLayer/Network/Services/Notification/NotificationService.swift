//
//  NotificationService.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2023-05-26.
//

import Foundation

struct NotificationService {
    
    let network: Network
    let authManager: AuthManager
    let configService: MobileConfigService
    
    private var endpoints: UrlAccessor {
        return UrlAccessor()
    }
    
    func fetchAndStore(for patient: Patient, completion: @escaping ([GatewayNotification])->Void) {
        network.addLoader(message: .SyncingRecords, caller: .NotificationService_fetchAndStore)
        fetch(for: patient) { resposne in
            guard let resposne = resposne else {
                network.removeLoader(caller: .NotificationService_fetchAndStore)
                return
                completion([])
            }
            StorageService.shared.deleteNotifications()
            StorageService.shared.store(notifications: resposne, for: patient) { storedObjects in
                network.removeLoader(caller: .NotificationService_fetchAndStore)
                completion(storedObjects)
            }
        }
    }
    
    func dimissAll(completion: @escaping ()->Void) {
        
    }
    
    func dimiss(id: String, completion: @escaping ()->Void) {
        
    }
}

extension NotificationService {

    func fetch(for patient: Patient, completion: @escaping(_ response: AuthenticatedNotificationResponse?) -> Void) {
        
        guard let token = authManager.authToken,
              let hdid = patient.hdid,
              NetworkConnection.shared.hasConnection
        else { return completion(nil)}
        
        configService.fetchConfig { response in
            guard let config = response,
                  config.online,
                  let baseURLString = config.baseURL,
                  let baseURL = URL(string: baseURLString)
            else {
                return completion(nil)
            }
            let headers = [
                Constants.AuthenticationHeaderKeys.authToken: "Bearer \(token)"
            ]
            
            let parameters: DefaultParams = DefaultParams(apiVersion: "1")
            
            let requestModel = NetworkRequest<DefaultParams, AuthenticatedNotificationResponse>(url: endpoints.notifcations(base: baseURL, hdid: hdid),
                                                                            type: .Get,
                                                                            parameters: parameters,
                                                                            encoder: .urlEncoder,
                                                                            headers: headers)
            { result in
                return completion(result)
            } onError: { error in
                switch error {
                case .FailedAfterRetry:
                    network.showToast(message: .fetchRecordError, style: .Warn)
                default:
                    break
                }
                
            }
            
            network.request(with: requestModel)
        }
    }
    
    private func deleteComment(object: DeleteComment, completion: @escaping(PostCommentResponseResult?)->Void) {
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
            
            let requestModel = NetworkRequest<DeleteComment, PostCommentResponse>(url: endpoints.comments(base: baseURL, hdid: hdid), type: .Delete, parameters: object, headers: headers) { result in
                return completion(result?.resourcePayload)
            }
            
            network.request(with: requestModel)
        }
    }
}
    
extension GatewayNotification {
    enum ActionType: String, Codable {
        case externalLink = "ExternalLink"
        case internalLink = "InternalLink"
        case none = "None"
    }
    
    var actionTypeEnum: ActionType? {
        guard let type = actionType else {
            return nil
        }
        return ActionType(rawValue: type)
    }
}
