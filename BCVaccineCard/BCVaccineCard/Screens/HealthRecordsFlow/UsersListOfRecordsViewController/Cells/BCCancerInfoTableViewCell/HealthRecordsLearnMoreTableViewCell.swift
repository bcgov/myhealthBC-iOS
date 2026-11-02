//
//  HealthRecordsLearnMoreTableViewCell.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2024-02-05.
//

import UIKit

class HealthRecordsLearnMoreTableViewCell: UITableViewCell {
    
    @IBOutlet weak private var recordLearnMoreView: HealthRecordsLearnMoreView!

    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    private func setup() {
        self.layoutIfNeeded()
    }
    
    func configure(type: RecordsLearnMoreTypes) {
        recordLearnMoreView.configure(type: type)
        self.layoutIfNeeded()
    }
    
}

