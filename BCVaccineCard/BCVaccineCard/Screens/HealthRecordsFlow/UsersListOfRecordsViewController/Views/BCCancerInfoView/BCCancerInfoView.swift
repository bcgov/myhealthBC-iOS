//
//  BCCancerInfoView.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2024-02-06.
//

import UIKit

class BCCancerInfoView: UIView {
    
    @IBOutlet weak private var contentView: UIView!
    @IBOutlet weak private var containerView: UIView!
    @IBOutlet weak private var infoTextView: UITextView!
    @IBOutlet weak private var infoIconImageView: UIImageView!
            
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed(BCCancerInfoView.getName, owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        setup()
    }
    
    private func setup() {
        containerView.backgroundColor = AppColours.bannerBlue
        containerView.layer.cornerRadius = 4
        containerView.clipsToBounds = true
        
        infoTextView.delegate = self
        infoTextView.isEditable = false
        infoTextView.isScrollEnabled = false
        infoTextView.backgroundColor = AppColours.bannerBlue
        let attributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.foregroundColor: AppColours.appBlue,
            NSAttributedString.Key.font: UIFont.bcSansRegularWithSize(size: 15)
        ]
        let attrStr = NSMutableAttributedString(string: "Only BC Cancer cervix screening letters are available here. Your Health Gateway timeline may include these and other screening test results in lab or imaging reports. Learn more", attributes: attributes)
        if let range = attrStr.range(textToFind: "Learn more"), let url = URL(string: "http://www.bccancer.bc.ca/screening") {
            let attr: [NSAttributedString.Key: Any] = [
                NSAttributedString.Key.link: url
            ]
            attrStr.setAttributes(attr, range: range)
            
            infoTextView.linkTextAttributes = [
                NSAttributedString.Key.underlineColor: AppColours.appBlue,
                NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue,
                NSAttributedString.Key.foregroundColor: AppColours.appBlue,
                NSAttributedString.Key.font: UIFont.bcSansRegularWithSize(size: 15)
            ]
        }
        
        infoTextView.attributedText = attrStr
        
        infoIconImageView.image = UIImage(named: "more-info")
    }
    
    
}

extension BCCancerInfoView: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        AppDelegate.sharedInstance?.showExternalURL(url: URL.absoluteString)
        return false
    }
}
