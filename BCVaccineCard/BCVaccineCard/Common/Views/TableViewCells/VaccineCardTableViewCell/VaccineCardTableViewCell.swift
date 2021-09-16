//
//  VaccineCardTableViewCell.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-09-15.
//

import UIKit

class VaccineCardTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var checkmarkImageView: UIImageView!
    @IBOutlet weak var vaccineStatusLabel: UILabel!
    @IBOutlet weak var issuedOnLabel: UILabel!
    @IBOutlet weak var qrCodeImage: UIImageView!
    @IBOutlet weak var statusBackgroundView: UIView!
    @IBOutlet weak var expandableBackgroundView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        // Configure the view for the selected state
//    }
    
    func configure(model: VaccinePassportModel, expanded: Bool) {
        nameLabel.text = model.name
        checkmarkImageView.isHidden = model.status != .fully
        vaccineStatusLabel.text = model.status.getTitle
        statusBackgroundView.backgroundColor = model.status.getColor
        expandableBackgroundView.backgroundColor = model.status.getColor
        qrCodeImage.image = UIImage(named: model.imageName)
        expandableBackgroundView.isHidden = !expanded
    }
    
}
