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
        // TODO: Import image, then set here
//        dismissButton.setImage(<#T##image: UIImage?##UIImage?#>, for: <#T##UIControl.State#>)
        
        
    }
    
    private func setupTextView() {
        // TODO: See what I did for the text view in HG 2.0
        // TODO: Apply proper formatting here
        let attributedText = NSMutableAttributedString(string: "")
        // All text size 13
        
        // Normal text
        // You can add or update immunizations by visiting
        let normal = NSAttributedString(string: "You can add or update immunizations by visiting")
        attributedText.append(normal)
        // link text - bold
        // immunizationrecord.gov.bc.ca.
        let link = NSAttributedString(string: "immunizationrecord.gov.bc.ca.")
        attributedText.append(link)
        // italic text
        // You can always access this information by going to the Resources page.
        let italic = NSAttributedString(string: "You can always access this information by going to the Resources page.")
        attributedText.append(italic)
    }
    
    func configure(delegateOwner: UIViewController) {
        self.delegate = delegateOwner as? CitizenSubmissionTableViewCellDelegate
    }
    
    @IBAction private func dismissAction(_ sender: UIButton) {
        delegate?.dismissButtonTapped()
        // TODO: Note, when dismissed, store boolean in app delegate
    }
    
}
