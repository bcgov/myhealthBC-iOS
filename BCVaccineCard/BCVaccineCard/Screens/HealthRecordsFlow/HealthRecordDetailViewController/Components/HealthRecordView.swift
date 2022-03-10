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
        case .covidImmunizationRecord:
            return [.Header, .Fields]
        case .covidTestResultRecord:
            return [.Header, .Fields]
        case .medication:
            return [.Fields, .Comments]
        case .laboratoryOrder:
            return [.Fields]
        }
    }
}

fileprivate extension HealthRecordsDetailDataSource.Record {
    var hasComments: Bool {
        getCellSections().contains(.Comments)
    }
}

class HealthRecordView: UIView, UITableViewDelegate, UITableViewDataSource {
    enum CellSection: Int, CaseIterable {
        case Header
        case Fields
        case Comments
    }
    
    private var tableView: UITableView?
    private var model: HealthRecordsDetailDataSource.Record?
    
    func configure(model: HealthRecordsDetailDataSource.Record) {
        self.model = model
        createTableView()
        setupTableView()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {[weak self] in
            self?.tableView?.reloadData()
        }
    }
    
    private func createTableView() {
        let tableView = UITableView(frame: .zero)
        addSubview(tableView)
        tableView.addEqualSizeContraints(to: self)
        self.tableView = tableView
    }
    
    private func setupTableView() {
        guard let tableView = tableView else {
            return
        }
        tableView.register(UINib.init(nibName: BannerViewTableViewCell.getName, bundle: .main), forCellReuseIdentifier: BannerViewTableViewCell.getName)
        tableView.register(UINib.init(nibName: TextListViewTableViewCell.getName, bundle: .main), forCellReuseIdentifier: TextListViewTableViewCell.getName)
        tableView.register(UINib.init(nibName: CommentViewTableViewCell.getName, bundle: .main), forCellReuseIdentifier: CommentViewTableViewCell.getName)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.showsVerticalScrollIndicator = false
        tableView.estimatedRowHeight = 600
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = false
        tableView.separatorStyle = .none
        self.tableView = tableView
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let model = self.model else {return 0}
        let availableSections = model.getCellSections()
        return availableSections.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let model = self.model else {return nil}
        let currentSectionEnum = sectionEnum(for: section, availableSections: model.getCellSections())
        guard currentSectionEnum == .Comments else {return nil}
        let headerView: TableSectionHeader = TableSectionHeader.fromNib()
        let commentsString = model.comments.count == 1 ? "Comment" : "Comments"
        headerView.configure(text: "\(model.comments.count) \(commentsString)")
        return headerView
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let model = self.model else {return 0}
        let currentSection = sectionEnum(for: section, availableSections: model.getCellSections())
        switch currentSection {
        case .Header:
            return 1
        case .Fields:
            return model.fields.count
        case .Comments:
            return model.comments.count
        }
    }
    
    func sectionEnum(for section: Int, availableSections: [CellSection]) -> CellSection {
        // All Sections being used
        if availableSections.count == CellSection.allCases.count, let currentSection = CellSection(rawValue: section) {
            return currentSection
        }
        
        // Header not being used
        if !availableSections.contains(.Header), availableSections.contains(.Fields), let currentSection = CellSection(rawValue: section + 1) {
            return currentSection
        }
        
        Logger.log(string: "ERROR: Case Not handled", type: .general)
        return .Fields
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let model = self.model else { return UITableViewCell()}
        let currentSection = sectionEnum(for: indexPath.section, availableSections: model.getCellSections())
        switch currentSection {
        case .Header:
            return headerCell(indexPath: indexPath, tableView: tableView)
        case .Fields:
            return textListCellWithIndexPathOffset(indexPath: indexPath, tableView: tableView)
        case .Comments:
            return commentCell(indexPath: indexPath, tableView: tableView)
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
    
    private func commentCell(indexPath: IndexPath, tableView: UITableView) -> UITableViewCell {
        guard
            let model = self.model,
            let cell = tableView.dequeueReusableCell(withIdentifier: CommentViewTableViewCell.getName, for: indexPath) as? CommentViewTableViewCell
        else {
            return UITableViewCell()
        }
        cell.configure(comment: model.comments[indexPath.row])
        return cell
    }
}
