//
//  FormTableViewCell.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-09-16.
//

import UIKit

enum FormTableViewCellTextFieldType {
    case number, date
}

enum FormTableViewCellField {
    case personalHealthNumber, dateOfBirth, dateOfVaccination
    
    var getFieldTitle: String {
        switch self {
        case .personalHealthNumber: return Constants.Strings.MyCardFlow.Form.personalHealthNumber
        case .dateOfBirth: return Constants.Strings.MyCardFlow.Form.dateOfBirth
        case .dateOfVaccination: return Constants.Strings.MyCardFlow.Form.dateOfVaccine
        }
    }
    
    var getPlaceholderText: String {
        switch self {
        case .personalHealthNumber: return "973 7364 347"
        case .dateOfBirth: return "1967-01-21"
        case .dateOfVaccination: return "2021-01-02"
        }
    }
    
    var getImage: UIImage? {
        switch self {
        case .personalHealthNumber: return nil
        case .dateOfBirth: return #imageLiteral(resourceName: "calendar-icon")
        case .dateOfVaccination: return #imageLiteral(resourceName: "calendar-icon")
        }
    }
    
    var getFieldType: FormTableViewCellTextFieldType {
        switch self {
        case .personalHealthNumber: return .number
        case .dateOfBirth: return .date
        case .dateOfVaccination: return .date
        }
    }
}

protocol FormTableViewCellDelegate: AnyObject {
    // TODO: Add necessary form text field delegates here
    func doneEditing(formField: FormTableViewCellField, indexPath: IndexPath, text: String?, isDataValid: Bool)
    func textChanged(formField: FormTableViewCellField, text: String, indexPath: IndexPath)
}

class FormTableViewCell: UITableViewCell {
    
    @IBOutlet weak private var formTextFieldTitleLabel: UILabel!
    @IBOutlet weak private var formTextField: UITextField!
    @IBOutlet weak private var formTextFieldErrorLabel: UILabel!
    @IBOutlet weak private var formTextFieldRightImageView: UIImageView!
    
    weak var delegate: FormTableViewCellDelegate?
    private var formField: FormTableViewCellField!
    var datePicker = UIDatePicker()
    var indexPath: IndexPath!

    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }

//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        // Configure the view for the selected state
//    }
    
    private func setup() {
        // TODO: Implement this when we have error handling and validation
        formTextFieldErrorLabel.isHidden = true
        formTextField.delegate = self
        
        // TODO: Add font and colour setup here for components
    }
    
    func configure(formType: FormTableViewCellField, delegateOwner: UIViewController, indexPath: IndexPath) {
        self.indexPath = indexPath
        self.delegate = delegateOwner as? FormTableViewCellDelegate
        self.formField = formType
        formTextFieldRightImageView.isHidden = formType.getFieldType == .number
        formTextFieldTitleLabel.text = formType.getFieldTitle
        formTextField.placeholder = formType.getPlaceholderText
        if let image = formType.getImage {
            formTextFieldRightImageView.image = image
        }
        createKeyboardForType(type: formType.getFieldType)
    }
    
    private func createKeyboardForType(type: FormTableViewCellTextFieldType) {
        switch type {
        case .number:
            formTextField.keyboardType = .numberPad
            createKeyboardToolbar() // Need to test this, may need to delete
        case .date:
            createDatePicker()
        }
    }
    
    private func createKeyboardToolbar() {
        // toolbar
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        // bar button 'done'
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTapped))
        
        // add buttons to toolbar
        toolbar.setItems([doneButton], animated: true)
        
        // assign toolbar
        formTextField.inputAccessoryView = toolbar
    }
    
    private func createDatePicker() {
        createKeyboardToolbar()
        
        // assign date picker to text field
        formTextField.inputView = datePicker
        
        // date picker mode
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
    }
    
    @objc func doneButtonTapped() {
        doneButtonLogic()
        
    }
    
    private func doneButtonLogic() {
        if formField != .personalHealthNumber {
            let text = Date.Formatter.longDate.string(from: datePicker.date)
            self.formTextField.text = text
            self.delegate?.textChanged(formField: formField, text: text, indexPath: self.indexPath)
        }
        // NOTE: Need to consider case where user doesn't tap done and just taps another table view cell
        let isValidData = regexCheck(text: self.formTextField.text)
        self.delegate?.doneEditing(formField: self.formField, indexPath: self.indexPath, text: self.formTextField.text, isDataValid: isValidData)
    }
    
    // This is called from didSelectRow to open the keyboard
    func openKeyboardAction() {
        self.formTextField.becomeFirstResponder()
    }
    
    // This is called when we have a regex error
    private func adjustValidationError(error: String?) {
        self.formTextFieldErrorLabel.isHidden = error == nil
        self.formTextFieldErrorLabel.text = error
    }
    
    private func regexCheck(text: String?) -> Bool {
        // TODO: Regex check here
        guard let text = text else { return false }
        // TODO: Apply regex to text
        var validationError: String? = nil
        adjustValidationError(error: validationError)
        return validationError == nil
    }
    
}

extension FormTableViewCell: UITextFieldDelegate {
    
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        if formField == .personalHealthNumber {
//            let currentString: NSString = textField.text! as NSString
//            let newString: String = currentString.replacingCharacters(in: range, with: string) as String
//            self.delegate?.textChanged(formField: formField, text: newString, indexPath: self.indexPath)
//        }
//        return true
//    }
    
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        self.delegate?.doneTapped(formField: formField)
//        return true
//    }
}
