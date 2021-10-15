//
//  QueueItWorker.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-10-14.
//

import QueueITLibrary
import Alamofire
import Foundation

protocol QueueItWorkerDefaultsDelegate: AnyObject {
    func handleVaccineCard(localModel: LocallyStoredVaccinePassportModel)
    func handleError(title: String, error: ResultError)
    func showLoader()
    func hideLoader()
}

class QueueItWorker: NSObject {
    
    private var engine: QueueITEngine?
    private var model: GatewayVaccineCardRequest?
    private var customerID: String?
    private var eventAlias: String?
    private var queueitToken: String?
    private var cookieHeader: [String: String]?
    
    private var url: URL?
    
    private var delegateOwner: UIViewController
    private var healthGateway: HealthGatewayBCGateway
    private weak var delegate: QueueItWorkerDefaultsDelegate?
    
    init(delegateOwner: UIViewController, healthGateway: HealthGatewayBCGateway, delegate: QueueItWorkerDefaultsDelegate) {
        self.delegateOwner = delegateOwner
        self.healthGateway = healthGateway
        self.delegate = delegate
    }
}

// MARK: Queue It Setup
extension QueueItWorker: QueuePassedDelegate, QueueViewWillOpenDelegate, QueueDisabledDelegate, QueueITUnavailableDelegate, QueueUserExitedDelegate, QueueViewClosedDelegate {
    
    // This callback will be triggered when the user has been through the queue.
    // Here you should store session information, so user will only be sent to queue again if the session has timed out.
    private func queueItSetup() {
        guard let customerID = self.customerID, let eventAlias = self.eventAlias else { return }
        self.engine = QueueITEngine.init(host: self.delegateOwner, customerId: customerID, eventOrAliasId: eventAlias, layoutName: nil, language: nil)
        self.engine?.queuePassedDelegate = self // Invoked once the user is passed the queue
        self.engine?.queueViewWillOpenDelegate = self // Invoked to notify that Queue-It UIWebView or WKWebview will open
        self.engine?.queueDisabledDelegate = self // Invoked to notify that queue is disabled
        self.engine?.queueITUnavailableDelegate = self // Invoked in case QueueIT is unavailable (500 errors)
        self.engine?.queueUserExitedDelegate = self // Invoked when user chooses to leave the queue
    }
    
    private func runQueueIt() {
        do {
            try engine?.run()
        }
        catch let err {
            // TODO: Handle reasons for not being able to start queue it here
            print("CONNOR FAILED TO RUN: ", err)
            print("CONNOR ERROR CODE: ", (err as NSError).code)
            self.delegate?.hideLoader()
            let errorCode = (err as NSError).code
            if errorCode == NetworkUnavailable.rawValue {
                self.delegate?.handleError(title: "Network Unavailable", error: ResultError(resultMessage: "The network is currently unavailable, please try again later"))
            } else if errorCode == RequestAlreadyInProgress.rawValue {
                // Need to fetch locally stored Cookie and token
                self.fetchValueFromDefaults()
                guard let model = self.model, let url = self.url, let cookieHeadString = self.cookieHeader else {
                    self.delegate?.handleError(title: "In Progress Error", error: ResultError(resultMessage: "There was an error with your in progress request, please try again later."))
                    return
                }
                let cookies = HTTPCookie.cookies(withResponseHeaderFields: cookieHeadString, for: url)
                AF.session.configuration.httpCookieStorage?.setCookies(cookies, for: url, mainDocumentURL: nil)
                self.getActualVaccineCard(model: model, token: self.queueitToken)
            } else {
                self.delegate?.handleError(title: "Error", error: ResultError(resultMessage: "An unknown error occured."))
            }
            
        }
    }
    
    // This callback will be triggered just before the webview (hosting the queue page) will be shown.
    // Here you can change some relevant UI elements.
    func notifyYourTurn(_ queuePassedInfo: QueuePassedInfo!) {
        print("CONNOR QUEUE IT: ", queuePassedInfo)
        self.queueitToken = queuePassedInfo?.queueitToken
        self.saveValueToDefaults(queueitToken: self.queueitToken)
        guard let model = self.model, let token = self.queueitToken else {
            self.delegate?.hideLoader()
            self.delegate?.handleError(title: "Error", error: ResultError(resultMessage: "There was an issue with your request, please try again."))
            return
        }
        getActualVaccineCard(model: model, token: token)
    }
    
    // This callback will be triggered when the queue used (event alias ID) is in the 'disabled' state.
    // Most likely the application should still function, but the queue's 'disabled' state can be changed at any time,
    // so session handling is important.
    func notifyQueueViewWillOpen() {
        print("CONNOR QUEUE IT: notifyQueueViewWillOpen")
    }
    
    // This callback will be triggered when the mobile application can't reach Queue-it's servers.
    // Most likely because the mobile device has no internet connection.
    // Here you decide if the application should function or not now that is has no queue-it protection.
    func notifyQueueDisabled() {
        print("CONNOR QUEUE IT: notifyQueueDisabled")
    }
    
    // This callback will be triggered after a user clicks a close link in the layout and the WebView closes.
    // The close link is "queueit://close". Whenever the user navigates to this link, the SDK intercepts the navigation
    // and closes the webview.
    func notifyQueueITUnavailable(_ errorMessage: String!) {
        print("CONNOR QUEUE IT: errorMessage: ", errorMessage)
        self.delegate?.hideLoader()
        self.delegate?.handleError(title: "QueueIt Waiting Room Closed", error: ResultError(resultMessage: errorMessage ?? "You have closed the QueueIt waiting room"))
    }
    
    func notifyUserExited() {
        print("CONNOR QUEUE IT: notifyUserExited")
    }
    
