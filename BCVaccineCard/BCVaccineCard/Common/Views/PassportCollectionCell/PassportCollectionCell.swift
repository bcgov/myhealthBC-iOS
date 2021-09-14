//
//  PassportCollectionCell.swift
//  ClientVaxPass-POC
//
//  Created by Connor Ogilvie on 2021-09-10.
// PassportCollectionCell

import UIKit

class PassportCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var checkmarkImageView: UIImageView!
    @IBOutlet weak var vaccineStatusLabel: UILabel!
    @IBOutlet weak var issuedOnLabel: UILabel!
    @IBOutlet weak var qrCodeImage: UIImageView!
    @IBOutlet weak var statusBackgroundView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(model: VaccinePassportModel) {
        nameLabel.text = model.name
        checkmarkImageView.isHidden = model.status != .fully
        vaccineStatusLabel.text = model.status.getTitle
        statusBackgroundView.backgroundColor = model.status.getColor
        qrCodeImage.image = UIImage(named: model.imageName)
        print("CONNOR IMAGE: ", self.qrCodeImage.frame)
    }

}

