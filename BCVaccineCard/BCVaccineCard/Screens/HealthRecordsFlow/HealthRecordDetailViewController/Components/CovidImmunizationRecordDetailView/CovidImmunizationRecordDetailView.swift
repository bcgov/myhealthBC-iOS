//
//  ImmunizationRecordDetailView.swift
//  HealthGatewayTest
//
//  Created by Amir on 2022-06-22.
//

import UIKit


extension HealthRecordsDetailDataSource.Record {
    fileprivate func covidImmunization() -> LocallyStoredVaccinePassportModel? {
        switch self.type {
        case .covidImmunizationRecord(model: let model, immunizations: _):
            return model
        default:
            return nil
        }
    }
    
    fileprivate func covidImmunizations() -> [CovidImmunizationRecord]? {
        switch self.type {
        case .covidImmunizationRecord(model: _, immunizations: let imms):
            return imms
        default:
            return nil
        }
    }
}

class CovidImmunizationRecordDetailView: BaseHealthRecordsDetailView, UITableViewDelegate, UITableViewDataSource {
    
    private var fields: [[TextListModel]] = [[]]

    override func setup() {
        tableView?.dataSource = self
        tableView?.delegate = self
        fields = createFields()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return fields.count + 1 // Immunization dose sets + header
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1 // Hedaer section
       default:
            return fields[section - 1].count // Immunizations
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let model = self.model, let immunizationModel = model.covidImmunization() else {return UITableViewCell()}
        switch indexPath.section {
        case 0:
            guard let cell = CovidImmunizationBannerCell(indexPath: indexPath, tableView: tableView) else {return UITableViewCell()}
            cell.setup(model: immunizationModel)
            return cell
        default:
            guard let cell = textCell(indexPath: indexPath, tableView: tableView) else {return UITableViewCell()}
            cell.setup(with: fields[indexPath.section - 1][indexPath.row])
            return cell
        }
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

extension CovidImmunizationRecordDetailView {
    
    private func createFields() -> [[TextListModel]] {
        guard let model = model, let immunizations = model.covidImmunizations() else {return []}
        var fields: [[TextListModel]] = []
        for (index, imsModel) in immunizations.enumerated() {
            var stringDate = ""
            if let date = imsModel.date {
                stringDate = date.issuedOnDate
            }
            let product = Constants.vaccineInfo(snowMedCode: Int(imsModel.snomed ?? "1") ?? 1)?.displayName ?? ""
            let imsSet = [
                TextListModel(
                    header: TextProperties(
                        text: "Dose \(index + 1)",
                        bolded: true),
                    subtext: nil),
                TextListModel(
                    header: TextProperties(
                        text: "Date:",
                        bolded: true),
                    subtext: TextProperties(
                        text: stringDate,
                        bolded: false)),
                TextListModel(
                    header: TextProperties(
                        text: "Product:",
                        bolded: true),
                    subtext: TextProperties(
                        text: product,
                        bolded: false)),
                TextListModel(
                    header: TextProperties(
                        text: "Provide / Clinic:",
                        bolded: true),
                    subtext: TextProperties(
                        text: imsModel.provider ?? "N/A",
                        bolded: false)),
                TextListModel(
                    header: TextProperties(
                        text: "Lot number:",
                        bolded: true),
                    subtext: TextProperties(
                        text: imsModel.lotNumber ?? "N/A",
                        bolded: false))
            ]
            fields.append(imsSet)
        }
        return fields
    }
}
