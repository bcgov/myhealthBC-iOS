//
//  ImmunizationRecordDetailView.swift
//  BCVaccineCard
//
//  Created by Amir on 2022-07-07.
//

import UIKit


extension HealthRecordsDetailDataSource.Record {
    fileprivate func immunization() -> Immunization? {
        switch self.type {
        case .immunization(model: let model):
            return model
        default:
            return nil
        }
    }
}

class ImmunizationRecordDetailView: BaseHealthRecordsDetailView, UITableViewDelegate, UITableViewDataSource {
    
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

extension ImmunizationRecordDetailView {
    
    private func createFields() -> [TextListModel] {
        guard let model = model, let immunization = model.immunization() else {return []}
        var stringDate = ""
        if let date = immunization.dateOfImmunization {
            stringDate = date.issuedOnDate
        }
        var fields: [TextListModel] = [
            TextListModel(
                header: TextProperties(
                    text: "Date:",
                    bolded: true),
                subtext: TextProperties(
                    text: stringDate,
                    bolded: false)),
            TextListModel(
                header: TextProperties(
                    text: "Provider / Clinic:",
                    bolded: true),
                subtext: TextProperties(
                    text: immunization.providerOrClinic ?? "--",
                    bolded: false))
        ]
        if let agents = immunization.immunizationDetails?.agents {
            for agent in agents {
                fields.append(
                    TextListModel(
                        header: TextProperties(
                            text: "Product:",
                            bolded: true),
                        subtext: TextProperties(
                            text: agent.productName ?? "--",
                            bolded: false))
                )
                fields.append(
                    TextListModel(
                        header: TextProperties(
                            text: "Lot number:",
                            bolded: true),
                        subtext: TextProperties(
                            text: agent.lotNumber ?? "--",
                            bolded: false))
                )
            }
        } else {
            // Agents
            fields.append(
                TextListModel(
                    header: TextProperties(
                        text: "Lot number:",
                        bolded: true),
                    subtext: TextProperties(
                        text: "--",
                        bolded: false))
            )
        }
        
       
        return fields
    }
}
