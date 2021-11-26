//
//  GetARecordTableViewCell.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-11-26.
//

import UIKit

class GetARecordTableViewCell: UITableViewCell {
    
    @IBOutlet weak private var getRecordsView: GetRecordsView!
    
    var type: GetRecordsView.RecordType!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configure(type: GetRecordsView.RecordType) {
        self.type = type
        getRecordsView.configure(type: type)
    }
    
}
