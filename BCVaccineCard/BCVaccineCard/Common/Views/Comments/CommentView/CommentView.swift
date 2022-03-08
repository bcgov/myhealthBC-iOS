//
//  CommentView.swift
//  BCVaccineCard
//
//  Created by Amir on 2022-03-03.
//

import UIKit

class CommentView: UIView {
    
    static let dateTimeHeight: CGFloat = 32
    static let verticalSpacing: CGFloat = 10
    static let textFont = UIFont.bcSansRegularWithSize(size: 17)
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var dateTimeLabel: UILabel!
    @IBOutlet weak var dateTimeHeightConstraint: NSLayoutConstraint!
    
    func configure(comment: Comment) {
        textView.text = comment.text
        
        if let createdDate = comment.createdDateTime {
            dateTimeLabel.text = Date.Formatter.issuedOnDateTime.string(from: createdDate)
        } else {
            dateTimeLabel.text = ""
        }
        textView.backgroundColor = .clear
        textView.translatesAutoresizingMaskIntoConstraints = true
        textView.sizeToFit()
        textView.isScrollEnabled = false
        self.backgroundColor = AppColours.commentBackground
        dateTimeLabel.textColor = AppColours.commentDateTime
        textView.textColor = AppColours.textBlack
        
        textView.font = CommentView.textFont
        dateTimeLabel.font = UIFont.bcSansRegularWithSize(size: 13)
        
        dateTimeHeightConstraint.constant = CommentView.dateTimeHeight
        self.layoutIfNeeded()
    }

}

extension Comment {
    func height(width: CGFloat) -> CGFloat {
        let textHeight = text?.heightForView(font: CommentView.textFont, width: width) ?? 0
        return CommentView.dateTimeHeight + CommentView.verticalSpacing + textHeight
    }
}
