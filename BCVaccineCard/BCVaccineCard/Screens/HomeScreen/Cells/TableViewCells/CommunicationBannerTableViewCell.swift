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
    func shouldUpdateUI()
}

class CommunicationBannerTableViewCell: UITableViewCell {
    
    let maxMessageChar: Int = 120
    
    @IBOutlet weak var messageHeight: NSLayoutConstraint!
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
        expandButton.setImage(UIImage(named: "expand_arrow_up"), for: .normal)
        delegate?.onExpand(banner: data)
        layoutIfNeeded()
    }
    
    private func close() {
        messageStack.isHidden = true
        buttonsStack.isHidden = true
        expandButton.setImage(UIImage(named: "expand_arrow_down"), for: .normal)
        delegate?.onClose(banner: data)
        layoutIfNeeded()
    }
    
    func configure(data: CommunicationBanner?, delegate: CommunicationBannerTableViewCellDelegate) {
        guard let data = data else {
            return
        }
        expandButton.setImage(UIImage(named: "expand_arrow_up"), for: .normal)
        self.data = data
        self.delegate = delegate
        titleLabel.text = data.subject
        
        var textAttributed = data.text?.injectHTMLFont(size: 14).htmlToAttributedString?.trimmedAttributedString()
        
        if let text = textAttributed, let shortText = text.cutOff(at: maxMessageChar) {
            learnMoreButton.isHidden = false
            textAttributed = shortText
        } else {
            learnMoreButton.isHidden = true
        }
        
        textView.attributedText = textAttributed
        textView.delegate = self
        style()
    }
    
    private func style() {
        layoutIfNeeded()
        container.backgroundColor = UIColor(red: 0.851, green: 0.918, blue: 0.969, alpha: 1)
        container.layer.cornerRadius = 10
        
        titleLabel.textColor = AppColours.blueLightText
        titleLabel.font = UIFont.bcSansBoldWithSize(size: 15)
        
        iconImageView.image = UIImage(named: "communication-icon")
        textView.backgroundColor = .clear
        
        textView.isScrollEnabled = false
        textView.sizeToFit()
        textView.isEditable = false
        
        container.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.07).cgColor
        container.layer.shadowOpacity = 1
        container.layer.shadowOffset = CGSize(width: -1, height: 5)
        container.layer.shadowRadius = 3
        
        learnMoreButton.setTitle("", for: .normal)
        dismissButton.setTitle("", for: .normal)
        learnMoreButton.setImage(UIImage(named: "learn-more"), for: .normal)
        dismissButton.setImage(UIImage(named: "dismiss-communication"), for: .normal)
        layoutIfNeeded()
        delegate?.shouldUpdateUI()
    }
}

extension CommunicationBannerTableViewCell: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        if UIApplication.shared.canOpenURL(URL) {
            UIApplication.shared.open(URL)
        }
        return false
    }
}

// TODO: Move these to proper extension files, as these files will become obsolete soon
extension String {
    /// Creates attributed string from HTML string
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



extension String {
    /// Replaces HTML tags for styling with inline CSS and injects a Font through CSS with the given size
    func injectHTMLFont(size: Int) -> String {
        var edited = self
        // Italic text
        edited = edited.replacingOccurrences(of: "<em>", with: "<span style=\"font-style: italic;\">")
        edited = edited.replacingOccurrences(of: "</em>", with: "</span>")
        // Underlined text
        edited = edited.replacingOccurrences(of: "<u>", with: "<span style=\"text-decoration: underline;\">")
        edited = edited.replacingOccurrences(of: "</u>", with: "</span>")
        // Bold Text
        edited = edited.replacingOccurrences(of: "<b>", with: "<span style=\"font-weight: bold;\">")
        edited = edited.replacingOccurrences(of: "</b>", with: "</span>")
        // Strikethrough text
        edited = edited.replacingOccurrences(of: "<del>", with: "<span style=\"text-decoration: line-through;\">")
        edited = edited.replacingOccurrences(of: "</del>", with: "</span>")
        edited = edited.replacingOccurrences(of: "<p>", with: "<p style=\" font-family: Arial, sans-serif; font-size: \(size)px;\">")
        
        return edited
    }
}


extension NSAttributedString {
    /// Cuts off text after given number of characters and adds ...
    func cutOff(at maxChar: Int) -> NSMutableAttributedString? {
        guard self.string.count > maxChar, let mutStr = self.mutableCopy() as? NSMutableAttributedString else {
            return nil
        }
        let textString = self.string
        let length = textString.count
        let reminder = length - maxChar
        let hiddenChars = String(textString.suffix(reminder))
        let range = (mutStr.string as NSString).range(of: hiddenChars)
        mutStr.deleteCharacters(in: range)
        let dots = NSAttributedString(string: "...", attributes: nil)
        mutStr.append(dots)
        return mutStr
    }
    
    func trimmedAttributedString() -> NSAttributedString {
        let invertedSet = CharacterSet.whitespacesAndNewlines.inverted
        let startRange = string.rangeOfCharacter(from: invertedSet)
        let endRange = string.rangeOfCharacter(from: invertedSet, options: .backwards)
        guard let startLocation = startRange?.upperBound, let endLocation = endRange?.lowerBound else {
            return NSAttributedString(string: string)
        }
        let location = string.distance(from: string.startIndex, to: startLocation) - 1
        let length = string.distance(from: startLocation, to: endLocation) + 2
        let range = NSRange(location: location, length: length)
        return attributedSubstring(from: range)
    }
}
