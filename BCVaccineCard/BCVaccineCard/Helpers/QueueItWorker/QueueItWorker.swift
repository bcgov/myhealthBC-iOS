//
//  QueueItWorker.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-10-14.
//

import QueueITLibrary
import Alamofire
import UIKit
import BCVaccineValidator

protocol QueueItWorkerDefaultsDelegate: AnyObject {
    func handleVaccineCard(scanResult: ScanResultModel, fedCode: String?)
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
    
    private var retryOnEmptyPDFCount: Int = 0
    
    private var delegateOwner: UIViewController
    private var apiClient = APIClient()
    private weak var delegate: QueueItWorkerDefaultsDelegate?
    private var endpoint: URL
    
    init(delegateOwner: UIViewController, delegate: QueueItWorkerDefaultsDelegate, endpoint: URL) {
        self.delegateOwner = delegateOwner
        self.delegate = delegate
        self.endpoint = endpoint
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
            // Handle reasons for not being able to start the queue here.
            self.delegate?.hideLoader()
            let errorCode = (err as NSError).code
            if errorCode == NetworkUnavailable.rawValue {
                self.delegate?.handleError(title: .networkUnavailableTitle, error: ResultError(resultMessage: .networkUnavailableMessage))
            } else if errorCode == RequestAlreadyInProgress.rawValue {
                // Need to fetch locally stored Cookie and token
                self.fetchValueFromDefaults()
                guard let model = self.model, let url = self.url, let cookieHeadString = self.cookieHeader else {
                    self.delegate?.handleError(title: .inProgressErrorTitle, error: ResultError(resultMessage: .inProgressErrorMessage))
                    return
                }
                let cookies = HTTPCookie.cookies(withResponseHeaderFields: cookieHeadString, for: url)
                AF.session.configuration.httpCookieStorage?.setCookies(cookies, for: url, mainDocumentURL: nil)
                self.delegate?.showLoader()
                self.getActualVaccineCard(model: model, token: self.queueitToken)
            } else {
                self.delegate?.handleError(title: .error, error: ResultError(resultMessage: .unknownErrorMessage))
            }
            
        }
    }
    
    // This callback will be triggered just before the webview (hosting the queue page) will be shown.
    // Here you can change some relevant UI elements.
    func notifyYourTurn(_ queuePassedInfo: QueuePassedInfo!) {
        #if DEBUG
            print("notifyQueueViewWillOpen: ", queuePassedInfo ?? "Info")
        #endif
        self.queueitToken = queuePassedInfo?.queueitToken
        self.saveValueToDefaults(queueitToken: self.queueitToken)
        guard let model = self.model, let token = self.queueitToken else {
            self.delegate?.hideLoader()
            self.delegate?.handleError(title: .error, error: ResultError(resultMessage: .genericErrorMessage))
            return
        }
        getActualVaccineCard(model: model, token: token)
    }
    
    // This callback will be triggered when the queue used (event alias ID) is in the 'disabled' state.
    // Most likely the application should still function, but the queue's 'disabled' state can be changed at any time,
    // so session handling is important.
    // QueueITWKViewController will be shown here
    func notifyQueueViewWillOpen() {
        #if DEBUG
            print("notifyQueueViewWillOpen")
        #endif
        // Delay interval is 0 by default, so we can add a button on the main queue, going to add a delay to be safe
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if let webViewController = self.delegateOwner.presentedViewController as? QueueITWKViewController {
                // add close button
                self.addCloseButton(viewController: webViewController)
            }
        }
    }
    
    // This callback will be triggered when the mobile application can't reach Queue-it's servers.
    // Most likely because the mobile device has no internet connection.
    // Here you decide if the application should function or not now that is has no queue-it protection.
    func notifyQueueDisabled() {
        #if DEBUG
            print("notifyQueueDisabled")
        #endif
    }
    
    // This callback will be triggered after a user clicks a close link in the layout and the WebView closes.
    // The close link is "queueit://close". Whenever the user navigates to this link, the SDK intercepts the navigation
    // and closes the webview.
    func notifyQueueITUnavailable(_ errorMessage: String!) {
        #if DEBUG
            print("notifyQueueITUnavailable: ", errorMessage ?? "Error")
        #endif
        self.delegate?.hideLoader()
        self.delegate?.handleError(title: .queueItClosedTitle, error: ResultError(resultMessage: errorMessage ?? .queueItClosedMessage))
    }
    
    func notifyUserExited() {
        #if DEBUG
            print("notifyUserExited")
        #endif
    }
    
    func notifyViewClosed() {
        #if DEBUG
            print("notifyViewClosed")
        #endif
    }
    
}

