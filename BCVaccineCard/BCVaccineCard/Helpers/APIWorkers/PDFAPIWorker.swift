//
//  PDFAPIWorker.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2022-09-08.
//

import UIKit

class PDFAPIWorker: NSObject {
    
    private var apiClient: APIClient
    private var queueItDelegateOwner: UIViewController
    private var authCredentials: AuthenticationRequestObject
    
    init(delegateOwner: UIViewController, authCredentials: AuthenticationRequestObject) {
        self.apiClient = APIClient(delegateOwner: delegateOwner)
        self.queueItDelegateOwner = delegateOwner
        self.authCredentials = authCredentials
    }
    
    func getAuthenticatedLabPDF(authCredentials: AuthenticationRequestObject, reportId: String, type: LabTestType, completion: @escaping (String?) -> Void) {
        let queueItTokenCached = Defaults.cachedQueueItObject?.queueitToken
        apiClient.getAuthenticatedLabTestPDF(authCredentials, token: queueItTokenCached, reportId: reportId, executingVC: queueItDelegateOwner, includeQueueItUI: false, type: type) { [weak self] result, queueItRetryStatus in
            guard let `self` = self else {
                completion(nil)
                return
            }
            if let retry = queueItRetryStatus, retry.retry == true {
                let queueItToken = retry.token
                self.apiClient.getAuthenticatedLabTestPDF(authCredentials, token: queueItToken, reportId: reportId, executingVC: self.queueItDelegateOwner, includeQueueItUI: false, type: type) { [weak self] result, _ in
                    guard let `self` = self else {
                        completion(nil)
                        return
                    }
                    return self.handlePDFResponse(result: result, completion: completion)
                }
            } else {
                return self.handlePDFResponse(result: result, completion: completion)
            }

        }
    }
    
    private func handlePDFResponse(result: Result<AuthenticatedPDFResponseObject, ResultError>, completion: @escaping (String?) -> Void) {
        switch result {
        case .success(let pdfObject):
            // Note: Have to check for error here because error is being sent back on a 200 response
            if let resultMessage = pdfObject.resultError?.resultMessage, ((pdfObject.resourcePayload?.data ?? "").isEmpty) {
                Logger.log(string: "Error fetching PDF data", type: .Network)
                completion(nil)
            } else {
                completion(pdfObject.resourcePayload?.data)
            }
        case .failure(let error):
//            showFetchFailed()
            Logger.log(string: "Error fetching PDF data: " + (error.resultMessage ?? ""), type: .Network)
            completion(nil)
        }
    }
    
}

