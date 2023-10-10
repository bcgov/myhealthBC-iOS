//
//  DiagnosticImagingInfoTableViewCell.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2023-10-04.
//

import UIKit

protocol DiagnosticImagingInfoTableViewCellDelegate {
    func openLink(type: DiagnosticImagingInfoTableViewCell.Link)
}

class DiagnosticImagingInfoTableViewCell: UITableViewCell {

    @IBOutlet weak var divider: UIView!
    @IBOutlet weak var FirstLabel: UILabel!
    @IBOutlet weak var secondLabel: UILabel!
    @IBOutlet weak var healthLinkBCLabel: UILabel!
    @IBOutlet weak var BCRadiologicalLabel: UILabel!
    
    enum Link {
        case HealthLinkBC
        case BCRadiologicalSociety
    }
    
    var delegate: DiagnosticImagingInfoTableViewCellDelegate? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setup(delegate: DiagnosticImagingInfoTableViewCellDelegate) {
        self.delegate = delegate
        FirstLabel.font = UIFont.bcSansRegularWithSize(size: 17)
        secondLabel.font = UIFont.bcSansRegularWithSize(size: 17)
        healthLinkBCLabel.font = UIFont.bcSansBoldWithSize(size: 17)
        BCRadiologicalLabel.font = UIFont.bcSansBoldWithSize(size: 17)
        
        healthLinkBCLabel.textColor = AppColours.appBlue
        BCRadiologicalLabel.textColor = AppColours.appBlue
        let healthLinkGesture = UITapGestureRecognizer(target: self, action: #selector(healthLinkTapped))
        healthLinkBCLabel.isUserInteractionEnabled = true
        healthLinkBCLabel.addGestureRecognizer(healthLinkGesture)
        
        let radiologyLinkGesture = UITapGestureRecognizer(target: self, action: #selector(radiologyLinkTapped))
        BCRadiologicalLabel.isUserInteractionEnabled = true
        BCRadiologicalLabel.addGestureRecognizer(radiologyLinkGesture)
        divider.backgroundColor = AppColours.divider
    }
    
    
    @objc private func healthLinkTapped(sender:UITapGestureRecognizer) {
        delegate?.openLink(type: .HealthLinkBC)
    }
    
    @objc private func radiologyLinkTapped(sender:UITapGestureRecognizer) {
        delegate?.openLink(type: .BCRadiologicalSociety)
    }
    
    
}
