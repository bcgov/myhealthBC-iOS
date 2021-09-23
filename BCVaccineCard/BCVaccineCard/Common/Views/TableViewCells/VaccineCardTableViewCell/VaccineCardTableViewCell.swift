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
    
    func configure(model: AppVaccinePassportModel, expanded: Bool) {
        nameLabel.text = model.codableModel.name
        checkmarkImageView.isHidden = model.codableModel.status != .fully
        vaccineStatusLabel.text = model.codableModel.status.getTitle
        if let issuedOnDate = model.issueDate {
            issuedOnLabel.text = Constants.Strings.MyCardFlow.HasCards.issuedOn + issuedOnDate
        }
        issuedOnLabel.isHidden = model.issueDate == nil
        statusBackgroundView.backgroundColor = model.codableModel.status.getColor
        expandableBackgroundView.backgroundColor = model.codableModel.status.getColor
        qrCodeImage.image = model.image
        expandableBackgroundView.isHidden = !expanded
    }
    
}
