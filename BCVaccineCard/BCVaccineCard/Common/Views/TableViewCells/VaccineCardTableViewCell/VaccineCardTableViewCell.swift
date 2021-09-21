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
    @IBOutlet weak var tapToZoomInLabel: UILabel!
    @IBOutlet weak var statusBackgroundView: UIView!
    @IBOutlet weak var expandableBackgroundView: UIView!
    
    // TODO: Will need this information from metadata
    private let placeholderDate = "September-09-2012, 14:27"

    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }

    private func setup() {
        nameLabel.textColor = .white
        nameLabel.font = UIFont.bcSansBoldWithSize(size: 16)
        vaccineStatusLabel.textColor = .white
        vaccineStatusLabel.font = UIFont.bcSansRegularWithSize(size: 18)
        issuedOnLabel.textColor = .white
        issuedOnLabel.font = UIFont.bcSansRegularWithSize(size: 11)
        tapToZoomInLabel.textColor = .white
        tapToZoomInLabel.font = UIFont.bcSansBoldWithSize(size: 12)
        tapToZoomInLabel.text = Constants.Strings.MyCardFlow.HasCards.tapToZoomIn
    }
    
    func configure(model: VaccinePassportModel, expanded: Bool) {
        nameLabel.text = model.name
        checkmarkImageView.isHidden = model.status != .fully
        vaccineStatusLabel.text = model.status.getTitle
        issuedOnLabel.text = Constants.Strings.MyCardFlow.HasCards.issuedOn + placeholderDate
        statusBackgroundView.backgroundColor = model.status.getColor
        expandableBackgroundView.backgroundColor = model.status.getColor
        qrCodeImage.image = UIImage(named: model.imageName)
        expandableBackgroundView.isHidden = !expanded
    }
    
}
