//
//  CommunicationBannerTableViewCell.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2022-09-14.
//

import UIKit

protocol CommunicationBannerTableViewCellDelegate {
    func onExpand(banner: CommunicationBanner?)
    func onClose(banner: CommunicationBanner?)
    func onDismiss(banner: CommunicationBanner?)
    func onLearnMore(banner: CommunicationBanner?)
}

class CommunicationBannerTableViewCell: UITableViewCell {
    
    let maxMessageChar: Int = 120

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var expandButton: UIButton!
    @IBOutlet weak var learnMoreButton: UIButton!
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var buttonsStack: UIStackView!
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var messageStack: UIStackView!
    
    private var delegate: CommunicationBannerTableViewCellDelegate?
    private var data: CommunicationBanner?
    
    var isExpanded: Bool {
        return !buttonsStack.isHidden && !messageStack.isHidden
    }

    @IBAction func expandButtonTapped(_ sender: Any) {
        if isExpanded {
            close()
        } else {
            expand()
        }
    }
    
    @IBAction func learnMoreButtonTapped(_ sender: Any) {
        delegate?.onLearnMore(banner: data)
    }
    
    @IBAction func dismissButtonTapped(_ sender: Any) {
        delegate?.onDismiss(banner: data)
    }
    
    
    private func expand() {
        messageStack.isHidden = false
        buttonsStack.isHidden = false
        expandButton.setImage(UIImage(named: "expand_arrow_down"), for: .normal)
        delegate?.onExpand(banner: data)
    }
    
    private func close() {
        messageStack.isHidden = true
        buttonsStack.isHidden = true
        expandButton.setImage(UIImage(named: "expand_arrow_up"), for: .normal)
        delegate?.onClose(banner: data)
    }
    
    func configure(data: CommunicationBanner?, delegate: CommunicationBannerTableViewCellDelegate) {
        guard let data = data else {
            return
        }
        self.data = data
        self.delegate = delegate
        titleLabel.text = data.subject
        
        var textAttributed = data.text.htmlToAttributedString
        
        if let text = textAttributed, text.string.count > maxMessageChar, let mutStr = text.mutableCopy() as? NSMutableAttributedString {
            learnMoreButton.isHidden = false
            let textString = text.string
            let length = textString.count
            let reminder = length - maxMessageChar
            let hiddenChars = String(textString.suffix(reminder))
            let range = (mutStr.string as NSString).range(of: hiddenChars)
            mutStr.deleteCharacters(in: range)
            let dots = NSAttributedString(string: "...", attributes: nil)
            mutStr.append(dots)
            textAttributed = mutStr
        } else {
            learnMoreButton.isHidden = true
        }
        textView.attributedText = textAttributed
        style()
    }
    
    private func style() {
        container.backgroundColor = UIColor(red: 0.851, green: 0.918, blue: 0.969, alpha: 1)
        container.layer.cornerRadius = 10
        
        titleLabel.textColor = AppColours.blueLightText
        
        titleLabel.font = UIFont.bcSansBoldWithSize(size: 15)
        
        iconImageView.image = UIImage(named: "communication-icon")
        textView.font = UIFont.bcSansRegularWithSize(size: 13)
        textView.backgroundColor = .clear
        
        textView.isScrollEnabled = false
        textView.sizeToFit()
        
        container.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.07).cgColor
        container.layer.shadowOpacity = 1
        container.layer.shadowOffset = CGSize(width: -1, height: 5)
        container.layer.shadowRadius = 3
        
        learnMoreButton.setTitle("", for: .normal)
        dismissButton.setTitle("", for: .normal)
        learnMoreButton.setImage(UIImage(named: "learn-more"), for: .normal)
        dismissButton.setImage(UIImage(named: "dismiss-communication"), for: .normal)
        layoutIfNeeded()
    }
}

extension String {
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return nil }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return nil
        }
    }
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
}
