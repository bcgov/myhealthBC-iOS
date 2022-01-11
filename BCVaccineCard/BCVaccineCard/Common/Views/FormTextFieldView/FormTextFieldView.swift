//
//  FormTextFieldView.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-09-17.
//

import UIKit
// TODO: Need to set minimum and maximum dates for date picker
enum FormTextFieldKeyboardStyle {
    case number, date
}

enum FormTextFieldType {
    case personalHealthNumber, dateOfBirth, dateOfVaccination, dateOfTest
    
    var getFieldTitle: String {
        switch self {
        case .personalHealthNumber: return .personalHealthNumber
        case .dateOfBirth: return .dateOfBirth
        case .dateOfVaccination: return .dateOfVaccine
        case .dateOfTest: return .dateOfTest
        }
    }
    // Leaving this for now, even though we currently aren't using, as designs keep changing
    var getFieldSubtitle: String? {
        switch self {
        case .personalHealthNumber: return nil
        case .dateOfBirth: return nil
        case .dateOfVaccination: return nil
        case .dateOfTest: return nil
        }
    }
    
    var getFieldFooter: String? {
        switch self {
        case .personalHealthNumber: return .phnFooter
        case .dateOfBirth: return nil
        case .dateOfVaccination: return nil
        case .dateOfTest: return nil
        }
    }
    
    var getPlaceholderText: String {
        switch self {
        case .personalHealthNumber: return "xxxx xxx xxx"
        case .dateOfBirth: return "yyyy-mm-dd"
        case .dateOfVaccination: return "yyyy-mm-dd"
        case .dateOfTest: return "yyyy-mm-dd"
        }
    }
    
    var getPlaceholderAccessibilityText: String {
        switch self {
        case .personalHealthNumber: return AccessibilityLabels.FormTextField.numberFormat
        case .dateOfBirth: return AccessibilityLabels.FormTextField.dateFormat
        case .dateOfVaccination: return AccessibilityLabels.FormTextField.dateFormat
        case .dateOfTest: return AccessibilityLabels.FormTextField.dateFormat
        }
    }
    
    var getImage: UIImage? {
        switch self {
        case .personalHealthNumber: return #imageLiteral(resourceName: "dropdown-arrow")
        case .dateOfBirth: return #imageLiteral(resourceName: "calendar-icon")
        case .dateOfVaccination: return #imageLiteral(resourceName: "calendar-icon")
        case .dateOfTest: return #imageLiteral(resourceName: "calendar-icon")
        }
    }
    
    var isRightButtonClickable: Bool {
        switch self {
        case .personalHealthNumber: return true
        case .dateOfBirth: return false
        case .dateOfVaccination: return false
        case .dateOfTest: return false
        }
    }
    
    var getFieldType: FormTextFieldKeyboardStyle {
        switch self {
        case .personalHealthNumber: return .number
        case .dateOfBirth: return .date
        case .dateOfVaccination: return .date
        case .dateOfTest: return .date
        }
    }
    
    func setErrorValidationMessage(text: String) -> String? {
        switch self {
        case .personalHealthNumber:
            guard text.trimWhiteSpacesAndNewLines.count > 0 else { return .phnRequired }
            guard text.isValidNumber else { return .phnNumber }
            guard text.removeWhiteSpaceFormatting.isValidLength(length: 10) else { return .phnLength }
            return nil
        case .dateOfBirth:
            guard text.trimWhiteSpacesAndNewLines.count > 0 else { return .dobRequired }
            guard text.isValidDate(withFormatter: Date.Formatter.yearMonthDay) else { return .validDate }
            guard text.isValidDateRange(withFormatter: Date.Formatter.yearMonthDay, latestDate: Date()) else { return .dobRange }
            return nil
        case .dateOfVaccination:
            guard text.trimWhiteSpacesAndNewLines.count > 0 else { return .dovRequired }
            guard text.isValidDate(withFormatter: Date.Formatter.yearMonthDay) else { return .validDate }
            guard text.isValidDateRange(withFormatter: Date.Formatter.yearMonthDay, earliestDate: Constants.DateConstants.firstVaxDate, latestDate: Date()) else { return .dovRange }
            return nil
        case .dateOfTest:
            guard text.trimWhiteSpacesAndNewLines.count > 0 else { return .dotRequired }
            guard text.isValidDate(withFormatter: Date.Formatter.yearMonthDay) else { return .validDate }
            guard text.isValidDateRange(withFormatter: Date.Formatter.yearMonthDay, earliestDate: Constants.DateConstants.firstTestDate, latestDate: Date()) else { return .dotRange }
            return nil
        }
    }
}