// MARK: Alamofire requests
extension QueueItWorker {
    func createInitialVaccineCardRequest(model: GatewayVaccineCardRequest) {
        self.retryOnEmptyPDFCount = 0
        self.model = model
        self.delegate?.showLoader()
        let interceptor = NetworkRequestInterceptor()
        let headerParameters: HTTPHeaders = [
            Constants.GatewayVaccineCardRequestParameters.phn: model.phn,
            Constants.GatewayVaccineCardRequestParameters.dateOfBirth: model.dateOfBirth,
            Constants.GatewayVaccineCardRequestParameters.dateOfVaccine: model.dateOfVaccine
        ]
        
        AF.request(endpoint, method: .get, headers: headerParameters, interceptor: interceptor).response { response in
            // Check for queue it cookie here, if it's there, set the cookie and make actual request
            self.url = response.request?.url
            if let cookie = response.response?.allHeaderFields["Set-Cookie"] as? String, cookie.contains("QueueITAccepted") {
                let header = response.response?.allHeaderFields as? [String: String]
                self.saveValueToDefaults(cookieHeader: header)
                guard let model = self.model else {
                    self.delegate?.hideLoader()
                    self.delegate?.handleError(title: .error, error: ResultError(resultMessage: .genericErrorMessage))
                    return
                }
                // Resetting this here as I want to make sure retry uses the same logic
                self.queueitToken = nil
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
                switch response.result {
                case .success(_):
                    // Resetting this here as I want to make sure retry uses the same logic
                    self.queueitToken = nil
                    self.getActualVaccineCard(model: model, token: nil)
                case .failure(let error):
                    self.delegate?.hideLoader()
                    self.delegate?.handleError(title: .error, error: ResultError(resultMessage: error.errorDescription))
                }
            }
        }
    }
    
    @objc private func retryGetActualVaccineCardRequest() {
        guard let model = self.model else {
            self.delegate?.hideLoader()
            self.delegate?.handleError(title: .error, error: ResultError(resultMessage: .genericErrorMessage))
            return
        }
        self.getActualVaccineCard(model: model, token: self.queueitToken)
    }
    
    private func getActualVaccineCard(model: GatewayVaccineCardRequest, token: String?) {
        self.apiClient.getVaccineCard(model, token: token) { [weak self ] result in
            guard let `self` = self else {return}
            switch result {
            case .success(let vaccineCard):
                print(vaccineCard)
                // Note: Have to check for error here because error is being sent back on a 200 response
                if let resultMessage = vaccineCard.resultError?.resultMessage, (vaccineCard.resourcePayload?.qrCode?.data == nil && vaccineCard.resourcePayload?.federalVaccineProof?.data == nil) {
                    let adjustedMessage = resultMessage == .errorParsingPHNFromHG ? .errorParsingPHNMessage : resultMessage
                    self.delegate?.handleError(title: .error, error: ResultError(resultMessage: adjustedMessage))
                    self.delegate?.hideLoader()
                } else if vaccineCard.resourcePayload?.loaded == false && self.retryOnEmptyPDFCount < Constants.NetworkRetryAttempts.publicVaccineStatusRetryMaxForFedPass, let retryinMS = vaccineCard.resourcePayload?.retryin {
                    // Note: If we don't get QR data back when retrying (for BC Vaccine Card purposes), we
                    self.retryOnEmptyPDFCount += 1
                    let retryInSeconds = Double(retryinMS/1000)
                    self.perform(#selector(self.retryGetActualVaccineCardRequest), with: nil, afterDelay: retryInSeconds)
                } else {
                    let qrResult = vaccineCard.transformResponseIntoQRCode()
                    guard let code = qrResult.qrString else {
                        self.delegate?.handleError(title: .error, error: ResultError(resultMessage: qrResult.error))
                        self.delegate?.hideLoader()
                        return
                    }
                    BCVaccineValidator.shared.validate(code: code) { [weak self] result in
                        guard let `self` = self else { return }
                        guard let data = result.result else {
                            self.delegate?.handleError(title: .error, error: ResultError(resultMessage: .invalidQRCodeMessage))
                            self.delegate?.hideLoader()
                            return
                        }
                        DispatchQueue.main.async { [weak self] in
                            guard let `self` = self else {return}
                            self.delegate?.handleVaccineCard(scanResult: data, fedCode: vaccineCard.resourcePayload?.federalVaccineProof?.data)
                            self.delegate?.hideLoader()
                        }
                        
                    }
                }
            case .failure(let error):
                print(error)
                self.delegate?.hideLoader()
                self.delegate?.handleError(title: .error, error: error)
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

// MARK: Queue It Add close button hack - NOTE: This has not been tested yet
extension QueueItWorker {
    private func addCloseButton(viewController: QueueITWKViewController) {
        let closeImage = UIImage(named: "close-icon")
        let button = UIButton()
        button.setImage(closeImage, for: .normal)
        button.setTitle(nil, for: .normal)
        let statusBarHeight: CGFloat
        if #available(iOS 13.0, *) {
            statusBarHeight = AppDelegate.sharedInstance?.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 48.0
        } else {
            statusBarHeight = UIApplication.shared.statusBarFrame.height
        }
        let y: CGFloat = statusBarHeight + 10
        button.frame = CGRect(x: 12, y: y, width: 24, height: 24)
        button.autoresizingMask = [.flexibleRightMargin, .flexibleBottomMargin]
        button.addTarget(self, action: #selector(closeWebView), for: .touchUpInside)
        viewController.view.addSubview(button)
    }
    
    @objc func closeWebView() {
        if let webViewController = self.delegateOwner.presentedViewController as? QueueITWKViewController {
            webViewController.close(nil)
            self.delegate?.hideLoader()
        }
    }
}
