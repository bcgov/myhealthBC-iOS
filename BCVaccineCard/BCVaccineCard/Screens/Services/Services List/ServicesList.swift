//
//  ServicesList.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2023-04-10.
//

import UIKit

class ServicesList: UIView {
    enum Rows: Int, CaseIterable {
        case OrganDonorRegistration = 0
    }
    
    // MARK: Outlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Variables
    var patient: Patient?
    var organDonorDelegate: OrganDonorDelegate?
    
    // MARK: Setup
    func setup(in container: UIView, for patient: Patient, organDonorDelegate: OrganDonorDelegate) {
        container.subviews.forEach({$0.removeFromSuperview()})
        container.addSubview(self)
        self.addEqualSizeContraints(to: container)
        self.patient = patient
        self.organDonorDelegate = organDonorDelegate
        setupTableView()
    }

}

// MARK: TableView
extension ServicesList: UITableViewDelegate, UITableViewDataSource {
    private func setupTableView() {
        tableView.register(UINib.init(nibName: OrganDonorServiceTableViewCell.getName, bundle: .main), forCellReuseIdentifier: OrganDonorServiceTableViewCell.getName)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Rows.allCases.count
    }
    
    func getOrganDonorCell(indexPath: IndexPath) -> OrganDonorServiceTableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: OrganDonorServiceTableViewCell.getName, for: indexPath) as? OrganDonorServiceTableViewCell else { return OrganDonorServiceTableViewCell() }
        return cell
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let row = Rows.init(rawValue: indexPath.row) else {
            return UITableViewCell()
        }
        
        switch row {
        case .OrganDonorRegistration:
            let cell = getOrganDonorCell(indexPath: indexPath)
            cell.setup(patient: patient, delegate: organDonorDelegate)
            return cell
        }
    }
}
