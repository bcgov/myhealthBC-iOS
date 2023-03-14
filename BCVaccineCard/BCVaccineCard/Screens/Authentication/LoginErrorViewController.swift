//
//  LoginErrorViewController.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2023-03-13.
//

import UIKit
import MessageUI

class LoginErrorViewController: BaseViewController {
    
    class func constructLoginErrorViewController() -> LoginErrorViewController {
        if let vc = Storyboard.authentication.instantiateViewController(withIdentifier: String(describing: LoginErrorViewController.self)) as? LoginErrorViewController {
            return vc
        }
        return LoginErrorViewController()
    }
    
    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionTextView: UITextView!
    @IBOutlet private weak var emailButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
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
        iconImageView.image = UIImage(named: "auth-error")
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
        
        let underlineAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.bcSansRegularWithSize(size: 17),
            .foregroundColor: AppColours.appBlue,
            .underlineStyle: NSUnderlineStyle.single.rawValue
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
    }
    
    private func styleButton() {
        emailButton.setImage(UIImage(named: "email-icon"), for: .normal)
        emailButton.setTitle("  Email us", for: .normal)
        emailButton.titleLabel?.font = UIFont.bcSansBoldWithSize(size: 17)
        emailButton.backgroundColor = AppColours.appBlue
        emailButton.tintColor = .white
        emailButton.layer.cornerRadius = 4
        emailButton.clipsToBounds = true
    }
    
    @IBAction private func emailUsButtonTapped(_ sender: UIButton) {
        composeEmail()
    }

}

extension LoginErrorViewController: MFMailComposeViewControllerDelegate {
    
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
