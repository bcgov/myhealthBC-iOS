//
//  TextListViewTableViewCell.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-11-29.
//

import UIKit

class TextListViewTableViewCell: UITableViewCell {
    
    @IBOutlet weak private var textListView: TextListView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configure(data: [TextListModel]) {
        textListView.configure(data: data)
    }
    
}
