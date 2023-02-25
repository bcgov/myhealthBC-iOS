//
//  CommunicationPreferencesTableViewCell.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2023-02-24.
//

import UIKit

class CommunicationPreferencesTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionTextView: UITextView!
    @IBOutlet private weak var emailAddressTitleLabel: UILabel!
    @IBOutlet private weak var emailAddressDetailsLabel: UILabel!
    @IBOutlet private weak var verifiedStatusImageView: UIImageView!
    @IBOutlet private weak var imageViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet private weak var phoneNumberTitleLabel: UILabel!
    @IBOutlet private weak var phoneNumberDetailsLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }

    private func setup() {
        staticLabelSetup()
        textViewSetup()
        styleLabel(label: emailAddressDetailsLabel, data: nil, emptyDataText: "No email address provided")
        displayVerifiedImage(emailAddress: nil, verified: false)
        styleLabel(label: phoneNumberDetailsLabel, data: nil, emptyDataText: "No phone number provided")
    }
    
    private func staticLabelSetup() {
        titleLabel.text = "Communication Preferences"
        titleLabel.font = UIFont.bcSansBoldWithSize(size: 17)
        titleLabel.textColor = AppColours.textBlack
        emailAddressTitleLabel.text = "Email address"
        emailAddressTitleLabel.font = UIFont.bcSansRegularWithSize(size: 14)
        emailAddressTitleLabel.textColor = AppColours.textBlack
        phoneNumberTitleLabel.text = "Phone number"
        phoneNumberTitleLabel.font = UIFont.bcSansRegularWithSize(size: 14)
        phoneNumberTitleLabel.textColor = AppColours.textBlack
    }
    
    private func textViewSetup() {
        let attrString = NSMutableAttributedString(string: "Keep you updated on health record updates (vaccine availability, lab results and more).\n\nTo make changes to email address and phone number, please go to www.healthgateway.gov.bc.ca")
        let urlString = "www.healthgateway.gov.bc.ca"
        attrString.addAttribute(.font, value: UIFont.bcSansRegularWithSize(size: 13), range: NSMakeRange(0, attrString.length))
        attrString.addAttribute(.foregroundColor, value: AppColours.textGray, range: NSMakeRange(0, attrString.length))
        if let url = URL(string: urlString) {
            attrString.setAttributes([.link: url], range: NSMakeRange(attrString.length - urlString.count, urlString.count))
            descriptionTextView.attributedText = attrString
            descriptionTextView.isUserInteractionEnabled = true
            descriptionTextView.isEditable = false
            descriptionTextView.linkTextAttributes = [
                .foregroundColor: UIColor(hexString: "#1A5A96"),
                .underlineStyle: NSUnderlineStyle.single.rawValue
            ]
        } else {
            descriptionTextView.attributedText = attrString
        }
        descriptionTextView.textContainerInset = .zero
        descriptionTextView.textContainer.lineFragmentPadding = 0.0
        
    }
    // NOTE: Remember to cache these values for this session, and to check cache for values before hitting endpoint
    func configure(patient: Patient) {
        styleLabel(label: emailAddressDetailsLabel, data: patient.email, emptyDataText: "No email address provided")
        displayVerifiedImage(emailAddress: patient.email, verified: patient.emailVerified)
        styleLabel(label: phoneNumberDetailsLabel, data: patient.phone, emptyDataText: "No phone number provided")
    }
    
    private func styleLabel(label: UILabel, data: String?, emptyDataText: String) {
        label.text = data != nil ? data : emptyDataText
        label.font = data != nil ? UIFont.bcSansRegularWithSize(size: 17) : UIFont.bcSansRegularWithSize(size: 13)
        label.textColor = data != nil ? AppColours.textBlack : AppColours.textGray
    }
    
    private func displayVerifiedImage(emailAddress: String?, verified: Bool) {
        guard let _ = emailAddress else {
            verifiedStatusImageView.isHidden = true
            return
        }
        verifiedStatusImageView.isHidden = false
        verifiedStatusImageView.image = verified ? UIImage(named: "verified") : UIImage(named: "unverified")
        imageViewWidthConstraint.constant = verified ? 58 : 78
        self.layoutIfNeeded()
    }
    
}
