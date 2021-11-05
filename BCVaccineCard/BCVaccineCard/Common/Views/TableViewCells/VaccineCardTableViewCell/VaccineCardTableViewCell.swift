//
//  VaccineCardTableViewCell.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-09-15.
//

import UIKit

class VaccineCardTableViewCell: UITableViewCell {
    
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var roundedView: UIView!
    @IBOutlet weak var vaccineCardView: VaccineCardView!
    @IBOutlet weak var federalPassView: FederalPassView!
    @IBOutlet weak var federalPassViewHeightConstraint: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }

    private func setup() {
        viewSetup()
    }
    
    private func viewSetup() {
        shadowView.backgroundColor = UIColor.clear
        shadowView.layer.shadowColor = UIColor.black.cgColor
        shadowView.layer.shadowOffset = CGSize(width: 2, height: 2)
        shadowView.layer.shadowRadius = 6.0
        
        roundedView.layer.cornerRadius = 3
        roundedView.layer.masksToBounds = true
    }
    
    private func adjustShadow(expanded: Bool) {
        shadowView.layer.shadowOpacity = expanded ? 0.7 : 0.0
    }
    
    func configure(model: AppVaccinePassportModel, expanded: Bool, editMode: Bool, delegateOwner: UIViewController) {
        vaccineCardView.configure(model: model, expanded: expanded, editMode: editMode)
        federalPassView.isHidden = !expanded
        federalPassViewHeightConstraint.constant = expanded ? 94.0 : 0.0
        if expanded {
            federalPassView.configure(model: model, delegateOwner: delegateOwner)
        }
        adjustShadow(expanded: expanded)
    }

}
