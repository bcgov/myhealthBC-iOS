//
//  ImageTableViewCell.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-09-28.
//

import UIKit

class ImageTableViewCell: UITableViewCell {
    
    @IBOutlet weak private var cellImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setup()
    }
    
    private func setup() {
        self.isAccessibilityElement = false
        self.accessibilityElementsHidden = true
    }

    func configure(image: UIImage) {
        cellImageView.image = image
    }
    
}
