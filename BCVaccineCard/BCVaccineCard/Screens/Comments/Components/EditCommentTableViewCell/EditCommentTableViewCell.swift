//
//  EditCommentTableViewCell.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2023-04-10.
//

import UIKit

class EditCommentTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var commentTextView: UITextView!
    @IBOutlet private weak var cancelButton: AppStyleButton!
    @IBOutlet private weak var updateButton: AppStyleButton!
    
    private var initialComment: Comment?

    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    private func setup() {
        commentTextView.backgroundColor = AppColours.commentBackground
        commentTextView.textColor = AppColours.textBlack
        commentTextView.font = CommentView.textFont
        commentTextView.layer.cornerRadius = 4.0
        commentTextView.clipsToBounds = true
        commentTextView.delegate = self
    }

    
    func configure(comment: Comment, delegateOwner: UIViewController) {
        self.initialComment = comment
        commentTextView.text = comment.text
        cancelButton.configure(withStyle: .white, buttonType: .cancel, delegateOwner: delegateOwner, enabled: true, font: UIFont.bcSansBoldWithSize(size: 13))
        updateButton.configure(withStyle: .blue, buttonType: .update, delegateOwner: delegateOwner, enabled: false, font: UIFont.bcSansBoldWithSize(size: 13))
    }
    
}

// TODO: Add in restrictions here for comment that we have when initially adding a comment
// Note, see 'CommentTextFieldView' for rules and implemented UI - will do something very similar, but obviously we're using a textView instead



extension EditCommentTableViewCell: UITextViewDelegate {
    // TODO: Add check for initial comment to make sure that text has changed - if not, then disable button
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        <#code#>
    }
    
    func textViewDidChange(_ textView: UITextView) {
        <#code#>
    }
}
