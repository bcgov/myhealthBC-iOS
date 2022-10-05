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
        
        tableView.register(UINib.init(nibName: MessageBannerTableViewCell.getName, bundle: .main), forCellReuseIdentifier: MessageBannerTableViewCell.getName)
        
        tableView.register(UINib.init(nibName: HealthRecordDetailFieldTableViewCell.getName, bundle: .main), forCellReuseIdentifier: HealthRecordDetailFieldTableViewCell.getName)
        
        tableView.register(UINib.init(nibName: CommentViewTableViewCell.getName, bundle: .main), forCellReuseIdentifier: CommentViewTableViewCell.getName)
        
        tableView.register(UINib.init(nibName: SectionDescriptionTableViewCell.getName, bundle: .main), forCellReuseIdentifier: SectionDescriptionTableViewCell.getName)
        
        tableView.register(UINib.init(nibName: ViewPDFTableViewCell.getName, bundle: .main), forCellReuseIdentifier: ViewPDFTableViewCell.getName)
        
        
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
    
    
    public func messageHeaderCell(indexPath: IndexPath, tableView: UITableView) -> MessageBannerTableViewCell? {
        return tableView.dequeueReusableCell(withIdentifier: MessageBannerTableViewCell.getName, for: indexPath) as? MessageBannerTableViewCell
    }
    
    public func viewPDFButtonCell(indexPath: IndexPath, tableView: UITableView) -> ViewPDFTableViewCell? {
        return tableView.dequeueReusableCell(withIdentifier: ViewPDFTableViewCell.getName, for: indexPath) as? ViewPDFTableViewCell
    }
    
    public func commentCell(indexPath: IndexPath, tableView: UITableView) -> CommentViewTableViewCell? {
        return tableView.dequeueReusableCell(withIdentifier: CommentViewTableViewCell.getName, for: indexPath) as? CommentViewTableViewCell
    }
    
    public func sectionDescriptionCell(indexPath: IndexPath, tableView: UITableView) -> SectionDescriptionTableViewCell? {
        return tableView.dequeueReusableCell(withIdentifier: SectionDescriptionTableViewCell.getName, for: indexPath) as? SectionDescriptionTableViewCell
    }
    
    public func textCell(indexPath: IndexPath, tableView: UITableView) -> HealthRecordDetailFieldTableViewCell? {
        return tableView.dequeueReusableCell(withIdentifier: HealthRecordDetailFieldTableViewCell.getName, for: indexPath) as? HealthRecordDetailFieldTableViewCell
    }
}
