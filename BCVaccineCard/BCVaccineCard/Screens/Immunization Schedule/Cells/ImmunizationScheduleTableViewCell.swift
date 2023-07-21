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

class ImmunizationScheduleTableViewCell: UITableViewCell, Theme {
    
    @IBOutlet weak var container: UIView!
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
        fillData()
        style()
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
        let btnGesture = UITapGestureRecognizer(target: self, action: #selector(onTap))
        openButton.addGestureRecognizer(btnGesture)
    }
    
    func style() {
        container.layer.masksToBounds = true
        container.layer.cornerRadius = 4
        label.font = UIFont.bcSansBoldWithSize(size: 15)
        container.layer.backgroundColor = UIColor.white.cgColor
        container.layer.shadowColor = UIColor.gray.cgColor
        container.layer.shadowOffset = CGSize(width: 1.0, height: 2.0)
        container.layer.shadowRadius = 4.0
        container.layer.shadowOpacity = 0.3
        container.layer.masksToBounds = false
    }
    
    @objc func onTap(sender : UITapGestureRecognizer) {
        guard let type = self.type, let delegate = self.delegate else {return}
        delegate.tapped(type: type)
    }
    
    
}
