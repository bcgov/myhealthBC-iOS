//
//  TermsOfServiceViewController.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2022-03-24.
//

import UIKit
import WebKit

class TermsOfServiceViewController: BaseViewController {
    
    class func constructTermsOfServiceViewController(authWorker: AuthenticatedHealthRecordsAPIWorker?) -> TermsOfServiceViewController {
        if let vc = Storyboard.reusable.instantiateViewController(withIdentifier: String(describing: TermsOfServiceViewController.self)) as? TermsOfServiceViewController {
            vc.authWorker = authWorker
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
        case .cancel:
            // Note: Either this, or the user will create the TOS and set to false
            self.dismiss(animated: true, completion: nil)
            
//            // ORRRR...
//            guard let hdid = AuthManager().hdid, let token = AuthManager().authToken else { return }
//            let authCreds = AuthenticationRequestObject(authToken: token, hdid: hdid)
//            //TODO: Create request here, setting value to false
        case .agree:
            // TODO: Network request here, then dismiss once completed
            print("TODO")
        default: break
        }
    }
    
}
