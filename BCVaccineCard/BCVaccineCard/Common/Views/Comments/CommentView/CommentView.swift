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
    
    func configure(comment: Comment) {
        textView.text = comment.text
        
        if let createdDate = comment.createdDateTime, !comment.isPosting {
            dateTimeLabel.text = Date.Formatter.commentsDateTime.string(from: createdDate)
        } else if comment.isPosting {
            dateTimeLabel.text = "Posting..."
        } else {
            dateTimeLabel.text = ""
        }
        textView.backgroundColor = .clear
        textView.translatesAutoresizingMaskIntoConstraints = true
        textView.sizeToFit()
        textView.isScrollEnabled = false
        self.backgroundColor = AppColours.commentBackground
        dateTimeLabel.textColor = AppColours.greyText
        textView.textColor = AppColours.textBlack
        
        textView.font = CommentView.textFont
        dateTimeLabel.font = UIFont.bcSansRegularWithSize(size: 13)
        
        self.layoutIfNeeded()
    }

}
