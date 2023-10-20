//
//  CommunicationBannerCollectionViewCell.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2023-06-29.
//

import UIKit

protocol CommunicationBannerCollectionViewCellDelegate {
    func onExpand(banner: CommunicationBanner?)
    func onClose(banner: CommunicationBanner?)
    func onDismiss(banner: CommunicationBanner?)
    func onLearnMore(banner: CommunicationBanner?)
    func shouldUpdateUI(estimatedTextViewLines lines: Int, isExpanded: Bool)
}

class CommunicationBannerCollectionViewCell: UICollectionViewCell {

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

    private var delegate: CommunicationBannerCollectionViewCellDelegate?
    private var data: CommunicationBanner?
    private var lineBreakCount = 30
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

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

    func configure(data: CommunicationBanner?, delegate: CommunicationBannerCollectionViewCellDelegate) {
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
        let lines = Int(ceil(Double(textView.text.count) / Double(lineBreakCount)))
        delegate?.shouldUpdateUI(estimatedTextViewLines: lines, isExpanded: isExpanded)
    }
}

extension CommunicationBannerCollectionViewCell: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        if UIApplication.shared.canOpenURL(URL) {
            UIApplication.shared.open(URL)
        }
        return false
    }
}
