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
        return tableView.dequeueReusableCell(withIdentifier: HealthVisitRecordDetailTableViewCell.getName, for: indexPath) as? HealthVisitRecordDetailTableViewCell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fields.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        layoutIfNeeded()
        guard let cell = getCell(indexPath: indexPath, tableView: tableView) else {return UITableViewCell()}
        
        cell.configure(practitioner: model?.healthVisit()?.practitionerName ?? "")
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

extension HealthVisitRecordDetailView {
    
    private func createFields() -> [TextListModel] {
        guard let model = model, let object = model.healthVisit() else {return []}

        let fields: [TextListModel] = [
            TextListModel(
                header: TextProperties(
                    text: "Clinic/Practitioner",
                    bolded: true),
                subtext: TextProperties(
                    text: object.clinic?.name ?? "",
                    bolded: false))
        ]
       
        return fields
    }
}
