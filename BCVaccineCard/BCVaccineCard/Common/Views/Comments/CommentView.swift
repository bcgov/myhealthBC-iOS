//
//  CommentView.swift
//  BCVaccineCard
//
//  Created by Amir on 2022-03-03.
//

import UIKit

class CommentView: UIView {
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var dateTimeLabel: UILabel!
    
    func configure(comment: Comment) {
        textView.text = comment.text
        
        if let createdDate = comment.createdDateTime {
            dateTimeLabel.text = Date.Formatter.issuedOnDateTime.string(from: createdDate)
        } else {
            dateTimeLabel.text = ""
        }
        self.backgroundColor = AppColours.commentBackground
        dateTimeLabel.textColor = AppColours.commentDateTime
        textView.textColor = AppColours.textBlack
        
        textView.font = UIFont.bcSansRegularWithSize(size: 17)
        dateTimeLabel.font = UIFont.bcSansRegularWithSize(size: 13)
    }

}
