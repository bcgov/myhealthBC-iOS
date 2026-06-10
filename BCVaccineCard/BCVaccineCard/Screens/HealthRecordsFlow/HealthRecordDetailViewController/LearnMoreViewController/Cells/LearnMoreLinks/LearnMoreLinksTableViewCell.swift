//
//  LearnMoreLinksTableViewCell.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2024-03-06.
//

import UIKit

class LearnMoreLinksTableViewCell: UITableViewCell {
    
    @IBOutlet weak private var linkTextView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
//        setup()
    }
    
    func config(link: String, urlString: String) {
        let wholeString = " \u{2022}  \(link)"
        let linkString = "\(link)"
        linkTextView.attributedText = attributedText(withString: wholeString, linkString: linkString, link: urlString)
        linkTextView.linkTextAttributes = [
                NSAttributedString.Key.underlineColor: AppColours.appBlue,
                NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue,
                NSAttributedString.Key.foregroundColor: AppColours.appBlue,
                NSAttributedString.Key.font: UIFont.bcSansBoldWithSize(size: 17)
            ]
        linkTextView.delegate = self
    }
    
    private func attributedText(withString string: String, linkString: String, link: String) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: string,
                                                         attributes: [NSAttributedString.Key.font: UIFont.bcSansBoldWithSize(size: 17), NSAttributedString.Key.foregroundColor: AppColours.appBlue])
        if let url = URL(string: link) {
            let linkAttribute: [NSAttributedString.Key: Any] = [NSAttributedString.Key.link: url]
            
            let range = (string as NSString).range(of: linkString)
            attributedString.addAttributes(linkAttribute, range: range)
        }
        
        
        
        return attributedString
    }
    
}

extension LearnMoreLinksTableViewCell: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        AppDelegate.sharedInstance?.showExternalURL(url: URL.absoluteString)
        return false
    }
}
