//
//  HealthRecordsUserCollectionViewCell.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-11-26.
//

import UIKit

class HealthRecordsUserCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak private var healthRecordsUserView: HealthRecordsUserView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configure(name: String, records: Int) {
        healthRecordsUserView.configure(name: name, records: records)
    }

}
