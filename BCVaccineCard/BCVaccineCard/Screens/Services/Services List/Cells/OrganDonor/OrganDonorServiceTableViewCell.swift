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

class OrganDonorServiceTableViewCell: UITableViewCell {

    // MARK: Outlets
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var statusTitleLabel: UILabel!
    @IBOutlet weak var statusValueLabel: UILabel!
    @IBOutlet weak var descriptiveText: UILabel!
    @IBOutlet weak var notAvailableLabel: UILabel!
    @IBOutlet weak var downloadButton: UIButton!
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
        self.patient = patient
        self.delegate = delegate
    }
    
}
