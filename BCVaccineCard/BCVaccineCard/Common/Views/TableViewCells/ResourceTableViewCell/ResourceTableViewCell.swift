//
//  ResourceTableViewCell.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-10-11.
//

import UIKit

class ResourceTableViewCell: UITableViewCell {
    
    @IBOutlet weak private var roundedBackgroundView: UIView!
    @IBOutlet weak private var resourceImageView: UIImageView!
    @IBOutlet weak private var resourceLabel: UILabel!
    @IBOutlet weak private var resouceArrowImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    private func setup() {
        resourceLabel.font = UIFont.bcSansBoldWithSize(size: 17)
        resourceLabel.textColor = AppColours.appBlue
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        roundedBackgroundView.backgroundColor = AppColours.backgroundGray
        roundedBackgroundView.layer.cornerRadius = 5
        roundedBackgroundView.layer.masksToBounds = true
    }
    
    func configure(resource: Resource) {
        resourceImageView.image = resource.image
        resourceLabel.text = resource.text
        
        resourceImageView.isAccessibilityElement = false
        resourceLabel.isAccessibilityElement = false
        self.accessibilityLabel = resource.text
        self.accessibilityHint = AccessibilityLabels.OpenWebLink.openWebLinkHint
        self.accessibilityTraits = [.link]
    }

}
