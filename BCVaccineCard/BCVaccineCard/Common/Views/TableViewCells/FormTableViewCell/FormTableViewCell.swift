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
    
    func configure(formType: FormTextFieldType, delegateOwner: UIViewController, rememberedDetails: RememberedGatewayDetails) {
        formTextFieldView.configure(formType: formType, delegateOwner: delegateOwner, rememberedDetails: rememberedDetails)
    }
}

