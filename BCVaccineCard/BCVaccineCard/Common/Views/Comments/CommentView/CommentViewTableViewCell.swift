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

        self.layoutIfNeeded()
    }
}

extension Comment {
    var isPosting: Bool {
        return self.id == nil || self.id == ""
    }
}
