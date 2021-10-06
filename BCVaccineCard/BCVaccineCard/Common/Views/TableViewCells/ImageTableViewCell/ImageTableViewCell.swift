//
//  ImageTableViewCell.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-09-28.
//

import UIKit

class ImageTableViewCell: UITableViewCell {
    
    @IBOutlet weak private var cellImageView: UIImageView!
    @IBOutlet weak private var topConstraint: NSLayoutConstraint!
    @IBOutlet weak private var bottomConstraint: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setup()
    }
    
    private func setup() {
        self.isAccessibilityElement = false
        self.accessibilityElementsHidden = true
    }

    func configure(image: UIImage, bottomConstraint: CGFloat) {
        cellImageView.image = image
        self.topConstraint.constant = bottomConstraint * Constants.UI.CellSpacing.qrOptionTopToBottomRatio
        self.bottomConstraint.constant = bottomConstraint
    }
    
}
