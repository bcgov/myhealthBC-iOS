//
//  HealthVIsitRecordDetailVIew.swift
//  BCVaccineCard
//
//  Created by Amir on 2022-07-12.
//

import UIKit

extension HealthRecordsDetailDataSource.Record {
    fileprivate func healthVisit() -> HealthVisit? {
        switch self.type {
        case .healthVisit(model: let model):
            return model
        default:
            return nil
        }
    }
}

class HealthVisitRecordDetailView: BaseHealthRecordsDetailView, UITableViewDelegate, UITableViewDataSource {
    
    private var fields: [TextListModel] = []

    override func setup() {
        tableView?.dataSource = self
        tableView?.delegate = self
        tableView?.register(UINib.init(nibName: HealthVisitRecordDetailTableViewCell.getName, bundle: .main), forCellReuseIdentifier: HealthVisitRecordDetailTableViewCell.getName)
        fields = createFields()
    }
    
    private func getCell(indexPath: IndexPath, tableView: UITableView) -> HealthVisitRecordDetailTableViewCell? {
        let cell = tableView.dequeueReusableCell(withIdentifier: HealthVisitRecordDetailTableViewCell.getName, for: indexPath) as? HealthVisitRecordDetailTableViewCell
        cell?.selectionStyle = .none
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fields.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        layoutIfNeeded()
        if indexPath.row == 0 {
            guard let cell = getCell(indexPath: indexPath, tableView: tableView) else {return UITableViewCell()}
            cell.configure()
            return cell
        }
        if indexPath.row > 0 {
            
            guard let cell = textCell(indexPath: indexPath, tableView: tableView) else {return UITableViewCell()}
            cell.setup(with: fields[indexPath.row - 1])
            return cell
        }
        return UITableViewCell()
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

extension HealthVisitRecordDetailView {
    
    private func createFields() -> [TextListModel] {
        guard let model = model, let object = model.healthVisit() else {return []}

        let fields: [TextListModel] = [
            TextListModel(
                header: TextProperties(
                    text: "Clinic Name:",
                    bolded: true),
                subtext: TextProperties(
                    text: object.clinic?.name ?? "",
                    bolded: false)),
            TextListModel(
                header: TextProperties(
                    text: "Practiner Name:",
                    bolded: true),
                subtext: TextProperties(
                    text: object.practitionerName ?? "",
                    bolded: false))
        ]
       
        return fields
    }
}
