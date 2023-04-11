//
//  CommentViewTableViewCell.swift
//  BCVaccineCard
//
//  Created by Amir on 2022-03-08.
//

import UIKit

protocol CommentViewTableViewCellDelegate: AnyObject {
    func optionsTapped(row: Int)
}

class CommentViewTableViewCell: UITableViewCell {
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var stack: UIStackView!
    @IBOutlet weak var commentText: UILabel!
    @IBOutlet weak var dateTimeLabel: UILabel!
    @IBOutlet weak var optionsButton: UIButton!
    
    private var row: Int?
    weak var delegate: CommentViewTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func configure(comment: Comment, row: Int? = nil, delegateOwner: UIViewController? = nil, showOptionsButton: Bool, otherCellBeingEdited: Bool? = nil) {
        commentText.text = comment.text
        self.row = row
        self.delegate = delegateOwner as? CommentViewTableViewCellDelegate
        optionsButton.isEnabled = !(otherCellBeingEdited == true)
        optionsButton.isHidden = !showOptionsButton
        if let createdDate = comment.createdDateTime, !comment.isPosting {
            dateTimeLabel.text = Date.Formatter.commentsDateTime.string(from: createdDate)
        } else if comment.isPosting {
            dateTimeLabel.text = "Posting..."
        } else {
            dateTimeLabel.text = ""
        }
        commentText.backgroundColor = .clear
        self.backgroundColor = .clear
        container.backgroundColor = AppColours.commentBackground
        dateTimeLabel.textColor = AppColours.greyText
        commentText.textColor = AppColours.textBlack
        
        commentText.font = CommentView.textFont
        dateTimeLabel.font = UIFont.bcSansRegularWithSize(size: 13)
        
        optionsButton.tintColor = AppColours.darkGreyText
        
        self.alpha = otherCellBeingEdited == true ? 0.5 : 1.0
        
                
        self.layoutIfNeeded()
    }
    
    @IBAction private func optionsButtonTapped(_ sender: UIButton) {
        guard let row = self.row else { return }
        self.delegate?.optionsTapped(row: row)
    }
    
}

extension Comment {
    var isPosting: Bool {
        return self.id == nil || self.id == ""
    }
}
