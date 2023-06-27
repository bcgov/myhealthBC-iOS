//
//  ImmunizationScheduleTableViewCell.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2023-06-26.
//

import UIKit

protocol ImmunizationScheduleTableViewCellDelegate {
    func tapped(type: ImmunizationScheduleViewController.ScheduleType)
}

class ImmunizationScheduleTableViewCell: UITableViewCell {
    
    @IBOutlet weak var openButton: UIButton!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    
    private var delegate: ImmunizationScheduleTableViewCellDelegate?
    private var type: ImmunizationScheduleViewController.ScheduleType?

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setup(type: ImmunizationScheduleViewController.ScheduleType,
               delegate: ImmunizationScheduleTableViewCellDelegate)
    {
        self.delegate = delegate
        self.type = type
    }
    
    func fillData() {
        guard let type = self.type else {
            return
        }
        iconImageView.image = UIImage(named: type.imageName())
        label.text = type.title()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTap))
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(tapGesture)
        openButton.addGestureRecognizer(tapGesture)
    }
    
    @objc func onTap(sender : UITapGestureRecognizer) {
        guard let type = self.type, let delegate = self.delegate else {return}
        delegate.tapped(type: type)
    }
    
    
}
