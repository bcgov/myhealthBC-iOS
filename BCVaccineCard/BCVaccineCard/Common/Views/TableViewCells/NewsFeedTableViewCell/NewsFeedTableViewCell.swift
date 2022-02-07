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

//    func configure(item: NewsFeedData.Channel.Item) {
//        newsTitleLabel.text = item.title
//        newsDetailsLabel.text = item.itemDescription
//        newsDateLabel.text = item.pubDate
//    }
    
    func configure(item: Item) {
        newsTitleLabel.isHidden = item.title == nil
        newsTitleLabel.text = item.title
        newsDetailsLabel.isHidden = item.itemDescription == nil
        newsDetailsLabel.text = item.itemDescription
        guard let date = item.pubDate else {
            newsDateLabel.isHidden = true
            return
        }
        let dateString = Date.Formatter.yearMonthDay.string(from: date)
        newsDateLabel.text = dateString
        
        setupAccessibility()
    }
    
    func setupAccessibility() {
        newsDateLabel.isAccessibilityElement = false
        newsTitleLabel.isAccessibilityElement = false
        newsDetailsLabel.isAccessibilityElement = false
        
        var label = ""
        if let date = newsDateLabel.text, !date.isEmpty {
            label = "\(String.publishedOn): \(date). \n"
        }
        if let title = newsTitleLabel.text, !title.isEmpty {
            label += "\(String.title): \(title). \n"
        }
        
        if let detail = newsDetailsLabel.text, !detail.isEmpty {
            label += "\(String.details): \(detail). \n"
        }
        
        self.accessibilityLabel = label
        self.accessibilityHint = AccessibilityLabels.OpenWebLink.openWebLinkHint
        self.accessibilityTraits = .link
    }
}
