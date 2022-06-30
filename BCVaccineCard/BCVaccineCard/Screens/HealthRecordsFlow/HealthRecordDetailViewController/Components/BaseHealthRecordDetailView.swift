//
//  BaseHealthRecordsDetailView.swift
//  HealthGatewayTest
//
//  Created by Amir on 2022-06-25.
//

import UIKit

class BaseHealthRecordsDetailView: UIView {
    
    public var tableView: UITableView?
    public var model: HealthRecordsDetailDataSource.Record?
    
    let separatorHeight: CGFloat = 1
    let separatorBottomSpace: CGFloat = 12
    
    func setup(model: HealthRecordsDetailDataSource.Record) {
        self.model = model
        createTableView()
        setup()
    }
    
    func setup() {}
    
    public func createTableView() {
        let tableView = UITableView(frame: .zero)
        addSubview(tableView)
        tableView.addEqualSizeContraints(to: self)
        self.tableView = tableView
        setupTableView()
    }
    
    public func separatorView() -> UIView {
        let separatorContainer = UIView()
        let separator = UIView()
        separatorContainer.addSubview(separator)
        separator.place(in: separatorContainer, paddingBottom: separatorBottomSpace, height: separatorHeight)
        separator.backgroundColor = UIColor(red: 0.812, green: 0.812, blue: 0.812, alpha: 1)
        separator.layer.cornerRadius = 4
        return separatorContainer
    }
    
    private func setupTableView() {
        guard let tableView = tableView else {
            return
        }
        
        tableView.register(UINib.init(nibName: BannerViewTableViewCell.getName, bundle: .main), forCellReuseIdentifier: BannerViewTableViewCell.getName)
        tableView.register(UINib.init(nibName: CovidImmunizationBannerTableViewCell.getName, bundle: .main), forCellReuseIdentifier: CovidImmunizationBannerTableViewCell.getName)
        tableView.register(UINib.init(nibName: LabOrderBsnnerTableViewCell.getName, bundle: .main), forCellReuseIdentifier: LabOrderBsnnerTableViewCell.getName)
        tableView.register(UINib.init(nibName: HealthRecordDetailFieldTableViewCell.getName, bundle: .main), forCellReuseIdentifier: HealthRecordDetailFieldTableViewCell.getName)
        tableView.register(UINib.init(nibName: CommentViewTableViewCell.getName, bundle: .main), forCellReuseIdentifier: CommentViewTableViewCell.getName)
        
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.showsVerticalScrollIndicator = false
        if Device.IS_IPHONE_5 || Device.IS_IPHONE_4 {
            tableView.estimatedRowHeight = 1000
        } else {
            tableView.estimatedRowHeight = 600
        }
        
        tableView.allowsSelection = false
        tableView.separatorStyle = .none
        tableView.separatorInset = .zero
        self.tableView = tableView
    }
    
    // TODO:
    public func messageHeaderCell(indexPath: IndexPath, tableView: UITableView) -> BannerViewTableViewCell? {
        return tableView.dequeueReusableCell(withIdentifier: BannerViewTableViewCell.getName, for: indexPath) as? BannerViewTableViewCell
    }
    // TODO:
    public func covidTestHeaderCell(indexPath: IndexPath, tableView: UITableView) -> BannerViewTableViewCell? {
        return tableView.dequeueReusableCell(withIdentifier: BannerViewTableViewCell.getName, for: indexPath) as? BannerViewTableViewCell
    }

    public func CovidImmunizationBannerCell(indexPath: IndexPath, tableView: UITableView) -> CovidImmunizationBannerTableViewCell? {
        return tableView.dequeueReusableCell(withIdentifier: CovidImmunizationBannerTableViewCell.getName, for: indexPath) as? CovidImmunizationBannerTableViewCell
    }
  
    public func labOrderHeaderCell(indexPath: IndexPath, tableView: UITableView) -> LabOrderBsnnerTableViewCell? {
        return tableView.dequeueReusableCell(withIdentifier: LabOrderBsnnerTableViewCell.getName, for: indexPath) as? LabOrderBsnnerTableViewCell
    }
    
    public func commentCell(indexPath: IndexPath, tableView: UITableView) -> CommentViewTableViewCell? {
        return tableView.dequeueReusableCell(withIdentifier: CommentViewTableViewCell.getName, for: indexPath) as? CommentViewTableViewCell
    }
    
    public func fieldCell(indexPath: IndexPath, tableView: UITableView) -> TextListViewTableViewCell? {
        return tableView.dequeueReusableCell(withIdentifier: TextListViewTableViewCell.getName, for: indexPath) as? TextListViewTableViewCell
    }
    
    public func textCell(indexPath: IndexPath, tableView: UITableView) -> HealthRecordDetailFieldTableViewCell? {
        return tableView.dequeueReusableCell(withIdentifier: HealthRecordDetailFieldTableViewCell.getName, for: indexPath) as? HealthRecordDetailFieldTableViewCell
    }
}
