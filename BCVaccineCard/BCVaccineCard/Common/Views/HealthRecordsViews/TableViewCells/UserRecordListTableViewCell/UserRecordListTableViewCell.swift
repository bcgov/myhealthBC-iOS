//
//  UserRecordListTableViewCell.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-11-26.
//

import UIKit

class UserRecordListTableViewCell: UITableViewCell {
    
    @IBOutlet weak private var userRecordListView: UserRecordListView!
    
    var type: UserRecordListView.RecordType {
        return userRecordListView.type
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configure(type: UserRecordListView.RecordType) {
        userRecordListView.configure(recordType: type)
    }
    
}
