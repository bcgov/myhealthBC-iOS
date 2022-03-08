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
    enum CellSection {
        case Header
        case Fields
        case Comments
    }
    
    private var tableView: UITableView?
    private var commentsListView: CommentsListView?
    private var model: HealthRecordsDetailDataSource.Record?
    
    func configure(model: HealthRecordsDetailDataSource.Record) {
        self.model = model
        createViews()
        setupTableView()
    }
    
    private func createViews() {
        
        
        if let model = model, model.hasComments {
            createCommentsView()
        } else {
            let tableView = UITableView(frame: .zero)
            addSubview(tableView)
            tableView.addEqualSizeContraints(to: self)
        }
        
//        tableView.addEqualSizeContraints(to: self)
    }
    
    private func createCommentsView() {
        guard let model = self.model else {return}
        if let existing = self.commentsListView {existing.removeFromSuperview()}
        let commentsListView: CommentsListView = UIView.fromNib()
        self.commentsListView = commentsListView
        addSubview(commentsListView)
        commentsListView.translatesAutoresizingMaskIntoConstraints = false
        commentsListView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
        commentsListView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0).isActive = true
        commentsListView.bottomAnchor.constraint(equalTo: self.safeBottomAnchor, constant: 0).isActive = true
        commentsListView.heightAnchor.constraint(equalToConstant: 300).isActive = true
//        commentsListView.addEqualSizeContraints(to: self)
        
        var comments: [Comment] = []
        for i in 0...10 {
            comments.append(DummyComments.getComment())
        }
//        commentsListView.configure(comments: model.comments)
        commentsListView.configure(comments: comments)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
            commentsListView.tableView.reloadData()
        })
       
    }
    
    private func setupTableView() {
        guard let tableView = tableView else {
            return
        }
        tableView.register(UINib.init(nibName: BannerViewTableViewCell.getName, bundle: .main), forCellReuseIdentifier: BannerViewTableViewCell.getName)
        tableView.register(UINib.init(nibName: TextListViewTableViewCell.getName, bundle: .main), forCellReuseIdentifier: TextListViewTableViewCell.getName)
        tableView.register(UINib.init(nibName: CommentsTableViewCell.getName, bundle: .main), forCellReuseIdentifier: CommentsTableViewCell.getName)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.showsVerticalScrollIndicator = false
        tableView.estimatedRowHeight = 600
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = false
        self.tableView = tableView
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let model = self.model else { return 0}
        let sections = model.getCellSections()
        let currentSection = sections[indexPath.section]
        switch currentSection {
        case .Header:
            return 600
        case .Fields:
            return 600
        case .Comments:
            return 1000
        }
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
        case .Comments:
            return commentsCell(indexPath: indexPath, tableView: tableView)
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
    
    private func commentsCell(indexPath: IndexPath, tableView: UITableView) -> UITableViewCell {
        guard
            let model = self.model,
            let cell = tableView.dequeueReusableCell(withIdentifier: CommentsTableViewCell.getName, for: indexPath) as? CommentsTableViewCell
        else {
            return UITableViewCell()
        }
        
        // TODO: TEMP - For developement
        var comments: [Comment] = []
        for i in 0...10 {
            comments.append(DummyComments.getComment())
        }
//        cell.configure(comments: model.comments)
        cell.configure(comments: comments)
        cell.layoutIfNeeded()
        return cell
    }
}