protocol FormTextFieldViewDelegate: AnyObject {
    func didFinishEditing(formField: FormTextFieldType, text: String?)
    func textFieldTextDidChange(formField: FormTextFieldType, newText: String)
    func resignFirstResponderUI(formField: FormTextFieldType)
    func goToNextFormTextField(formField: FormTextFieldType)
    func rightTextFieldButtonTapped(formField: FormTextFieldType)
    func resizeForm(formField: FormTextFieldType)
}
// NOTE: Date Formatter is of type longType
class FormTextFieldView: UIView {
    
    @IBOutlet weak private var contentView: UIView!
    @IBOutlet weak private var formTextFieldTitleLabel: UILabel!
    @IBOutlet weak private var formTextFieldSubtitleLabel: UILabel!
    @IBOutlet weak private var formTextField: UITextField!
    @IBOutlet weak private var formTextFieldErrorLabel: UILabel!
    @IBOutlet weak private var formTextFieldFooterLabel: UILabel!
    @IBOutlet weak private var formTextFieldRightButton: LargerTouchAreaButton!
    
    weak var delegate: FormTextFieldViewDelegate?
    private var formField: FormTextFieldType!
    // Set this from view controller
    var validationError: String? = nil {
        didSet {
            self.showValidationMessage(message: validationError)
            self.delegate?.resizeForm(formField: self.formField)
            self.formTextField.accessibilityHint = validationError == nil ? AccessibilityLabels.FormTextField.required : validationError
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed(FormTextFieldView.getName, owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        setup()
    }
    
    private func setup() {
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .white
        setupUI()
        baseSetup()
    }
    
    private func setupUI() {
        formTextField.textColor = AppColours.textBlack
        formTextFieldTitleLabel.textColor = AppColours.textBlack
        formTextFieldTitleLabel.font = UIFont.bcSansBoldWithSize(size: 17)
        formTextFieldSubtitleLabel.textColor = AppColours.textGray
        formTextFieldSubtitleLabel.font = UIFont.bcSansRegularWithSize(size: 15)
        formTextFieldErrorLabel.textColor = AppColours.appRed
        formTextFieldErrorLabel.font = UIFont.bcSansItalicWithSize(size: 13)
        formTextFieldFooterLabel.textColor = AppColours.lightGray
        formTextFieldFooterLabel.font = UIFont.bcSansItalicWithSize(size: 13)
        formTextFieldTitleLabel.isAccessibilityElement = false
        formTextFieldSubtitleLabel.isAccessibilityElement = false
        formTextFieldErrorLabel.isAccessibilityElement = false
        formTextFieldFooterLabel.isAccessibilityElement = false
        formTextFieldRightButton.isAccessibilityElement = false
    }
    
    private func baseSetup() {
        formTextFieldErrorLabel.isHidden = true
    }
    
    func configure(formType: FormTextFieldType, delegateOwner: UIViewController, rememberedDetails: RememberedGatewayDetails, text: String?) {
        self.delegate = delegateOwner as? FormTextFieldViewDelegate
        self.formField = formType
        formTextFieldRightButton.isUserInteractionEnabled = formType.isRightButtonClickable
        formTextFieldRightButton.isHidden = (formType.getFieldType == .number) && (rememberedDetails.storageArray == nil || rememberedDetails.storageArray?.count == 0)
        formTextFieldTitleLabel.text = formType.getFieldTitle
        formTextFieldSubtitleLabel.isHidden = formType.getFieldSubtitle == nil
        formTextFieldSubtitleLabel.text = formType.getFieldSubtitle
        formTextFieldFooterLabel.isHidden = formType.getFieldFooter == nil
        formTextFieldFooterLabel.text = formType.getFieldFooter
        formTextField.placeholder = formType.getPlaceholderText
        if let text = text {
            formTextField.text = text
        }
        if let image = formType.getImage {
            formTextFieldRightButton.setImage(image, for: .normal)
        }
        createKeyboardForType(type: formType.getFieldType, formField: formType)
        formTextField.delegate = self
        setupAccessibility(formType: formType)
    }
    
    private func setupAccessibility(formType: FormTextFieldType) {
        self.formTextField.isAccessibilityElement = true
        self.formTextField.accessibilityLabel = formType.getFieldTitle + " " + (formType.getFieldSubtitle ?? "")
        self.formTextField.accessibilityValue = formType.getPlaceholderAccessibilityText
        self.formTextField.accessibilityHint = AccessibilityLabels.FormTextField.required
    }
    
    // This is called from didSelectRow to open the keyboard
    func openKeyboardAction() {
        self.formTextField.becomeFirstResponder()
    }
    
    @IBAction func textFieldRightButtonTapped(_ sender: UIButton) {
        self.delegate?.rightTextFieldButtonTapped(formField: self.formField)
    }
    
}

// MARK: Date picker logic
extension FormTextFieldView {
    
    private func createKeyboardForType(type: FormTextFieldKeyboardStyle, formField: FormTextFieldType) {
        switch type {
        case .number:
            formTextField.keyboardType = .numberPad
            createKeyboardToolbar()
        case .date:
            let datePicker = UIDatePicker()
            createDatePicker(datePicker: datePicker, formField: formField)
        }
    }
    
    private func createKeyboardToolbar() {
        // toolbar
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        // bar button 'done'
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTapped))
        
        // bar button 'next
        let nextButton = UIBarButtonItem(title: .next, style: .done, target: self, action: #selector(nextButtonTapped))
        
        // spacer between buttons
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        // add buttons to toolbar
        toolbar.setItems([doneButton, spacer, nextButton], animated: true)
        
        // assign toolbar
        formTextField.inputAccessoryView = toolbar
    }
    
    private func createDatePicker(datePicker: UIDatePicker, formField: FormTextFieldType) {
        createKeyboardToolbar()
        
        // assign date picker to text field
        formTextField.inputView = datePicker
        
        // date picker mode
        datePicker.datePickerMode = .date
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        datePicker.addTarget(self, action: #selector(datePickerChanged(datePicker:)), for: .valueChanged)
        
        // date picker min and max values
        datePicker.maximumDate = Date()
        if formField == .dateOfVaccination {
            datePicker.minimumDate = Constants.DateConstants.firstVaxDate
        }
    }
    
    @objc func doneButtonTapped() {
        delegate?.resignFirstResponderUI(formField: self.formField)
    }
    
    @objc func nextButtonTapped() {
        delegate?.goToNextFormTextField(formField: self.formField)
    }
    
    @objc func datePickerChanged(datePicker: UIDatePicker) {
        adjustTextFieldWithDatePickerSpin(datePicker: datePicker)
    }

    private func adjustTextFieldWithDatePickerSpin(datePicker: UIDatePicker) {
        let text = Date.Formatter.yearMonthDay.string(from: datePicker.date)
        self.formTextField.text = text
        self.delegate?.textFieldTextDidChange(formField: self.formField, newText: text)
    }
}

// MARK: Basic text field logic
extension FormTextFieldView: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if formField == .personalHealthNumber {
            var fullString = textField.text ?? ""
                fullString.append(string)
                if range.length == 1 {
                    textField.text = format(phn: fullString, shouldRemoveLastDigit: true)
                } else {
                    textField.text = format(phn: fullString)
                }
            let newString = textField.text ?? ""
            self.delegate?.textFieldTextDidChange(formField: self.formField, newText: newString)
                return false
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.delegate?.didFinishEditing(formField: self.formField, text: textField.text)
        guard let text = textField.text else {
            self.validationError = nil
            return
        }
        self.validationError = formField.setErrorValidationMessage(text: text)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
}

// MARK: Formatting for UITextField PHN
extension FormTextFieldView {
    func format(phn: String, shouldRemoveLastDigit: Bool = false) -> String {
        guard !phn.isEmpty else { return "" }
        guard let regex = try? NSRegularExpression(pattern: "[\\s-\\(\\)]", options: .caseInsensitive) else { return "" }
        let r = NSString(string: phn).range(of: phn)
        var number = regex.stringByReplacingMatches(in: phn, options: .init(rawValue: 0), range: r, withTemplate: "")

        if number.count > 10 {
            let tenthDigitIndex = number.index(number.startIndex, offsetBy: 10)
            number = String(number[number.startIndex..<tenthDigitIndex])
        }

        if shouldRemoveLastDigit {
            let end = number.index(number.startIndex, offsetBy: number.count-1)
            number = String(number[number.startIndex..<end])
        }

        if number.count < 8 {
            let end = number.index(number.startIndex, offsetBy: number.count)
            let range = number.startIndex..<end
            number = number.replacingOccurrences(of: "(\\d{4})(\\d+)", with: "$1 $2", options: .regularExpression, range: range)

        } else {
            let end = number.index(number.startIndex, offsetBy: number.count)
            let range = number.startIndex..<end
            number = number.replacingOccurrences(of: "(\\d{4})(\\d{3})(\\d+)", with: "$1 $2 $3", options: .regularExpression, range: range)
        }

        return number
    }
}

// MARK: TextField Validation Error Message Handling
extension FormTextFieldView {
    private func showValidationMessage(message: String?) {
        formTextFieldErrorLabel.isHidden = message == nil
        guard let message = message else { return }
        formTextFieldErrorLabel.text = message
    }
}
