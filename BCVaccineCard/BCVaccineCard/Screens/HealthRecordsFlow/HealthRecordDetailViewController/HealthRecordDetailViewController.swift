//
//  HealthRecordDetailViewController.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-11-29.
// TODO: This view controller will be a table view with "Delete" in the navigation bar, and will be customizable depending on what the record is, etc. Will likely use an enum here for imm record, or test result

import UIKit


extension HealthRecordsDetailDataSource.Record {
    fileprivate func getCellSections() -> [HealthRecordView.CellSection] {
        switch type {
        case .covidImmunizationRecord(let model, let immunizations):
            return [.Header, .StaticText, .Fields]
        case .covidTestResultRecord(model: let model):
            if model.status == .positive {
                return [.Header, .StaticText, .Fields]
            } else {
                return [.Header, .Fields]
            }
        }
    }
}
class HealthRecordView: UIView, UITableViewDelegate, UITableViewDataSource {
    enum CellSection {
        case Header
        case StaticText
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
        tableView.register(UINib.init(nibName: StaticPositiveTestTableViewCell.getName, bundle: .main), forCellReuseIdentifier: StaticPositiveTestTableViewCell.getName)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 600
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        self.tableView = tableView
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let model = self.model else {return 0}
        return model.getCellSections().count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let model = self.model else {return 0}
        let sections = model.getCellSections()
        if sections.contains(where: {$0 == .Fields}) {
            return model.fields.count
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let model = self.model else { return UITableViewCell()}
        let sections = model.getCellSections()
        let currentSection = sections[indexPath.section]
        switch currentSection {
        case .Header:
            return headerCell(indexPath: indexPath, tableView: tableView)
        case .StaticText:
            return getStaticPositiveTestCell(indexPath: indexPath, tableView: tableView)
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
        cell.configure(model: model.toBannerViewTableViewCellViewModel())
        return cell
    }
    
    private func getStaticPositiveTestCell(indexPath: IndexPath, tableView: UITableView) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: StaticPositiveTestTableViewCell.getName, for: indexPath) as? StaticPositiveTestTableViewCell
        else {
            return UITableViewCell()
        }
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

class HealthRecordsView: UIView, UITableViewDelegate, UITableViewDataSource {
    
    private var tableView: UITableView?
    
    private var models: [HealthRecordsDetailDataSource.Record] = []
    
    func configure(models: [HealthRecordsDetailDataSource.Record]) {
        self.models = models
        setupTableView()
        
    }
    
    private func setupTableView() {
        let tableView = UITableView(frame: .zero)
        addSubview(tableView)
        tableView.addEqualSizeContraints(to: self)
        tableView.register(HealthRecordTableViewCell.self, forCellReuseIdentifier: HealthRecordTableViewCell.getName)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 600
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        self.tableView = tableView
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: HealthRecordTableViewCell.getName, for: indexPath) as? HealthRecordTableViewCell
        else {
            return HealthRecordTableViewCell()
        }
        cell.configure(model: models[indexPath.row])
        return cell
    }
    
}

class HealthRecordTableViewCell: UITableViewCell {

    var model: HealthRecordsDetailDataSource.Record?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(model: HealthRecordsDetailDataSource.Record) {
        self.model = model
        let recordView: HealthRecordView = HealthRecordView(frame: .zero)
        self.contentView.addSubview(recordView)
        recordView.addEqualSizeContraints(to: self.contentView)
        recordView.configure(model: model)
    }
}


class HealthRecordDetailViewController: BaseViewController {
    
    class func constructHealthRecordDetailViewController(dataSource: HealthRecordsDetailDataSource) -> HealthRecordDetailViewController {
        if let vc = Storyboard.records.instantiateViewController(withIdentifier: String(describing: HealthRecordDetailViewController.self)) as? HealthRecordDetailViewController {
            vc.dataSource = dataSource
            return vc
        }
        return HealthRecordDetailViewController()
    }
    
    @IBOutlet weak private var tableView: UITableView!
    
    private var dataSource: HealthRecordsDetailDataSource!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            return UIStatusBarStyle.darkContent
        } else {
            return UIStatusBarStyle.default
        }
    }
    
    private func setup() {
        navSetup()
//        setupTableView()
        setupContent()
    }
    
    func setupContent() {
        let recordsView: HealthRecordsView = HealthRecordsView()
        self.view.addSubview(recordsView)
        recordsView.addEqualSizeContraints(to: self.view)
        recordsView.configure(models: dataSource.records)
    }
    
}

// MARK: Navigation setup
extension HealthRecordDetailViewController {
    private func navSetup() {
        let rightNavButton = NavButton(
            title: .delete,
            image: nil, action: #selector(self.deleteButton),
            accessibility: Accessibility(traits: .button, label: AccessibilityLabels.HealthRecordsDetailScreen.navRightIconTitle, hint: AccessibilityLabels.HealthRecordsDetailScreen.navRightIconHint))
        
        self.navDelegate?.setNavigationBarWith(title: dataSource.title,
                                               leftNavButton: nil,
                                               rightNavButton: rightNavButton,
                                               navStyle: .small,
                                               targetVC: self,
                                               backButtonHintString: nil)
    }
    
    @objc private func deleteButton() {
        alertConfirmation(title: dataSource.deleteAlertTitle, message: dataSource.deleteAlertMessage, confirmTitle: .delete, confirmStyle: .destructive) {
            //TODO: Delete Record and pop view controller
        } onCancel: {
        }
    }
}
