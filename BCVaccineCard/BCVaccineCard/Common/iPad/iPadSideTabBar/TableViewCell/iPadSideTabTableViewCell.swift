//
//  iPadSideTabTableViewCell.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2023-11-20.
//

import UIKit

class iPadSideTabTableViewCell: UITableViewCell {
    
    @IBOutlet weak private var homeScreenTabIconImageView: UIImageView!
    @IBOutlet weak private var homeScreenTabTitleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    private func setup() {
        self.contentView.backgroundColor = AppColours.appBlue
        homeScreenTabTitleLabel.textColor = .white
    }
    
    private func setTextFont(selected: Bool) {
        homeScreenTabTitleLabel.font = selected ? UIFont.bcSansBoldWithSize(size: 12) : UIFont.bcSansRegularWithSize(size: 12)
    }
    
    func configure(tab: AppTabs, selected: Bool) {
        setTextFont(selected: selected)
        homeScreenTabTitleLabel.text = tab.getIPadText
        homeScreenTabIconImageView.image = selected ? tab.getIPadIconSelected : tab.getIPadIconUnselected
        self.isSelected = selected
    }
    
}
