//
//  NotesService.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2023-06-06.
//

import Foundation
import UIKit
import Alamofire


struct NotesService {
    
    let network: Network
    let authManager: AuthManager
    let configService: MobileConfigService
    
    fileprivate static var blockSync: Bool = false
    
    var endpoints: UrlAccessor {
        return UrlAccessor()
    }
    
    public func fetchAndStore(for patient: Patient, completion: @escaping ([Note]?)->Void) {
        network.addLoader(message: .SyncingRecords, caller: .Notes_fetchAndStore)
        fetch(for: patient) { response in
            guard let response = response else {
                network.removeLoader(caller: .Notes_fetchAndStore)
                return completion(nil)
            }
            StorageService.shared.storeNotes(in: response, for: patient) { notes in
                network.removeLoader(caller: .Notes_fetchAndStore)
                completion(notes)
            }
        }
    }
    // TODO: Enable/disable addToTimeline logic on screen
    public func newNote(title: String, text: String, journalDate: String, addToTimeline: Bool, patient: Patient, completion: @escaping (Note?)->Void) {
        if addToTimeline == false {
            postLocalNote(title: title, text: text, journalDate: journalDate) { note in
                guard let note = note, let hdid = authManager.hdid else { return completion(nil) }
                let id = UUID().uuidString
                StorageService.shared.storeLocalNote(object: note, id: id, hdid: hdid, patient: patient, completion: completion)
            }
        } else {
            if NetworkConnection.shared.hasConnection {
                postNote(title: title, text: text, journalDate: journalDate) { result in
                    guard let result = result else {
                        print("Error")
                        // TODO: Error handling here
                        return completion(nil)
                    }
                    StorageService.shared.storeNote(remoteObject: result, patient: patient, completion: completion)
                }
            } else {
                print("Error")
                // Error handling should be done already due to lack of network connection
                return completion(nil)
            }
        }
        
    }
    
    // MARK: Fetch
    
    private func fetch(for patient: Patient, completion: @escaping(_ response: AuthenticatedNotesResponseModel?) -> Void) {
        
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
            
            let parameters: HDIDParams = HDIDParams(hdid: hdid, apiVersion: "1")
            
            let requestModel = NetworkRequest<HDIDParams, AuthenticatedNotesResponseModel>(url: endpoints.notes(base: baseURL,
                                                                                                                hdid: hdid),
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
    
    // MARK: POST
    
    private func postLocalNote(title: String, text: String, journalDate: String, completion: @escaping (PostNote?)->Void) {
        let model = PostNote(title: title, text: text, journalDate: journalDate, addedToTimeline: false)
        completion(model)
    }
    
    private func postNote(title: String, text: String, journalDate: String, completion: @escaping (NoteResponse?)->Void) {
        let model = PostNote(title: title, text: text, journalDate: journalDate, addedToTimeline: true)
        postNoteNetwork(object: model, completion: completion)
    }
    
    private func postNoteNetwork(object: PostNote, completion: @escaping(NoteResponse?)->Void) {
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
            
            let requestModel = NetworkRequest<PostNote, PostNoteResponse>(url: endpoints.notes(base: baseURL, hdid: hdid), type: .Post, parameters: object, headers: headers) { result in
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

