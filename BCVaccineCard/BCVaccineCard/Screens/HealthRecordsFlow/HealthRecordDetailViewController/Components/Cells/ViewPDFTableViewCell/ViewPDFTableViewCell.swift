//
//  ViewPDFTableViewCell.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2022-09-22.
//

import UIKit

class ViewPDFTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var viewPDFButton: AppStyleButton!

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    public func configure(delegateOwner: UIViewController) {
        viewPDFButton.configure(withStyle: .white, buttonType: .viewPDF, delegateOwner: delegateOwner, enabled: true)
    }
    
}
