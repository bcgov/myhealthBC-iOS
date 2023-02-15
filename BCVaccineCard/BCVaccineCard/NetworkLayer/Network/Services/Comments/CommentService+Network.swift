//
//  CommentService+Network.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2023-02-14.
//

import Foundation

typealias CommentsResponse = AuthenticatedCommentResponseObject

extension CommentService {
    func fetch(for patient: Patient, completion: @escaping(_ response: CommentsResponse?) -> Void) {
        
        guard let token = authManager.authToken,
              let hdid = patient .hdid,
              NetworkConnection.shared.hasConnection
        else { return completion(nil)}
        
        BaseURLWorker.shared.setBaseURL {
            guard BaseURLWorker.shared.isOnline == true else { return completion(nil) }
            
            let headers = [
                Constants.AuthenticationHeaderKeys.authToken: "Bearer \(token)"
            ]
            
            let parameters: HDIDParams = HDIDParams(hdid: hdid)
            
            let requestModel = NetworkRequest<HDIDParams, CommentsResponse>(url: endpoints.authenticatedComments(hdid: hdid),
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
                }
                
            }
            
            network.request(with: requestModel)
        }
    }
    
}
