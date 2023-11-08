//
//  CommunicationMessageUIViewController.swift
//  HealthGatewayTest
//
//  Created by Amir Shayegh on 2022-09-15.
//

import Foundation
import UIKit


class CommunicationMessageUIViewController: UIViewController {
    let padding: CGFloat = 16
    
    var banner: CommunicationBanner? = nil

    weak var textView: UITextView? = nil
    weak var titleLabel: UILabel? = nil
    weak var timeStampLabel: UILabel? = nil
    weak var stackView: UIStackView? = nil
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = .white
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        createSubviews()
        style()
    }
    
    func createSubviews() {
        let stackView = UIStackView()
        view.addSubview(stackView)
        
        let titleLabel = UILabel()
        let timeStampLabel = UILabel()
        let textView = UITextView()
        
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(timeStampLabel)
        
        /*
         Textview did not display when added in the stackview,
         so instead its added under using contraints
         stackView.addArrangedSubview(textView)
         */
        view.addSubview(textView)
        
        self.stackView = stackView
        self.titleLabel = titleLabel
        self.timeStampLabel = timeStampLabel
        self.textView = textView
    }
    
    func style() {
        styleStack(stackView: stackView)
        styleTitle(label: titleLabel)
        styleTimeStamp(label: timeStampLabel)
        styleMessage(textView: textView)
        
        title = .newUpdateTitle.capitalized
        navigationController?.navigationBar.prefersLargeTitles = false
        view.layoutIfNeeded()
    }
    
    func styleStack(stackView: UIStackView?) {
        guard let stackView = stackView else {
            return
        }
        stackView.alignment = .fill
        stackView.distribution = .fillProportionally
        stackView.spacing = padding / 2
        stackView.axis = .vertical
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding).isActive = true
        stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0 - padding).isActive = true
        stackView.topAnchor.constraint(equalTo: view.safeTopAnchor, constant: padding).isActive = true
    }
    
    func styleTitle(label: UILabel?) {
        guard let banner = banner, let label = label else {
            return
        }
        
        label.text = banner.subject
        label.textColor = AppColours.appBlue
        let font = UIFont.bcSansBoldWithSize(size: 17)
        label.font = font
        label.numberOfLines = 0
        
    }
    
    func styleTimeStamp(label: UILabel?) {
        guard let banner = banner, let label = label else {
            return
        }
        let timestamp = banner.effectiveDateTime?.getGatewayDate()?.shortString
        label.text = timestamp
        label.textColor = AppColours.textGray
        let font = UIFont.bcSansRegularWithSize(size: 13)
        label.font = font
    }
    
    func styleMessage(textView: UITextView?) {
        guard let banner = banner, let textView = textView, let stackView = stackView else {
            return
        }
        textView.attributedText = banner.text?.injectHTMLFont(size: 17).htmlToAttributedString
        textView.backgroundColor = .clear
        textView.isEditable = false
        textView.delegate = self
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding).isActive = true
        textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0 - padding).isActive = true
        textView.bottomAnchor.constraint(equalTo: view.safeBottomAnchor, constant: 0 - padding).isActive = true
        textView.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: padding).isActive = true
        view.needsUpdateConstraints()
    }
  
}

extension CommunicationMessageUIViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        if UIApplication.shared.canOpenURL(URL) {
//            UIApplication.shared.open(URL)
            AppDelegate.sharedInstance?.showExternalURL(url: URL.absoluteString)
        }
        return false
    }
}

// MARK: For iPad
extension CommunicationMessageUIViewController {
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        guard Constants.deviceType == .iPad else { return }
        NotificationCenter.default.post(name: .deviceDidRotate, object: nil)
        // TODO: Make iPad adjustments here if necessary
    }
}
