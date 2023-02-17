//
//  TermsOfServiceViewController.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2022-03-24.
//

import UIKit
import WebKit

class TermsOfServiceViewController: BaseViewController {
    
    class func constructTermsOfServiceViewController() -> TermsOfServiceViewController {
        if let vc = Storyboard.reusable.instantiateViewController(withIdentifier: String(describing: TermsOfServiceViewController.self)) as? TermsOfServiceViewController {
            vc.modalPresentationStyle = .overFullScreen
            return vc
        }
        return TermsOfServiceViewController()
    }
    
    @IBOutlet weak private var navHackCloseButton: UIButton!
    @IBOutlet weak private var navHackTitleLabel: UILabel!
    @IBOutlet weak private var navHackSeparatorView: UIView!
    @IBOutlet weak private var termsWebView: WKWebView!
    @IBOutlet weak private var buttonContainerView: UIView!
    @IBOutlet weak private var cancelButton: AppStyleButton!
    @IBOutlet weak private var agreeButton: AppStyleButton!
    
    private var tosPayload: TermsOfServiceResponse.ResourcePayload?

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            return UIStatusBarStyle.darkContent
        } else {
            return UIStatusBarStyle.default
        }
    }

    private func setup() {
        navSetup()
        uiSetup()
        fetchTermsOfService()
    }
    
    @IBAction private func navHackCloseButtonAction(_ sender: UIButton) {
        respondToTermsOfService(accepted: false)
//        self.dismiss(animated: true, completion: nil)
    }

}

// MARK: Nav setup
extension TermsOfServiceViewController {
    private func navSetup() {
        navHackCloseButton.setImage(UIImage(named: "close-icon-blue"), for: .normal)
        navHackCloseButton.tintColor = AppColours.appBlue
        navHackTitleLabel.font = UIFont.bcSansBoldWithSize(size: 17)
        navHackTitleLabel.textColor = AppColours.appBlue
        navHackTitleLabel.text = .termsOfService
        navHackSeparatorView.backgroundColor = AppColours.borderGray
    }
}

// MARK: Setup UI
extension TermsOfServiceViewController {
    private func uiSetup() {
        buttonContainerView.backgroundColor = .white
        buttonContainerView.layer.shadowColor = UIColor.black.cgColor
        buttonContainerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        buttonContainerView.layer.shadowRadius = 6.0
        buttonContainerView.layer.shadowOpacity = 0.2
        cancelButton.configure(withStyle: .white, buttonType: .cancel, delegateOwner: self, enabled: true)
        agreeButton.configure(withStyle: .blue, buttonType: .agree, delegateOwner: self, enabled: true)
    }
}

// MARK: Data fetch
extension TermsOfServiceViewController {
    private func fetchTermsOfService() {
        termsWebView.navigationDelegate = self
        TOSService(network: AFNetwork(), authManager: AuthManager(), configService: MobileConfigService(network: AFNetwork())).fetchTOS { tos in
            var displayString: String
            self.tosPayload = tos?.resourcePayload
            guard let terms = tos?.resourcePayload, let termsString = terms.content, terms.id != nil else {
                displayString = "We're sorry, there was an issue fetching terms of service."
                return
            }
            displayString = termsString
            self.termsWebView.loadHTMLString(displayString, baseURL: nil)
//            if let terms = tos, let termsString = terms.content, terms.id != nil {
//                displayString = termsString
//            } else {
//                displayString = "We're sorry, there was an issue fetching terms of service."
//            }
//            self.termsWebView.loadHTMLString(displayString, baseURL: nil)
//            self.view.endLoadingIndicator()
        }
    }
}

// MARK: WKWebView Delegate
extension TermsOfServiceViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        let js = "document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust='250%'"
        webView.evaluateJavaScript(js, completionHandler: nil)
    }
}

// MARK: Button actions
extension TermsOfServiceViewController: AppStyleButtonDelegate {
    func buttonTapped(type: AppStyleButton.ButtonType) {
        switch type {
        case .cancel: respondToTermsOfService(accepted: false)
        case .agree: respondToTermsOfService(accepted: true)
        default: break
        }
    }
    
}

// MARK: For terms of service request
extension TermsOfServiceViewController {
    private enum SignoutReason {
        case Error
        case DidntAgree
    }
    private func respondToTermsOfService(accepted: Bool) {
        
        guard let termsOfServiceId = tosPayload?.id else { return }
        guard accepted == true else {
            signout(error: nil, reason: .DidntAgree)
            return
        }
        TOSService(network: AFNetwork(), authManager: AuthManager(), configService: MobileConfigService(network: AFNetwork())).accept(termsOfServiceId: termsOfServiceId) { result in
            guard let result = result else {
                return
            }
            self.dismiss(animated: true)
        }
        
//        self.view.startLoadingIndicator()
//        self.authWorker?.respondToTermsOfService(authCredentials, accepted: accepted, termsOfServiceId: termsOfServiceId, completion: { accepted, error in
//            guard let accepted = accepted else {
//                self.signout(error: error, reason: .Error)
//                return
//            }
//
//            NotificationManager.respondToTermsOfService(accepted: accepted, error: nil, errorTitle: nil)
//            self.view.endLoadingIndicator()
//            self.dismiss(animated: true)
//
//        })
    }
    
//    private func resetRecordsTab() {
//        let recordFlowDetails = RecordsFlowDetails(currentStack: self.getCurrentStacks.recordsStack)
//        let passesFlowDetails = PassesFlowDetails(currentStack: self.getCurrentStacks.passesStack)
//        let currentTab = self.getCurrentTab
//        let scenario = AppUserActionScenarios.TermsOfServiceRejected(values: ActionScenarioValues(currentTab: currentTab, affectedTabs: [.records], recordFlowDetails: recordFlowDetails, passesFlowDetails: passesFlowDetails, loginSourceVC: nil, authenticationStatus: nil))
//        self.routerWorker?.routingAction(scenario: scenario, delayInSeconds: 0.0)
//    }
    
    private func signout(error: ResultError?, reason: SignoutReason) {
        let manager = AuthManager()
        manager.signout(in: self) { success in
            if !success {
                AuthManager().clearData()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.view.endLoadingIndicator()
//                self.dismiss(animated: true) {
//                    self.resetRecordsTab()
//                }
                self.dismiss(animated: true)
                switch reason {
                case .Error:
                    NotificationManager.respondToTermsOfService(accepted: nil, error: error?.resultMessage ?? "Unknown error occured with terms of service", errorTitle: .error)
                case .DidntAgree:
                    let error = "You must agree to the Health Gateway terms of service before using this app"
                    NotificationManager.respondToTermsOfService(accepted: nil, error: error, errorTitle: "Terms of service")
                }
            }
        }
    }
}
