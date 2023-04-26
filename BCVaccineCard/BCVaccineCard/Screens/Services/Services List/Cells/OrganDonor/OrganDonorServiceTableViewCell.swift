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
    func reload(patient: Patient)
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
    @IBOutlet weak var reloadButton: UIButton!
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
    @IBAction func reloadAction(_ sender: Any) {
        guard let patient = patient, let delegate = delegate else {return}
        delegate.reload(patient: patient)
    }
    
    @IBAction func updateOrRegisterAction(_ sender: Any) {
        guard let patient = patient, let delegate = delegate else {return}
        delegate.registerOrUpdate(patient: patient)
    }
    
    func setup(patient: Patient?, delegate: OrganDonorDelegate?) {
        style()
        self.patient = patient
        self.delegate = delegate
        if let statusModel = patient?.organDonorStatus{
            reloadButton.isHidden = true
            if let statusString = statusModel.status,
               statusString.lowercased() == "registered"
            {
                notAvailableLabel.isHidden = true
                downloadButton.isHidden = false
            } else {
                notAvailableLabel.isHidden = false
                downloadButton.isHidden = true
            }
            statusValueLabel.text = statusModel.status
            descriptiveText.text = statusModel.statusMessage
        } else {
            // No DATA - API FETCH ERROR
            statusValueLabel.text = "Error"
            descriptiveText.text = "Not Available"
            notAvailableLabel.isHidden = true
            downloadButton.isHidden = true
            reloadButton.isHidden = true
        }
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
        style(button: reloadButton, style: .Hollow, title: "Reload", image: UIImage(named: "refresh"))
        
        let registerOrUpdateButtonAttributes: [NSAttributedString.Key: Any] = [
              .font: UIFont.bcSansBoldWithSize(size: 14),
              .foregroundColor: AppColours.appBlue,
              .underlineStyle: NSUnderlineStyle.single.rawValue
          ]
        let registerOrUpdateButtonTitle = NSMutableAttributedString(
                string: "Register or update your decision",
                attributes: registerOrUpdateButtonAttributes
             )
        registerOrUpdateButton.setAttributedTitle(registerOrUpdateButtonTitle, for: .normal)
    }
    
}
