//
//  EditCommentTableViewCell.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2023-04-10.
//

import UIKit

protocol EditCommentTableViewCellDelegate: AnyObject {
    func newText(string: String)
}

class EditCommentTableViewCell: UITableViewCell {
    
    let MAXCHAR = 1000
    
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var commentTextView: UITextView!
    @IBOutlet private weak var messageLabel: UILabel!
    @IBOutlet private weak var cancelButton: AppStyleButton!
    @IBOutlet private weak var updateButton: AppStyleButton!
    
    private var initialComment: Comment?
    weak var delegate: EditCommentTableViewCellDelegate?
    
    var getText: String {
        get {
            return commentTextView.text
        }
    }

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
        messageLabel.alpha = 0
        messageLabel.font = UIFont.bcSansRegularWithSize(size: 12)
    }

    
    func configure(comment: Comment, delegateOwner: UIViewController) {
        self.initialComment = comment
        commentTextView.text = comment.text
        cancelButton.configure(withStyle: .white, buttonType: .cancel, delegateOwner: delegateOwner, enabled: true, font: UIFont.bcSansBoldWithSize(size: 13))
        updateButton.configure(withStyle: .blue, buttonType: .update, delegateOwner: delegateOwner, enabled: false, font: UIFont.bcSansBoldWithSize(size: 13))
        delegate = delegateOwner as? EditCommentTableViewCellDelegate
    }
    
}

extension EditCommentTableViewCell: UITextViewDelegate {

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard let textViewText = textView.text,
            let rangeOfTextToReplace = Range(range, in: textViewText) else {
                return false
        }
        let substringToReplace = textViewText[rangeOfTextToReplace]
        let count = textViewText.count - substringToReplace.count + text.count
        let isAllowed = count <= MAXCHAR
        if !isAllowed {
            showMaxCharCount()
        } else {
            removeMaxCharCount()
        }
        
        return isAllowed
    }
    
    func textViewDidChange(_ textView: UITextView) {
        guard let initialText = initialComment?.text else { return }
        let enabled = (initialText.trimWhiteSpacesAndNewLines != textView.text.trimWhiteSpacesAndNewLines) && textView.text.trimWhiteSpacesAndNewLines.count > 0
        updateButton.enabled = enabled
        if enabled {
            delegate?.newText(string: textView.text)
        }
        
    }
    
    func showMaxCharCount() {
        messageLabel.alpha = 1
        messageLabel.text = "Maximum \(MAXCHAR) characters"
        messageLabel.textColor = AppColours.appRed
    }
    
    func removeMaxCharCount() {
        messageLabel.alpha = 0
    }
}
