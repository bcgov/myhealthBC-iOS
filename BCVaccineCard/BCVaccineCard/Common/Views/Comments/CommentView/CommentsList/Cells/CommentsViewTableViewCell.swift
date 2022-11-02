//
//  CommentsViewTableViewCell.swift
//  BCVaccineCard
//
//  Created by Amir on 2022-03-03.
//

import UIKit

class CommentsViewTableViewCell: UITableViewCell {

    weak var commentView: CommentView? = UIView.fromNib()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        commentView?.placeIn(container: self, paddingVertical: 5, paddingHorizontal: 0)
    }
    
    func configure(comment: Comment) {
        commentView?.configure(comment: comment)
        self.layoutIfNeeded()
    }
    
}
