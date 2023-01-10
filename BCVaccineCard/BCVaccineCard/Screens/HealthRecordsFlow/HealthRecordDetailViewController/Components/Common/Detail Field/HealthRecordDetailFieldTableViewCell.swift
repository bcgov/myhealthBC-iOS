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
    @IBOutlet weak var thirdLine: InteractiveLinkLabel!
    
    func setup(with model: TextListModel) {
        self.layoutIfNeeded()
        setHeader(with: model)
        setValue(with: model)
        setThirdLine(with: model)
        self.layoutIfNeeded()
    }
    
    func setHeader(with model: TextListModel) {
        headerLabel.attributedText =
        headerLabel.attributedText(
            withString: model.header.text,
            linkedStrings: model.header.links ?? [],
            textColor: model.header.textColor.getUIColor,
            font: model.header.font
        )
        self.layoutIfNeeded()
    }
    
    func setValue(with model: TextListModel) {
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
            font: subtext.font
        )
        self.layoutIfNeeded()
    }
    
    func setThirdLine(with model: TextListModel) {
        guard let subtext = model.thirdLine else {
            thirdLine.isHidden = true
            return
        }
        thirdLine.attributedText =
        thirdLine.attributedText(
            withString: subtext.text,
            linkedStrings: subtext.links ?? [],
            textColor: subtext.textColor.getUIColor,
            font: subtext.font
        )
    }
    
}
