//
//  AddToTimelineTableViewCell.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2023-06-07.
//

import UIKit

enum AddToTimelineTableViewCellState {
    case AddNote
    case ViewNote
    case EditNote
}

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
        setup()
    }
    
    private func setup() {
        createdTitleLabel.font = UIFont.bcSansRegularWithSize(size: 13)
        createdTitleLabel.textColor = AppColours.textGray
        createdTitleLabel.text = "Created"
        createdDateValueLabel.font = UIFont.bcSansBoldWithSize(size: 13)
        createdDateValueLabel.textColor = AppColours.textBlack
        folderTitleLabel.font = UIFont.bcSansRegularWithSize(size: 13)
        folderTitleLabel.textColor = AppColours.textGray
        folderTitleLabel.text = "Folder"
        selectFolderButton.layer.cornerRadius = 4.0
        selectFolderButton.titleLabel?.font = UIFont.bcSansBoldWithSize(size: 13)
        selectFolderButton.titleLabel?.textColor = AppColours.textBlack
        addToMyTimelineLabel.font = UIFont.bcSansRegularWithSize(size: 15)
        addToMyTimelineLabel.textColor = AppColours.textGray
        addToMyTimelineLabel.text = "Add to my Timeline"
        datePickerButton.titleLabel?.font = UIFont.bcSansRegularWithSize(size: 15)
        datePickerButton.titleLabel?.textColor = AppColours.blueLightText
    }
    
    func configure(for note: PostNote?, state: AddToTimelineTableViewCellState) {
        // TODO: Add in user interaction formatting based on screen state
        formatForState(state: state)
        formatDate(for: note)
        let on = note?.addedToTimeline ?? false
        addToTimelineSwitch.setOn(on, animated: false)
    }
    
    private func formatForState(state: AddToTimelineTableViewCellState) {
        createdStackView.isHidden = state == .AddNote
        // TODO: Will adjust the folder background colour if note is attached to a folder or not, once we build that feature
        let hasFolder = false
        selectFolderButton.backgroundColor = state == .AddNote ? AppColours.disabledGray : (hasFolder ? AppColours.appBlueLight : .white)
        let titleText = state == .AddNote ? "Select" : (hasFolder ? "Title Of Folder here" : "None")
        selectFolderButton.setTitle(titleText, for: .normal)
    }
    
    private func formatDate(for note: PostNote?) {
        guard let date = note?.journalDate else {
            datePickerButton.setTitle("Today", for: .normal)
            return
        }
        // TODO: Get the date here, will be in yyyy-mm-dd time format
        if date == Date().yearMonthDayString {
            datePickerButton.setTitle("Today", for: .normal)
        } else {
            datePickerButton.setTitle(date, for: .normal)
        }
    }
    
    @IBAction private func selectFolderButtonTapped(_ sender: UIButton) {
        
    }
    
    @IBAction private func addToMyTimelineInfoButtonTapped(_ sender: UIButton) {
        
    }
    
    @IBAction private func addToTimelineSwitchValueChanged(_ sender: UISwitch) {
        
    }
    
}
