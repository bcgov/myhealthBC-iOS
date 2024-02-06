//
//  BCCancerInfoTableViewCell.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2024-02-05.
//

import UIKit

class BCCancerInfoTableViewCell: UITableViewCell {
    
    @IBOutlet weak private var bcCancerInfoView: BCCancerInfoView!

    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    private func setup() {
        self.layoutIfNeeded()
    }
    
}

