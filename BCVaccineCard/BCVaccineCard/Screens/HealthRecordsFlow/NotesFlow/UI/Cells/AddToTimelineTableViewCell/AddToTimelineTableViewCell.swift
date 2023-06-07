//
//  AddToTimelineTableViewCell.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2023-06-07.
//

import UIKit

class AddToTimelineTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var createdIconImageView: UIImageView!
    @IBOutlet private weak var createdTitleLabel: UILabel!
    @IBOutlet private weak var createdDateValueLabel: UILabel!
    @IBOutlet private weak var createdStackView: UIStackView!
    
    @IBOutlet private weak var folderIconImageView: UIImageView!
    @IBOutlet private weak var folderTitleLabel: UILabel!
    @IBOutlet private weak var selectFolderButton: UIButton!
    @IBOutlet private weak var separatorView: UIView!
    
    @IBOutlet private weak var addToMyTimelineLabel: UILabel!
    @IBOutlet private weak var addToMyTimelineInfoButton: UIButton!
    @IBOutlet private weak var datePickerButton: UIButton!
    @IBOutlet private weak var addToTimelineSwitch: UISwitch!
    @IBOutlet private weak var bottomSeparatorView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction private func selectFolderButtonTapped(_ sender: UIButton) {
        
    }
    
    @IBAction private func addToMyTimelineInfoButtonTapped(_ sender: UIButton) {
        
    }
    
    @IBAction private func addToTimelineSwitchValueChanged(_ sender: UISwitch) {
        
    }
    
}
