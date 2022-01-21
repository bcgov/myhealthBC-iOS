//
//  HealthRecordView.swift
//  BCVaccineCard
//
//  Created by Amir on 2021-12-09.
//

import Foundation
import UIKit

extension HealthRecordsDetailDataSource.Record {
    fileprivate func getCellSections() -> [HealthRecordView.CellSection] {
        switch type {
        case .covidImmunizationRecord(let model, let immunizations):
            return [.Header, .Fields]
        case .covidTestResultRecord(model: let model):
            return [.Header, .Fields]
            
        }
    }
}

class HealthRecordView: UIView, UITableViewDelegate, UITableViewDataSource {
    enum CellSection {
        case Header
        case Fields
    }
    
    private var tableView: UITableView?
    private var model: HealthRecordsDetailDataSource.Record?
    
    func configure(model: HealthRecordsDetailDataSource.Record) {
        self.model = model
        setupTableView()
    }
    
    private func setupTableView() {
        let tableView = UITableView(frame: .zero)
        addSubview(tableView)
        tableView.addEqualSizeContraints(to: self)
        tableView.register(UINib.init(nibName: BannerViewTableViewCell.getName, bundle: .main), forCellReuseIdentifier: BannerViewTableViewCell.getName)
        tableView.register(UINib.init(nibName: TextListViewTableViewCell.getName, bundle: .main), forCellReuseIdentifier: TextListViewTableViewCell.getName)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.showsVerticalScrollIndicator = false
        tableView.estimatedRowHeight = 600
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = false
        self.tableView = tableView
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let model = self.model else {return 0}
        return model.getCellSections().count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let model = self.model else {return 0}
        let sections = model.getCellSections()
        if sections.contains(where: {$0 == .Fields}), sections.last == .Fields && section == sections.count - 1 {
            return model.fields.count
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let model = self.model else { return UITableViewCell()}
        let sections = model.getCellSections()
        let currentSection = sections[indexPath.section]
        switch currentSection {
        case .Header:
            return headerCell(indexPath: indexPath, tableView: tableView)
        case .Fields:
            return textListCellWithIndexPathOffset(indexPath: indexPath, tableView: tableView)
        }
    }
    
    private func headerCell(indexPath: IndexPath, tableView: UITableView) -> UITableViewCell {
        guard
            let model = self.model,
            let cell = tableView.dequeueReusableCell(withIdentifier: BannerViewTableViewCell.getName, for: indexPath) as? BannerViewTableViewCell
        else {
            return UITableViewCell()
        }
        cell.configure(record: model)
        return cell
    }
    
    private func textListCellWithIndexPathOffset(indexPath: IndexPath, tableView: UITableView) -> UITableViewCell {
        guard
            let model = self.model,
            let cell = tableView.dequeueReusableCell(withIdentifier: TextListViewTableViewCell.getName, for: indexPath) as? TextListViewTableViewCell
        else {
            return UITableViewCell()
        }
        let data = model.fields[indexPath.row]
        cell.configure(data: data)
        cell.layoutIfNeeded()
        return cell
    }
}
