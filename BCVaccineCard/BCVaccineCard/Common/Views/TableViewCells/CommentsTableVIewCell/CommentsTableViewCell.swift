//
//  CommentsTableViewCell.swift
//  BCVaccineCard
//
//  Created by Amir on 2022-03-04.
//

import UIKit

class CommentsTableViewCell: UITableViewCell {
    weak var commentsListView: CommentsListView?
    
    @IBOutlet weak var contentContainer: UIView!
    @IBOutlet weak var contentHeightConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(comments: [Comment]) {
        self.commentsListView = createView()
        self.contentHeightConstraint.constant = commentsListView?.computeHeight(comments: comments) ?? 0
        commentsListView?.placeIn(container: contentContainer, paddingVertical: 0, paddingHorizontal: 0)
        commentsListView?.configure(comments: comments)
    }
    
    private func createView() -> CommentsListView {
        if let existing = self.commentsListView {existing.removeFromSuperview()}
        let commentsListView: CommentsListView = UIView.fromNib()
        return commentsListView
    }
}
