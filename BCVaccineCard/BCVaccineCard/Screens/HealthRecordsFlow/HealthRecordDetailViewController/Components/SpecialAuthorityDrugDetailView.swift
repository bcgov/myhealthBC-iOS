//
//  SpecialAuthorityDrugDetailView.swift
//  BCVaccineCard
//
//  Created by Amir on 2022-07-12.
//

import UIKit

extension HealthRecordsDetailDataSource.Record {
    fileprivate func specialAuthorityDrug() -> SpecialAuthorityDrug? {
        switch self.type {
        case .specialAuthorityDrug(model: let model):
            return model
        default:
            return nil
        }
    }
}

class SpecialAuthorityDrugDetailView: BaseHealthRecordsDetailView, UITableViewDelegate, UITableViewDataSource {
    
    private var fields: [TextListModel] = []

    override func setup() {
        tableView?.dataSource = self
        tableView?.delegate = self
        fields = createFields()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fields.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = textCell(indexPath: indexPath, tableView: tableView) else {return UITableViewCell()}
        cell.setup(with: fields[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard section != 0 else {return nil}
        return separatorView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard section != 0 else {return 0}
        return separatorHeight + separatorBottomSpace
    }
    
}

extension SpecialAuthorityDrugDetailView {
    
    private func createFields() -> [TextListModel] {
        guard let model = model, let object = model.specialAuthorityDrug() else {return []}
        var effectiveDate = ""
        if let date = object.effectiveDate {
            effectiveDate = date.issuedOnDate
        }
        
        var expiryDate = ""
        if let date = object.expiryDate {
            expiryDate = date.issuedOnDate
        }
        let prescriberFirstName = object.prescriberFirstName ?? ""
        let prescriberLastName = object.prescriberLastName ?? ""
        let fields: [TextListModel] = [
            TextListModel(
                header: TextProperties(
                    text: "Status:",
                    bolded: true),
                subtext: TextProperties(
                    text: object.requestStatus ?? "",
                    bolded: false)),
            TextListModel(
                header: TextProperties(
                    text: "Prescriber Name:",
                    bolded: true),
                subtext: TextProperties(
                    text: "\(prescriberFirstName) \(prescriberLastName)",
                    bolded: false)),
            TextListModel(
                header: TextProperties(
                    text: "Effective Date:",
                    bolded: true),
                subtext: TextProperties(
                    text: effectiveDate,
                    bolded: false)),
            TextListModel(
                header: TextProperties(
                    text: "Expiry Date:",
                    bolded: true),
                subtext: TextProperties(
                    text: expiryDate,
                    bolded: false)),
            TextListModel(
                header: TextProperties(
                    text: "Reference Number:",
                    bolded: true),
                subtext: TextProperties(
                    text: object.referenceNumber ?? "",
                    bolded: false)),
        ]
       
        return fields
    }
}
