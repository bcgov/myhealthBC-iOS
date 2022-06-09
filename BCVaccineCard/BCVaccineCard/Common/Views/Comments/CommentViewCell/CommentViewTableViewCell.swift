//
//  CommentViewTableViewCell.swift
//  BCVaccineCard
//
//  Created by Amir on 2022-03-08.
//

import UIKit

class CommentViewTableViewCell: UITableViewCell {
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var stack: UIStackView!
    @IBOutlet weak var commentText: UILabel!
    @IBOutlet weak var dateTimeLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configure(comment: Comment) {
        commentText.text = comment.text
        
        if let createdDate = comment.createdDateTime {
            dateTimeLabel.text = Date.Formatter.commentsDateTime.string(from: createdDate)
        } else {
            dateTimeLabel.text = ""
        }
        commentText.backgroundColor = .clear
        self.backgroundColor = .clear
        container.backgroundColor = AppColours.commentBackground
        dateTimeLabel.textColor = AppColours.commentDateTime
        commentText.textColor = AppColours.textBlack
        
        commentText.font = CommentView.textFont
        dateTimeLabel.font = UIFont.bcSansRegularWithSize(size: 13)
        
        self.layoutIfNeeded()
    }
    
}
