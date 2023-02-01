//
//  UpdateAddressViewController.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2023-01-30.
//

import UIKit
import WebKit

protocol UpdateAddressViewControllerDelegate: AnyObject {
    func webViewClosed()
}

class UpdateAddressViewController: UIViewController {
    
    class func constructUpdateAddressViewController(delegateOwner: UIViewController, urlString: String) -> UpdateAddressViewController {
        if let vc = Storyboard.main.instantiateViewController(withIdentifier: String(describing: UpdateAddressViewController.self)) as? UpdateAddressViewController {
            vc.delegate = delegateOwner as? UpdateAddressViewControllerDelegate
            vc.urlString = urlString
            vc.modalPresentationStyle = .overFullScreen
            return vc
        }
        return UpdateAddressViewController()
    }
    
    @IBOutlet weak private var webView: WKWebView!
    
    private weak var delegate: UpdateAddressViewControllerDelegate?
    private var urlString: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup() {
        webView.navigationDelegate = self
        if let url = URL(string: urlString) {
            webView.load(URLRequest(url: url))
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.delegate?.webViewClosed()
    }

}

// MARK: Web View Functions
extension UpdateAddressViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("DID FINISH")
    }
}
