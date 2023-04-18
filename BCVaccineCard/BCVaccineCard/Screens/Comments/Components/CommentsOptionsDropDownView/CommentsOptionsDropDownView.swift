//
//  CommentsOptionsDropDownView.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2023-04-10.
//

import UIKit

// NOTE: size should be 145 x 106 when setting
// NOTE: Not currently using, but created in case we decide to switch the UI to what the designs are instead of what the ticket shows

protocol CommentsOptionsDropDownViewDelegate: AnyObject {
    func beginEditingComment()
    func deleteComment()
}

class CommentsOptionsDropDownView: UIView {
    
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var editCommentButton: UIButton!
    @IBOutlet private weak var deleteCommentButton: UIButton!
    @IBOutlet private weak var separatorView: UIView!
    
    weak var delegate: CommentsOptionsDropDownViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed(CommentsOptionsDropDownView.getName, owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        setup()
    }
    
    private func setup() {
        contentView.layer.cornerRadius = 3.0
        contentView.clipsToBounds = true
        separatorView.backgroundColor = AppColours.borderGray
        editCommentButton.setTitle("Edit comment", for: .normal)
        editCommentButton.setTitleColor(AppColours.appBlue, for: .normal)
        editCommentButton.titleLabel?.font = UIFont.bcSansRegularWithSize(size: 15)
        deleteCommentButton.setTitle("Delete", for: .normal)
        deleteCommentButton.setTitleColor(AppColours.appRed, for: .normal)
        deleteCommentButton.titleLabel?.font = UIFont.bcSansRegularWithSize(size: 15)
    }
    
    func configure(delegateOwner: UIViewController) {
        self.delegate = delegateOwner as? CommentsOptionsDropDownViewDelegate
    }
    
    @IBAction private func editCommentButtonTapped(_ sender: UIButton) {
        delegate?.beginEditingComment()
    }
    
    @IBAction private func deleteCommentButtonTapped(_ sender: UIButton) {
        delegate?.deleteComment()
    }
    
}
