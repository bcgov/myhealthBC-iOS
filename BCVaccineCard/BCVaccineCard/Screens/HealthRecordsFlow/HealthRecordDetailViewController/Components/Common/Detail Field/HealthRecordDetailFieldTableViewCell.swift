//
//  HealthRecordDetailFieldTableViewCell.swift
//  HealthGatewayTest
//
//  Created by Amir on 2022-06-29.
//

import UIKit

// TODO: Use TextListModel


class HealthRecordDetailFieldTableViewCell: UITableViewCell {
    
    @IBOutlet weak var headerLabel: InteractiveLinkLabel!
    @IBOutlet weak var valueLabel: InteractiveLinkLabel!
    
    func setup(with model: TextListModel) {
        self.layoutIfNeeded()
        headerLabel.attributedText =
        headerLabel.attributedText(
            withString: model.header.text,
            linkedStrings: model.header.links ?? [],
            textColor: model.header.textColor.getUIColor,
            font: model.header.bolded ? UIFont.bcSansBoldWithSize(size: model.header.fontSize) : UIFont.bcSansRegularWithSize(size: model.header.fontSize)
        )
        guard let subtext = model.subtext else {
            valueLabel.isHidden = true
            return
        }
        valueLabel.isHidden = false
        valueLabel.attributedText =
        valueLabel.attributedText(
            withString: subtext.text,
            linkedStrings: subtext.links ?? [],
            textColor: subtext.textColor.getUIColor,
            font: subtext.bolded ? UIFont.bcSansBoldWithSize(size: subtext.fontSize) : UIFont.bcSansRegularWithSize(size: subtext.fontSize)
        )
        self.layoutIfNeeded()
    }
    
}
