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
    
    @IBOutlet private weak var addToMyTimelineLabel: UILabel!
    @IBOutlet private weak var addToMyTimelineInfoButton: UIButton!
    @IBOutlet private weak var datePickerTextField: UITextField!
    @IBOutlet private weak var addToTimelineSwitch: UISwitch!
    @IBOutlet private weak var bottomSeparatorView: UIView!
    
    private weak var delegate: AddToTimelineTableViewCellDelegate?

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
        selectFolderButton.titleLabel?.textColor = AppColours.textBlack
        addToMyTimelineLabel.font = UIFont.bcSansRegularWithSize(size: 15)
        addToMyTimelineLabel.textColor = AppColours.textGray
        addToMyTimelineLabel.text = "Add to my Timeline"
        datePickerTextField.font = UIFont.bcSansRegularWithSize(size: 15)
        datePickerTextField.textColor = AppColours.blueLightText
        datePickerTextField.borderStyle = .none
        datePickerTextField.backgroundColor = .white
        bottomSeparatorView.backgroundColor = AppColours.borderGray
        switchFormatting(isOn: false)
    }
    
    private func switchFormatting(isOn: Bool) {
        // TODO: Update this accordingly
        // Will likely have to dynamically update
        addToTimelineSwitch.onTintColor = AppColours.appBlue
        addToTimelineSwitch.tintColor = .white
        addToTimelineSwitch.layer.borderColor = AppColours.appBlue.cgColor
        addToTimelineSwitch.thumbTintColor = AppColours.appRed
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
    }
    
    private func formatForState(state: NoteVCCellState) {
        createdStackView.isHidden = state == .AddNote
        datePickerTextField.isUserInteractionEnabled = !(state == .ViewNote)
        selectFolderButton.isUserInteractionEnabled = !(state == .ViewNote)
        addToTimelineSwitch.isUserInteractionEnabled = !(state == .ViewNote)
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
    
    private func addDatePicker() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        // bar button 'done'
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTapped))
        toolbar.setItems([doneButton], animated: true)
        
        datePickerTextField.inputAccessoryView = toolbar
        
        let datePicker = UIDatePicker()
        
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
        self.resignFirstResponder()
    }
    
    @objc func datePickerChanged(datePicker: UIDatePicker) {
        adjustTextFieldWithDatePickerSpin(datePicker: datePicker)
    }

    private func adjustTextFieldWithDatePickerSpin(datePicker: UIDatePicker) {
        let text = Date.Formatter.yearMonthDay.string(from: datePicker.date)
        self.datePickerTextField.text = text
        self.delegate?.datePickerChanged(date: text)
    }
    
    @IBAction private func selectFolderButtonTapped(_ sender: UIButton) {
        delegate?.selectFolderButtonTapped()
    }
    
    @IBAction private func addToMyTimelineInfoButtonTapped(_ sender: UIButton) {
        delegate?.addToTimelineInfoButtonTapped()
    }
    
    @IBAction private func addToTimelineSwitchValueChanged(_ sender: UISwitch) {
        delegate?.addToTimelineSwitchValueChanged(isOn: sender.isOn)
    }
    
}
