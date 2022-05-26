//
//  HealthRecordView.swift
//  BCVaccineCard
//
//  Created by Amir on 2021-12-09.
//

import Foundation
import UIKit

extension HealthRecordsDetailDataSource.Record {
    fileprivate func getCellSection() -> [HealthRecordView.CellSection] {
        switch type {
        case .covidImmunizationRecord, .covidTestResultRecord:
            return [.Header, .Fields]
        case .medication:
            return [.Fields, .Comments]
        case .laboratoryOrder:
            return [.Header, .Fields]
        }
    }
}

fileprivate extension HealthRecordsDetailDataSource.Record {
    var hasComments: Bool {
        getCellSection().contains(.Comments)
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
        setupTableView(withSeparator: model.includesSeparatorUI)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {[weak self] in
            self?.tableView?.reloadData()
            // FIXME: For AMIR: I know we have this due to sync issue with Vaccine Card (I believe - when fetching individually, unauthenticated-style), however when the tableView gets reloaded here, we lose the separator at the bottom of the BannerViewTableViewCell, and I'm not sure why
        }
    }
    
    private func createTableView() {
        let tableView = UITableView(frame: .zero)
        addSubview(tableView)
        tableView.addEqualSizeContraints(to: self)
        self.tableView = tableView
    }
    
    private func setupTableView(withSeparator: Bool) {
        guard let tableView = tableView else {
            return
        }
        tableView.register(UINib.init(nibName: BannerViewTableViewCell.getName, bundle: .main), forCellReuseIdentifier: BannerViewTableViewCell.getName)
        tableView.register(UINib.init(nibName: TextListViewTableViewCell.getName, bundle: .main), forCellReuseIdentifier: TextListViewTableViewCell.getName)
        tableView.register(UINib.init(nibName: CommentViewTableViewCell.getName, bundle: .main), forCellReuseIdentifier: CommentViewTableViewCell.getName)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.showsVerticalScrollIndicator = false
        if Device.IS_IPHONE_5 || Device.IS_IPHONE_4 {
            tableView.estimatedRowHeight = 1000
        } else {
            tableView.estimatedRowHeight = 600
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = false
        tableView.separatorStyle = withSeparator ?  .singleLine : .none
        tableView.separatorInset = .zero
        self.tableView = tableView
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let model = self.model else {return 0}
        let availableSections = model.getCellSection()
        return availableSections.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let model = self.model else {return nil}
        let sectionType = model.getCellSection()[section]
        let headerView: TableSectionHeader = TableSectionHeader.fromNib()
        guard sectionType == .Comments, !model.comments.isEmpty else {
            headerView.configure(text: "")
            return headerView
        }
        let commentsString = model.comments.count == 1 ? "Comment" : "Comments"
        headerView.configure(text: "\(model.comments.count) \(commentsString)")
        headerView.backgroundColor = .white
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let model = self.model else {return 0}
        let sectionType = model.getCellSection()[section]
        if sectionType == .Comments, !model.comments.isEmpty {
            return "Comments".heightForView(font: TableSectionHeader.font, width: bounds.width) + 10
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let model = self.model else {return 0}
        let sectionType = model.getCellSection()[section]
        switch sectionType {
        case .Header:
            return 1
        case .Fields:
            return model.fields.count
        case .Comments:
            return model.comments.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let model = self.model else { return UITableViewCell()}
        let sectionType = model.getCellSection()[indexPath.section]
        switch sectionType {
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
