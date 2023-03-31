//
//  AuthenticationFailedViewController.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2023-03-31.
//

import UIKit
import MessageUI

class AuthenticationFailedViewController: BaseViewController {
    
    class func construct() -> AuthenticationFailedViewController {
        if let vc = Storyboard.authentication.instantiateViewController(withIdentifier: String(describing: AuthenticationFailedViewController.self)) as? AuthenticationFailedViewController {
            return vc
        }
        return AuthenticationFailedViewController()
    }
    
    @IBOutlet weak var navTitleLabel: UILabel!
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func sendMailAction(_ sender: Any) {
        composeEmail()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navSetup()
        setup()
    }
    
    private func navSetup() {
        self.navDelegate?.setNavigationBarWith(title: "Problem with log in",
                                               leftNavButton: nil,
                                               rightNavButton: nil,
                                               navStyle: .small,
                                               navTitleSmallAlignment: .Center,
                                               targetVC: self,
                                               backButtonHintString: nil)
    }
    
    private func setup() {
        guard titleLabel != nil else {return}
        navTitleLabel.text = "Problem with log in"
        navTitleLabel.font = UIFont.bcSansBoldWithSize(size: 17)
        navTitleLabel.textColor = AppColours.appBlue
        titleLabel.text = "Problem with log in"
        titleLabel.font = UIFont.bcSansBoldWithSize(size: 20)
        titleLabel.textColor = AppColours.appBlue
        attributedTextSetup()
        styleButton()
    }
    
    private func attributedTextSetup() {
        descriptionTextView.isUserInteractionEnabled = true
        descriptionTextView.isEditable = false
        descriptionTextView.isSelectable = true
        descriptionTextView.backgroundColor = .clear
        let attributedText = NSMutableAttributedString(string: "")
        // All text size 13
        
        // Normal text
        // You can add or update immunizations by visiting
        let normalAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.bcSansRegularWithSize(size: 17),
            .foregroundColor: AppColours.textBlack
        ]
        let normal = NSAttributedString(string: "We are unable to retrive your health record at this moment because of problem with BC Service Card log in, please contact Health Gateway team: ", attributes: normalAttributes)
        attributedText.append(normal)
        // underlined text
        let url = URL(string: "mailto:healthgateway@gov.bc.ca")
        let underlineAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.bcSansRegularWithSize(size: 17),
            .foregroundColor: AppColours.appBlue,
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .link: url
        ]
        let email = NSAttributedString(string: "healthgateway@gov.bc.ca", attributes: underlineAttributes)
        attributedText.append(email)
        // italic text
        // You can always access this information by going to the Resources page.
        let remainingNormalAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.bcSansRegularWithSize(size: 17),
            .foregroundColor: AppColours.textBlack
        ]
        let remainingNormal = NSAttributedString(string: " for more information", attributes: remainingNormalAttributes)
        attributedText.append(remainingNormal)
        
        descriptionTextView.attributedText = attributedText
        descriptionTextView.textAlignment = .center
        descriptionTextView.delegate = self
        descriptionTextView.isScrollEnabled = false
        view.layoutIfNeeded()
    }
    
    private func styleButton() {
        button.setImage(UIImage(named: "mail"), for: .normal)
        button.setTitle("  Email us", for: .normal)
        button.titleLabel?.font = UIFont.bcSansBoldWithSize(size: 17)
        button.backgroundColor = AppColours.appBlue
        button.tintColor = .white
        button.layer.cornerRadius = 4
        button.clipsToBounds = true
    }
}

extension AuthenticationFailedViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        if ((URL.scheme?.contains("mailto")) != nil) {
            composeEmail()
        }
        return false
    }
}

extension AuthenticationFailedViewController: MFMailComposeViewControllerDelegate {

    private func composeEmail() {
        let recipientEmail = "healthgateway@gov.bc.ca"
        let subject = "Problem with log in"
        let body = "Hi there, I am having issues with my BC Service Card log in"

        // Show default mail composer
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients([recipientEmail])
            mail.setSubject(subject)
            mail.setMessageBody(body, isHTML: false)

            present(mail, animated: true)

            // Show third party email composer if default Mail app is not present
        } else if let emailUrl = createEmailUrl(to: recipientEmail, subject: subject, body: body) {
            UIApplication.shared.open(emailUrl)
        }
    }

    private func createEmailUrl(to: String, subject: String, body: String) -> URL? {
        let subjectEncoded = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let bodyEncoded = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!

        let gmailUrl = URL(string: "googlegmail://co?to=\(to)&subject=\(subjectEncoded)&body=\(bodyEncoded)")
        let outlookUrl = URL(string: "ms-outlook://compose?to=\(to)&subject=\(subjectEncoded)&body=\(bodyEncoded)")
        let yahooMail = URL(string: "ymail://mail/compose?to=\(to)&subject=\(subjectEncoded)&body=\(bodyEncoded)")
        let sparkUrl = URL(string: "readdle-spark://compose?recipient=\(to)&subject=\(subjectEncoded)&body=\(bodyEncoded)")
        let defaultUrl = URL(string: "mailto:\(to)?subject=\(subjectEncoded)&body=\(bodyEncoded)")

        if let gmailUrl = gmailUrl, UIApplication.shared.canOpenURL(gmailUrl) {
            return gmailUrl
        } else if let outlookUrl = outlookUrl, UIApplication.shared.canOpenURL(outlookUrl) {
            return outlookUrl
        } else if let yahooMail = yahooMail, UIApplication.shared.canOpenURL(yahooMail) {
            return yahooMail
        } else if let sparkUrl = sparkUrl, UIApplication.shared.canOpenURL(sparkUrl) {
            return sparkUrl
        }

        return defaultUrl
    }

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}
