//
//  FormTableViewCell.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-09-16.
//

import UIKit

// TODO: Figure out setup of table view cell with different text field type

enum FormTableViewCellTextFieldType {
    case number, date
    
//    var getTextFieldFormat: Formatter {
//        switch self {
//        case .number:
//        case . date
//        }
//    }
}

enum FormTableViewCellType {
    case personalHealthNumber, dateOfBirth, dateOfVaccination
    
    var getFieldTitle: String {
        switch self {
        case .personalHealthNumber: return "Personal Health Number"
        case .dateOfBirth: return "Date of birth"
        case .dateOfVaccination: return "Date of vaccination (Dose 1 or Dose 2)"
        }
    }
    
    var getPlaceholderText: String {
        switch self {
        case .personalHealthNumber: return "973 7364 347"
        case .dateOfBirth: return "1967-01-21"
        case .dateOfVaccination: return "2021-01-02"
        }
    }
}

class FormTableViewCell: UITableViewCell {
    
    @IBOutlet weak private var formTextFieldTitleLabel: UILabel!
    @IBOutlet weak private var formTextField: UITextField!
    @IBOutlet weak private var formTextFieldErrorLabel: UILabel!
    @IBOutlet weak private var formTextFieldRightButton: UIButton! // Note: This may just be an image if functionality is adjusted

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    private func setup() {
        
    }
    
    func configure(textFieldType: FormTableViewCellTextFieldType, cellType: FormTableViewCellType) {
        formTextFieldRightButton.isHidden = textFieldType == .number
        formTextFieldTitleLabel.text = cellType.getFieldTitle
        formTextField.placeholder = cellType.getPlaceholderText
    }
    
}