    func notifyViewClosed() {
        print("CONNOR QUEUE IT: notifyViewClosed")
    }
    
}

// MARK: Alamofire requests
extension QueueItWorker {
    func createInitialVaccineCardRequest(model: GatewayVaccineCardRequest) {
        self.model = model
        self.delegate?.showLoader()
        let interceptor = NetworkRequestInterceptor()
        let headerParameters: HTTPHeaders = [
            "phn": model.phn,
            "dateOfBirth": model.dateOfBirth,
            "dateOfVaccine": model.dateOfVaccine
        ]
        // TODO: Need to find a better way to get URL - ran out of time
        AF.request(URL(string: "https://healthgateway.gov.bc.ca/api/immunizationservice/v1/api/VaccineStatus")!, method: .get, headers: headerParameters, interceptor: interceptor).response { response in
            // Check for queue it cookie here, if it's there, set the cookie and make actual request
            self.url = response.request?.url
            if let cookie = response.response?.allHeaderFields["Set-Cookie"] as? String, cookie.contains("QueueITAccepted") {
                let header = response.response?.allHeaderFields as? [String: String]
                self.saveValueToDefaults(cookieHeader: header)
                guard let model = self.model else {
                    self.delegate?.hideLoader()
                    self.delegate?.handleError(title: "Error", error: ResultError(resultMessage: "There was an issue with your request, please try again."))
                    return
                }
                self.getActualVaccineCard(model: model, token: nil)
            } else if let redirectURLStringEndcoded = response.response?.allHeaderFields["x-queueit-redirect"] as? String,
                      let decodedURLString = redirectURLStringEndcoded.removingPercentEncoding,
                      let url = URL(string: decodedURLString),
                      let items = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems {
                self.customerID = items.first(where: { $0.name == "c" })?.value
                self.eventAlias = items.first(where: { $0.name == "e" })?.value
                self.saveValueToDefaults(customerID: self.customerID, eventAlias: self.eventAlias)
                self.queueItSetup()
                self.runQueueIt()
            } else {
                self.delegate?.hideLoader()
                switch response.result {
                case .success(_):
                    // This shouldn't happen, but putting this here in case
                    self.delegate?.handleError(title: "Error", error: ResultError(resultMessage: "There was an issue with your request, please try again."))
                case .failure(let error):
                    self.delegate?.handleError(title: "Error", error: ResultError(resultMessage: error.errorDescription))
                }
            }
        }
    }
    
    private func getActualVaccineCard(model: GatewayVaccineCardRequest, token: String?) {
        self.healthGateway.requestVaccineCard(model, token: token) { [weak self ] result in
            guard let `self` = self else {return}
            switch result {
            case .success(let vaccineCard):
                print(vaccineCard)
                // Note: Have to add error handling here, because whoever set up this response didn't do it correctly - error is part of ths success response object
                // Noticed: Errors seem to be very inconsistent in terms of the response object
                self.delegate?.hideLoader()
                if let resultMessage = vaccineCard.resultError?.resultMessage {
                    let adjustedMessage = resultMessage == "Error parsing phn" ? "There was an error with your Personal Health Number. Please check that it is correct and try again." : resultMessage
                    self.delegate?.handleError(title: "Error", error: ResultError(resultMessage: adjustedMessage))
                }
                guard let localVaccineCard = vaccineCard.transformResponseIntoLocallyStoredVaccinePassportModel() else {
                    self.delegate?.handleError(title: "Error", error: ResultError(resultMessage: "There was an issue with your request, please check your information and try again."))
                    return
                }
                self.delegate?.handleVaccineCard(localModel: localVaccineCard)
            case .failure(let error):
                print(error)
                self.delegate?.hideLoader()
                self.delegate?.handleError(title: "Error", error: error)
            }
        }
    }
    
}

// MARK: Handling cached queueIt object
extension QueueItWorker {

    func saveValueToDefaults(customerID: String? = nil, eventAlias: String? = nil, queueitToken: String? = nil, cookieHeader: [String: String]? = nil) {
        if let customerID = customerID {
            if let _ = Defaults.cachedQueueItObject {
                Defaults.cachedQueueItObject?.customerID = customerID
            } else {
                Defaults.cachedQueueItObject = QueueItCachedObject(customerID: customerID, eventAlias: nil, queueitToken: nil, cookieHeader: nil)
            }
        }
        if let eventAlias = eventAlias {
            if let _ = Defaults.cachedQueueItObject {
                Defaults.cachedQueueItObject?.eventAlias = eventAlias
            } else {
                Defaults.cachedQueueItObject = QueueItCachedObject(customerID: nil, eventAlias: eventAlias, queueitToken: nil, cookieHeader: nil)
            }
        }
        if let queueitToken = queueitToken {
            if let _ = Defaults.cachedQueueItObject {
                Defaults.cachedQueueItObject?.queueitToken = queueitToken
            } else {
                Defaults.cachedQueueItObject = QueueItCachedObject(customerID: nil, eventAlias: nil, queueitToken: queueitToken, cookieHeader: nil)
            }
        }
        if let cookieHeader = cookieHeader {
            if let _ = Defaults.cachedQueueItObject {
                Defaults.cachedQueueItObject?.cookieHeader = cookieHeader
            } else {
                Defaults.cachedQueueItObject = QueueItCachedObject(customerID: customerID, eventAlias: nil, queueitToken: nil, cookieHeader: cookieHeader)
            }
        }
    }
    
    func fetchValueFromDefaults() {
        guard let cached = Defaults.cachedQueueItObject else { return }
        self.customerID = cached.customerID
        self.eventAlias = cached.eventAlias
        self.queueitToken = cached.queueitToken
        self.cookieHeader = cached.cookieHeader
    }
}
