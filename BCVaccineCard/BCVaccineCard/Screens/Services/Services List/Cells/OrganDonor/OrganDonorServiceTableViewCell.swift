//
//  OrganDonorServiceTableViewCell.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2023-04-10.
//

import UIKit

protocol OrganDonorDelegate {
    func download(patient: Patient)
    func registerOrUpdate(patient: Patient)
}

class OrganDonorServiceTableViewCell: UITableViewCell, Theme {

    // MARK: Outlets
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var boxContainer: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var statusTitleLabel: UILabel!
    @IBOutlet weak var statusValueLabel: UILabel!
    @IBOutlet weak var descriptiveText: UILabel!
    @IBOutlet weak var notAvailableLabel: UILabel!
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var decisionLabel: UILabel!
    @IBOutlet weak var registerOrUpdateButton: UIButton!
    
    // MARK: Variables
    var delegate: OrganDonorDelegate?
    var patient: Patient?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    @IBAction func downloadAction(_ sender: Any) {
        guard let patient = patient, let delegate = delegate else {return}
        delegate.download(patient: patient)
    }
    
    @IBAction func updateOrRegisterAction(_ sender: Any) {
        guard let patient = patient, let delegate = delegate else {return}
        delegate.registerOrUpdate(patient: patient)
    }
    
    func setup(patient: Patient?, delegate: OrganDonorDelegate?) {
        style()
        self.patient = patient
        self.delegate = delegate
        if let statusModel = patient?.organDonorStatus,
           let statusString = statusModel.status,
           statusString.lowercased() == "registered"
        {
            styleRegistered()
        } else {
            styleNotRegistered()
        }
    }
    
    func styleRegistered() {
        notAvailableLabel.isHidden = true
        statusValueLabel.text = "Registered"
        descriptiveText.text = "You can update your registration on BC Transplant website"
    }
    
    func styleNotRegistered() {
        downloadButton.isHidden = true
        statusValueLabel.text = "Not Registered"
        descriptiveText.text = "We do not have a record of your decision about organ donation. If you filled out a paper registration form, we may not have processed it yet. You can also register your decision online now."
    }
    
    func style() {
        shadowView.backgroundColor = UIColor.clear
        shadowView.layer.shadowColor = UIColor.black.cgColor
        shadowView.layer.shadowOffset = CGSize(width: 2, height: 2)
        shadowView.layer.shadowOpacity = 0.20
        shadowView.layer.shadowRadius = 6.0
        
        boxContainer.layer.cornerRadius = 4
        boxContainer.layer.masksToBounds = true
        
        iconImageView.image = UIImage(named: "ogran-donor-logo")
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        statusValueLabel.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        notAvailableLabel.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        statusTitleLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        statusTitleLabel.textColor = AppColours.darkGreyText
        decisionLabel.textColor = AppColours.darkGreyText
        decisionLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        descriptiveText.font = UIFont.systemFont(ofSize: 13)
        descriptiveText.textColor = AppColours.greyText
        style(button: downloadButton, style: .Hollow, title: "Download", image: UIImage(named: "download"))
    }
    
}
