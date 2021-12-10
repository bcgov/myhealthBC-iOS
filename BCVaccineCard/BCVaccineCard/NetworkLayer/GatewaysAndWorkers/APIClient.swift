//
//  HealthGatewayBCWorker.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-10-10.
//

import Foundation
import QueueITLibrary
import Alamofire

class APIClient {
    
    private var engine: QueueITEngine?
    private var delegateOwner: UIViewController
        
    init(delegateOwner: UIViewController) {
        self.delegateOwner = delegateOwner
    }
    
    private var endpoints: EndpointsAccessor {
       return UrlAccessor()
    }
    
    private var remote: RemoteAccessor {
        return NetworkAccessor()
    }
    
    func getVaccineCard(_ model: GatewayVaccineCardRequest, token: String?, executingVC: UIViewController, completion: @escaping NetworkRequestCompletion<GatewayVaccineCardResponse>) {
        let interceptor = NetworkRequestInterceptor()
        let url = configureURL(token: token, endpoint: self.endpoints.getVaccineCard)
        
        let headerParameters: Headers = [
            Constants.GatewayVaccineCardRequestParameters.phn: model.phn,
            Constants.GatewayVaccineCardRequestParameters.dateOfBirth: model.dateOfBirth,
            Constants.GatewayVaccineCardRequestParameters.dateOfVaccine: model.dateOfVaccine
        ]
        
        guard let unwrappedURL = url else { return }
        self.remote.request(withURL: unwrappedURL, method: .get, headers: headerParameters, interceptor: interceptor, checkQueueIt: true, executingVC: executingVC, andCompletion: completion)
    }
}

// MARK: QUEUEIT Logic here
extension APIClient {
    
    func configureURL(token: String?, endpoint: URL) -> URL? {
        var url: URL?
        if let token = token {
            let queryItems = [URLQueryItem(name: Constants.QueueItStrings.queueittoken, value: token)]
            var urlComps = URLComponents(string: endpoint.absoluteString)
            urlComps?.queryItems = queryItems
            url = urlComps?.url
        } else {
            url = endpoint
        }
        return url
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////////
// NOTE: The following will go in its own file, keeping things separate for now so that we don't have any merge conflicts
// TODO: Put these next two structs elsewhere
struct QueueItRunStatus: Codable {
    var token: String?
    let succeeded: Bool
}

struct NetworkRetryStatus: Codable {
    var token: String?
    var retry: Bool
}

protocol QueueItEngineCustomDelegate: AnyObject {
    func adjustLoader(hidden: Bool)
}

class QueueItEngine: NSObject {
    
    private var engine: QueueITEngine?
    private var delegateOwner: UIViewController
    private var customDelegate: QueueItEngineCustomDelegate?
    var runCompletionHandler: ((QueueItRunStatus, DisplayableResultError?) -> Void)?
    
    init(delegateOwner: UIViewController, customDelegateOwner: UIViewController) {
        self.delegateOwner = delegateOwner
        self.customDelegate = customDelegateOwner as? QueueItEngineCustomDelegate
    }
    
    func setupQueueIt(customerID: String, eventAlias: String, url: URL?) {
        self.engine = QueueITEngine.init(host: self.delegateOwner, customerId: customerID, eventOrAliasId: eventAlias, layoutName: nil, language: nil)
        self.engine?.queuePassedDelegate = self // Invoked once the user is passed the queue
        self.engine?.queueViewWillOpenDelegate = self // Invoked to notify that Queue-It UIWebView or WKWebview will open
        self.engine?.queueDisabledDelegate = self // Invoked to notify that queue is disabled
        self.engine?.queueITUnavailableDelegate = self // Invoked in case QueueIT is unavailable (500 errors)
        self.engine?.queueUserExitedDelegate = self // Invoked when user chooses to leave the queue
        self.runQueueIt(url: url)
    }
    
    private func runQueueIt(url: URL?) {
        do {
            try engine?.run()
        }
        catch let err {
            // Handle reasons for not being able to start the queue here.
            let errorCode = (err as NSError).code
            if errorCode == NetworkUnavailable.rawValue {
                runCompletionHandler?(QueueItRunStatus(succeeded: false), DisplayableResultError(title: .networkUnavailableTitle, resultError: ResultError(resultMessage: .networkUnavailableMessage)))
            } else if errorCode == RequestAlreadyInProgress.rawValue, let url = url {
                // Need to fetch locally stored Cookie and token
                let cached = QueueItLocal.fetchValueFromDefaults()
                guard let cookieHeadString = cached?.cookieHeader else {
                    runCompletionHandler?(QueueItRunStatus(succeeded: false), DisplayableResultError(title: .inProgressErrorTitle, resultError: ResultError(resultMessage: .inProgressErrorMessage)))
                    return
                }
                let cookies = HTTPCookie.cookies(withResponseHeaderFields: cookieHeadString, for: url)
                AF.session.configuration.httpCookieStorage?.setCookies(cookies, for: url, mainDocumentURL: nil)
                runCompletionHandler?(QueueItRunStatus(token: cached?.queueitToken, succeeded: true), nil)
            } else {
                runCompletionHandler?(QueueItRunStatus(succeeded: false), DisplayableResultError(title: .error, resultError: ResultError(resultMessage: .unknownErrorMessage)))
            }
            
        }
    }

    
}

extension QueueItEngine: QueuePassedDelegate, QueueViewWillOpenDelegate, QueueDisabledDelegate, QueueITUnavailableDelegate, QueueUserExitedDelegate, QueueViewClosedDelegate {
    // This callback will be triggered just before the webview (hosting the queue page) will be shown.
    // Here you can change some relevant UI elements.
    func notifyYourTurn(_ queuePassedInfo: QueuePassedInfo!) {
        #if DEBUG
            print("notifyQueueViewWillOpen: ", queuePassedInfo ?? "Info")
        #endif
        let token = queuePassedInfo?.queueitToken
        QueueItLocal.saveValueToDefaults(queueitToken: token)
        runCompletionHandler?(QueueItRunStatus(token: token, succeeded: true), nil)
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
        runCompletionHandler?(QueueItRunStatus(succeeded: false), DisplayableResultError(title: .queueItClosedTitle, resultError: ResultError(resultMessage: errorMessage ?? .queueItClosedMessage)))
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

// MARK: Queue It Add close button hack - NOTE: This has not been tested yet
extension QueueItEngine {
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
            self.customDelegate?.adjustLoader(hidden: true)
        }
    }
}
