//
//  PrivacyPolicyViewController.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2024-01-10.
//

import UIKit
import WebKit

class PrivacyPolicyViewController: BaseViewController {
    
    class func construct(with urlString: String) -> PrivacyPolicyViewController {
        let vc = PrivacyPolicyViewController()
        vc.urlString = urlString
        return vc
    }
    
    private var urlString: String!
    private var webView: WKWebView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup() {
        webView = WKWebView()
        guard let webView = webView else { return }
        view.addSubview(webView)
        webView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        webView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        webView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        webView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        
        webView.navigationDelegate = self
        if let url = URL(string: urlString) {
            webView.load(URLRequest(url: url))
        }
    }
}

// MARK: Web View Functions
extension PrivacyPolicyViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("DID FINISH")
    }
}

// MARK: For iPad
extension PrivacyPolicyViewController {
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        guard Constants.deviceType == .iPad else { return }
        NotificationCenter.default.post(name: .deviceDidRotate, object: nil)
        // TODO: Make iPad adjustments here if necessary
    }
}
