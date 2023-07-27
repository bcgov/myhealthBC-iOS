//
//  AddToTimelineTableViewCell.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2023-06-07.
//

import UIKit

protocol AddToTimelineTableViewCellDelegate: AnyObject {
    func selectFolderButtonTapped() // TODO: Update this when we include this feature
    func datePickerChanged(date: String)
    func addToTimelineInfoButtonTapped()
    func addToTimelineSwitchValueChanged(isOn: Bool)
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
    @IBOutlet private weak var folderStackView: UIStackView!
    
    @IBOutlet private weak var addToTimelineSectionStackView: UIStackView!
    @IBOutlet private weak var addToMyTimelineLabel: UILabel!
    @IBOutlet private weak var addToMyTimelineInfoButton: UIButton!
    @IBOutlet private weak var datePickerTextField: UITextField!
    @IBOutlet private weak var addToTimelineSwitch: UISwitch!
    @IBOutlet private weak var bottomSeparatorView: UIView!
    
    private weak var delegate: AddToTimelineTableViewCellDelegate?
    
    private var datePicker: UIDatePicker?

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
        separatorView.backgroundColor = AppColours.borderGray
        selectFolderButton.layer.cornerRadius = 4.0
        selectFolderButton.titleLabel?.font = UIFont.bcSansBoldWithSize(size: 13)
        selectFolderButton.setTitleColor(AppColours.textBlack, for: .normal)
        addToMyTimelineLabel.font = UIFont.bcSansRegularWithSize(size: 15)
        addToMyTimelineLabel.textColor = AppColours.textGray
        addToMyTimelineLabel.text = "Add to my Timeline"
        datePickerTextField.font = UIFont.bcSansRegularWithSize(size: 15)
        datePickerTextField.textColor = AppColours.blueLightText
        datePickerTextField.borderStyle = .none
        datePickerTextField.backgroundColor = .white
        bottomSeparatorView.backgroundColor = AppColours.borderGray
        switchBaseFormatting()
        // NOTE: Uncomment this when we want to use the folder structure
        folderStackView.isHidden = true
    }
    
    private func switchBaseFormatting() {
        addToTimelineSwitch.layer.borderWidth = 1.0
        addToTimelineSwitch.layer.cornerRadius = 15.5
        addToTimelineSwitch.layer.borderColor = AppColours.appBlue.cgColor
        addToTimelineSwitch.onTintColor = AppColours.appBlue
        if #available(iOS 13.0, *) {
            addToTimelineSwitch.subviews[0].subviews[0].backgroundColor = .white
        } else {
            addToTimelineSwitch.backgroundColor = .white
        }
    }
    
    private func switchVariableFormatting(isOn: Bool) {
        addToTimelineSwitch.thumbTintColor = isOn ? .white : AppColours.appBlue
    }
    
    func configure(for note: PostNote?, state: NoteVCCellState, delegateOwner: UIViewController) {
        formatForState(state: state)
        formatDate(for: note)
        let on = note?.addedToTimeline ?? false
        addToTimelineSwitch.setOn(on, animated: false)
        self.delegate = delegateOwner as? AddToTimelineTableViewCellDelegate
        if state != .ViewNote {
            addDatePicker()
        }
        switchVariableFormatting(isOn: note?.addedToTimeline ?? false)
        formatDateInViewMode(for: note, state: state)
        // TODO: Adjust once we have a folder structure
        let doesntHaveFolder = true
        if state == .ViewNote && doesntHaveFolder {
            // Ignore for now
        } else {
            selectFolderButton.contentEdgeInsets = UIEdgeInsets(top: 5, left: 8, bottom: 5, right: 8)
        }
        self.layoutIfNeeded()
    }
    
    
    private func formatForState(state: NoteVCCellState) {
        createdStackView.isHidden = state == .AddNote
        addToTimelineSectionStackView.isHidden = state == .ViewNote
//        datePickerTextField.isUserInteractionEnabled = state != .ViewNote
        selectFolderButton.isUserInteractionEnabled = state != .ViewNote
//        addToTimelineSwitch.isUserInteractionEnabled = state != .ViewNote
        // Hide add to timeline section in view note.... tbc
        // FIXME: Will adjust the folder background colour if note is attached to a folder or not, once we build that feature
        let hasFolder = false
        selectFolderButton.backgroundColor = state == .AddNote ? AppColours.disabledGray : (hasFolder ? AppColours.appBlueLight : .white)
        let titleText = state == .AddNote ? "Select" : (hasFolder ? "Title Of Folder here" : "None")
        selectFolderButton.setTitle(titleText, for: .normal)
    }
    
    private func formatDate(for note: PostNote?) {
        guard let date = note?.journalDate else {
            datePickerTextField.text = "Today"
            return
        }
        if date == Date().yearMonthDayString {
            datePickerTextField.text = "Today"
        } else {
            datePickerTextField.text = date
        }
    }
    
    private func formatDateInViewMode(for note: PostNote?, state: NoteVCCellState) {
        guard state == .ViewNote else { return }
        guard let date = note?.journalDate else {
            createdDateValueLabel.text = "Unknown"
            return
        }
        createdDateValueLabel.text = Date.Formatter.yearMonthDay.date(from: date)?.yearMonthStringDayString ?? date
        
    }
    
    private func addDatePicker() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        datePicker = UIDatePicker()
        // Note, if we want to restrict the date to nothing in the future, uncomment below
//        datePicker?.maximumDate = Date()
        // bar button 'done'
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTapped))
        toolbar.setItems([doneButton], animated: true)
        
        datePickerTextField.inputAccessoryView = toolbar
        
        guard let datePicker = datePicker else { return }
        
        if Device.HasNotch {
            let containerView = UIView(frame: CGRect(x: 0, y: 0, width: window?.bounds.width ?? 300, height: 250))
            containerView.addSubview(datePicker)
            datePicker.addEqualSizeContraints(to: containerView, paddingBottom: 32)
            
            datePickerTextField.inputView = containerView
        } else {
            datePickerTextField.inputView = datePicker
        }
        
        // date picker mode
        datePicker.datePickerMode = .date
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        datePicker.addTarget(self, action: #selector(datePickerChanged(datePicker:)), for: .valueChanged)
    }
    
    @objc func doneButtonTapped() {
        if let datePicker = datePicker {
            adjustTextFieldWithDatePickerSpin(datePicker: datePicker)
        }
        self.datePickerTextField.resignFirstResponder()
        self.datePicker = nil
    }
    
    @objc func datePickerChanged(datePicker: UIDatePicker) {
        adjustTextFieldWithDatePickerSpin(datePicker: datePicker)
    }

    private func adjustTextFieldWithDatePickerSpin(datePicker: UIDatePicker) {
        var text = Date.Formatter.yearMonthDay.string(from: datePicker.date)
        let date = text
        if text == Date().yearMonthDayString {
            text = "Today"
        }
        self.datePickerTextField.text = text
        self.delegate?.datePickerChanged(date: date)
    }
    
    @IBAction private func selectFolderButtonTapped(_ sender: UIButton) {
        delegate?.selectFolderButtonTapped()
    }
    
    @IBAction private func addToMyTimelineInfoButtonTapped(_ sender: UIButton) {
        delegate?.addToTimelineInfoButtonTapped()
    }
    
    @IBAction private func addToTimelineSwitchValueChanged(_ sender: UISwitch) {
        delegate?.addToTimelineSwitchValueChanged(isOn: sender.isOn)
        switchVariableFormatting(isOn: sender.isOn)
    }
    
}
