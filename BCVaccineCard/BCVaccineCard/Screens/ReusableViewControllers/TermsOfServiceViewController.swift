//
//  TermsOfServiceViewController.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2022-03-24.
//

import UIKit
import WebKit

class TermsOfServiceViewController: BaseViewController {
    
    class func constructTermsOfServiceViewController(authWorker: AuthenticatedHealthRecordsAPIWorker?, authCredentials: AuthenticationRequestObject) -> TermsOfServiceViewController {
        if let vc = Storyboard.reusable.instantiateViewController(withIdentifier: String(describing: TermsOfServiceViewController.self)) as? TermsOfServiceViewController {
            vc.authWorker = authWorker
            vc.authCredentials = authCredentials
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
    
    private var authWorker: AuthenticatedHealthRecordsAPIWorker?
    private var authCredentials: AuthenticationRequestObject?

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
        AuthManager().clearData()
        self.dismiss(animated: true, completion: nil)
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
        self.view.startLoadingIndicator()
        authWorker?.fetchTermsOfService(completion: { termsString, error in
            var displayString: String
            if let termsString = termsString {
                displayString = termsString
            } else if let error = error?.resultMessage {
                displayString = error
            } else {
                displayString = "Unknown error"
            }
            self.termsWebView.loadHTMLString(displayString, baseURL: nil)
            self.view.endLoadingIndicator()
        })
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
    private func respondToTermsOfService(accepted: Bool) {
        guard let authCredentials = self.authCredentials else { return }
        guard accepted == true else {
            AuthManager().clearData()
            let error = "Please note that you cannot authenticate with BCSC and fetch their records until they accept the terms of service"
            NotificationManager.respondToTermsOfService(accepted: nil, error: error, errorTitle: "Notice")
            self.dismiss(animated: true)
            return
        }
        self.view.startLoadingIndicator()
        self.authWorker?.respondToTermsOfService(authCredentials, accepted: accepted, completion: { accepted, error in
            guard let accepted = accepted else {
                AuthManager().clearData()
                NotificationManager.respondToTermsOfService(accepted: nil, error: error?.resultMessage ?? "Unknown error occured with terms of service", errorTitle: .error)
                self.view.endLoadingIndicator()
                self.dismiss(animated: true)
                return
            }
//            if !accepted {
//                AuthManager().clearData()
//            }
            NotificationManager.respondToTermsOfService(accepted: accepted, error: nil, errorTitle: nil)
            self.view.endLoadingIndicator()
            self.dismiss(animated: true)
        })
    }
}