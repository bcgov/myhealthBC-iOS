//
//  CitizenSubmissionTableViewCell.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2023-03-02.
//

import UIKit

protocol CitizenSubmissionTableViewCellDelegate: AnyObject {
    func dismissButtonTapped()
    func websiteTapped(urlString: String) // Prob don't need this
}

class CitizenSubmissionTableViewCell: UITableViewCell {
    
    @IBOutlet weak private var roundedView: UIView!
    @IBOutlet weak private var informationIconButton: UIButton!
    @IBOutlet weak private var contentTextView: UITextView!
    @IBOutlet weak private var dismissButton: UIButton!
    
    private weak var delegate: CitizenSubmissionTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }

    private func setup() {
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        roundedView.layer.cornerRadius = 10
        roundedView.backgroundColor = AppColours.appBlueLight
        informationIconButton.setImage(UIImage(named: "info-icon-fill"), for: .normal)
        informationIconButton.isUserInteractionEnabled = false
        dismissButton.setImage(UIImage(named: "close-icon"), for: .normal)
        setupTextView()
    }
    
    private func setupTextView() {
        contentTextView.isUserInteractionEnabled = true
        contentTextView.isEditable = false
        contentTextView.backgroundColor = .clear
        let attributedText = NSMutableAttributedString(string: "")
        // All text size 13
        
        // Normal text
        // You can add or update immunizations by visiting
        let normalAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.bcSansRegularWithSize(size: 13),
            .foregroundColor: AppColours.textBlack
        ]
        let normal = NSAttributedString(string: "You can add or update immunizations by visiting\n", attributes: normalAttributes)
        attributedText.append(normal)
        // link text - bold
        // immunizationrecord.gov.bc.ca.
        let stringUrl = "immunizationrecord.gov.bc.ca."
        let linkUrl = "https://www.immunizationrecord.gov.bc.ca."
        guard let url = URL(string: linkUrl) else { return }
        let linkAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.bcSansBoldWithSize(size: 13),
            .foregroundColor: AppColours.appBlue,
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .link: url
        ]
        let link = NSAttributedString(string: stringUrl, attributes: linkAttributes)
        attributedText.append(link)
        // italic text
        // You can always access this information by going to the Resources page.
        let italicAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.bcSansItalicWithSize(size: 13),
            .foregroundColor: AppColours.textBlack
        ]
        let italic = NSAttributedString(string: "\nYou can always access this information by going to the Resources page.", attributes: italicAttributes)
        attributedText.append(italic)
        
        contentTextView.attributedText = attributedText
        
        contentTextView.textContainerInset = .zero
        contentTextView.textContainer.lineFragmentPadding = 0.0
    }
    
    func configure(delegateOwner: UIViewController) {
        self.delegate = delegateOwner as? CitizenSubmissionTableViewCellDelegate
    }
    
    @IBAction private func dismissAction(_ sender: UIButton) {
        delegate?.dismissButtonTapped()
        // TODO: Note, when dismissed, store boolean in app delegate
    }
    
}
