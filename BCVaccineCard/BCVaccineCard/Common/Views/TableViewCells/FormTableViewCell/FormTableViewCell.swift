//
//  FormTableViewCell.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-09-16.
//

import UIKit

class FormTableViewCell: UITableViewCell {
    
    @IBOutlet weak var formTextFieldView: FormTextFieldView!

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(formType: FormTableViewCellField, delegateOwner: UIViewController) {
        formTextFieldView.configure(formType: formType, delegateOwner: delegateOwner)
    }
    
    
    // This is called when we have a regex error
//    private func adjustValidationError(error: String?) {
//        self.formTextFieldErrorLabel.isHidden = error == nil
//        self.formTextFieldErrorLabel.text = error
//    }
//
//    private func regexCheck(text: String?) -> Bool {
//        // TODO: Regex check here
//        guard let text = text else { return false }
//        // TODO: Apply regex to text
//        var validationError: String? = nil
//        adjustValidationError(error: validationError)
//        return validationError == nil
//    }
    
}

