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
    
    func fetchAndStore(for patient: Patient, loadingStyle: LoaderMessage, completion: @escaping ([GatewayNotification])->Void) {
        network.addLoader(message: loadingStyle, caller: .NotificationService_fetchAndStore)
        fetch(for: patient) { resposne in
            guard let resposne = resposne else {
                SessionStorage.notificationFethFilure = true
                network.removeLoader(caller: .NotificationService_fetchAndStore)
                return completion([])
            }
            SessionStorage.notificationFethFilure = false
            StorageService.shared.deleteNotifications()
            StorageService.shared.store(notifications: resposne, for: patient) { storedObjects in
                network.removeLoader(caller: .NotificationService_fetchAndStore)
                completion(storedObjects)
            }
        }
    }
    
    func dimissAll(for patient: Patient, completion: @escaping (Bool)->Void) {
        network.addLoader(message: .empty, caller: .NotificationService_dismissAll)
        deleteAll() { success in
            network.removeLoader(caller: .NotificationService_dismissAll)
            if success {
                fetchAndStore(for: patient, loadingStyle: .empty, completion: {_ in
                    return completion(true)
                })
            } else {
                return completion(false)
            }
        }
    }
    
    func dimiss(notification: GatewayNotification, completion: @escaping (Bool)->Void) {
        guard let patient = notification.patient else {
            return completion(false)
        }
        network.addLoader(message: .empty, caller: .NotificationService_dismiss)
        delete(notification: notification) { success in
            network.removeLoader(caller: .NotificationService_dismiss)
            if success {
                fetchAndStore(for: patient, loadingStyle: .empty, completion: {_ in 
                    return completion(true)
                })
            } else {
                return completion(false)
            }
        }
    }
}

extension NotificationService {

    func fetch(for patient: Patient, completion: @escaping(_ response: AuthenticatedNotificationResponse?) -> Void) {
        
        guard let token = authManager.authToken,
              let hdid = patient.hdid,
              NetworkConnection.shared.hasConnection
        else {return completion(nil)}
        
        configService.fetchConfig { response in
            guard let config = response,
                  config.online,
                  let baseURLString = config.baseURL,
                  let baseURL = URL(string: baseURLString)
            else {
                network.showToast(message: .maintenanceMessage, style: .Warn)
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
    
    private func deleteAll(completion: @escaping(Bool)->Void) {
        guard let token = authManager.authToken, let hdid = authManager.hdid else {return}
        configService.fetchConfig { response in
            guard let config = response,
                  config.online,
                  let baseURLString = config.baseURL,
                  let baseURL = URL(string: baseURLString)
            else {
                network.showToast(message: .maintenanceMessage, style: .Warn)
                return completion(false)
            }
            let headers = [
                Constants.AuthenticationHeaderKeys.authToken: "Bearer \(token)",
                Constants.AuthenticationHeaderKeys.hdid: hdid
            ]
            let url = endpoints.notifcations(base: baseURL, hdid: hdid)
            
            let parameters: DefaultParams = DefaultParams(apiVersion: "1")
            
            let requestModel = NetworkRequest<DefaultParams, Int>(url: url, type: .Delete, parameters: parameters, headers: headers) { result in
                print(result)
                return completion(result == 200)
            }
            
            network.request(with: requestModel)
        }
    }
    
    private func delete(notification: GatewayNotification, completion: @escaping(Bool)->Void) {
        guard let token = authManager.authToken, let hdid = authManager.hdid else {return}
        configService.fetchConfig { response in
            guard let config = response,
                  config.online,
                  let baseURLString = config.baseURL,
                  let baseURL = URL(string: baseURLString),
                  let notificationId = notification.id
            else {
                network.showToast(message: .maintenanceMessage, style: .Warn)
                return completion(false)
            }
            let headers = [
                Constants.AuthenticationHeaderKeys.authToken: "Bearer \(token)",
                Constants.AuthenticationHeaderKeys.hdid: hdid
            ]
            let url = endpoints.deleteNotifcations(base: baseURL, hdid: hdid, notificationID: notificationId)
            
            let parameters: DefaultParams = DefaultParams(apiVersion: "1")
            
            let requestModel = NetworkRequest<DefaultParams, Int>(url: url, type: .Delete, parameters: parameters, headers: headers) { result in
                print(result)
                return completion(result == 200)
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
    
    var category: NotificationCategory? {
        guard let category = categoryName else {
            return nil
        }
        return NotificationCategory(rawValue: category)
    }
}
