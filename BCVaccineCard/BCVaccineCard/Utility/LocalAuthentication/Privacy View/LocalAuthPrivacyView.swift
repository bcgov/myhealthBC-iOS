//
//  LocalAuthPrivacyView.swift
//  BCVaccineCard
//
//  Created by Amir on 2022-02-01.
//

import UIKit

class LocalAuthPrivacyView: UIView, UITextViewDelegate, Theme {

    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    
    @IBAction func backButtonAction(_ sender: Any) {
        self.removeFromSuperview()
    }
    
    public func show(over parentView: UIView) {
        self.frame = parentView.bounds
        let transition = CATransition()
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromLeft
        parentView.layer.add(transition, forKey: nil)
        parentView.addSubview(self)
        self.addEqualSizeContraints(to: parentView)
    }
    
    private func style() {
        textSetup()
        style(label: titleLabel, style: .Bold, size: 17, colour: .Blue)
        textView.font = UIFont.bcSansRegularWithSize(size: 17)
        textView.textColor = AppColours.textBlack
        titleLabel.text = .privacy
        self.layoutIfNeeded()
    }
    
    private func textSetup() {
        let attributedText = NSMutableAttributedString(string: .localAuthPrivacyText)
        _ = attributedText.setAsLink(textToFind: "here", linkURL: "https://www2.gov.bc.ca/gov/content/governments/government-id/bcservicescardapp/terms-of-use")
        textView.attributedText = attributedText
        textView.isEditable = false
        textView.isUserInteractionEnabled = true
        textView.delegate = self
        textView.isEditable = false
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        UIApplication.shared.open(URL)
        return false
    }

}
