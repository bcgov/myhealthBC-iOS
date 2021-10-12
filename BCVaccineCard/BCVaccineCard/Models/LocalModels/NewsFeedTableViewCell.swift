//
//  NewsFeedTableViewCell.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-10-11.
//

import UIKit

class NewsFeedTableViewCell: UITableViewCell {
    
    @IBOutlet weak private var newsTitleLabel: UILabel!
    @IBOutlet weak private var newsDetailsLabel: UILabel!
    @IBOutlet weak private var newsDateLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    private func setup() {
        newsTitleLabel.font = UIFont.bcSansBoldWithSize(size: 15)
        newsTitleLabel.textColor = AppColours.textBlack
        newsDetailsLabel.font = UIFont.bcSansRegularWithSize(size: 15)
        newsDetailsLabel.textColor = AppColours.textBlack
        newsDateLabel.font = UIFont.bcSansRegularWithSize(size: 15)
        newsDateLabel.textColor = AppColours.textGray
    }

    func configure(item: NewsFeedData.Channel.Item) {
        newsTitleLabel.text = item.title
        newsDetailsLabel.text = item.itemDescription
        newsDateLabel.text = item.pubDate
    }
    
}
