//
//  UserRecordListTableViewCell.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-11-26.
//

import UIKit
import SwipeCellKit

class UserRecordListTableViewCell: SwipeTableViewCell {
    
    @IBOutlet weak private var userRecordListView: UserRecordListView!
    
    var type: HealthRecordsDetailDataSource.RecordType {
        return userRecordListView.type
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configure(record: HealthRecordsDetailDataSource) {
        userRecordListView.configure(record: record)
        self.layoutIfNeeded()
    }
    
}
