//
//  CardsBaseViewController.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-09-15.
//

import UIKit

class CardsBaseViewController: BaseViewController {
    
    @IBOutlet weak private var tableView: UITableView!
    @IBOutlet weak private var bottomButton: UIButton!
    
    private var expandedIndexRow = 0
    
    private var dataSource: [VaccinePassportModel] = [] {
        didSet {
            buttonHiddenStatus()
        }
    }
    
    private var inEditMode = false {
        didSet {
            adjustButtonName()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup() {
        navSetup()
        retrieveDataSource()
        setupTableView()
    }
    
}

// MARK: Navigation setup
extension CardsBaseViewController {
    private func navSetup() {
        self.navDelegate?.setNavigationBarWith(title: "My Cards", andImage: UIImage(named: "PlusIcon"), action: #selector(self.addCardButton))
    }
    
    @objc private func addCardButton() {
        goToAddCardOptionScreen()
    }
    
    private func goToAddCardOptionScreen() {
        // TODO Open the qr retrieval option screen here
    }
}

// MARK: DataSource Management
extension CardsBaseViewController {
    private func retrieveDataSource() {
        self.dataSource = Defaults.vaccinePassports ?? []
        inEditMode = false
    }
}

// MARK: Bottom Button Functionalty
extension CardsBaseViewController {
    private func buttonHiddenStatus() {
        bottomButton.isHidden = self.dataSource.isEmpty
    }
    private func adjustButtonName() {
        guard !self.dataSource.isEmpty else { return }
        let buttonTitle = inEditMode ? "Done" : "Manage Cards"
        bottomButton.setTitle(buttonTitle, for: .normal)
    }
}

// MARK: Table View Logic
extension CardsBaseViewController: UITableViewDelegate, UITableViewDataSource {
    private func setupTableView() {
        tableView.register(UINib.init(nibName: "VaccineCardTableViewCell", bundle: .main), forCellReuseIdentifier: "VaccineCardTableViewCell")
        tableView.register(UINib.init(nibName: "NoCardsTableViewCell", bundle: .main), forCellReuseIdentifier: "NoCardsTableViewCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 200
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return max(self.dataSource.count, 1)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard !dataSource.isEmpty else {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "NoCardsTableViewCell", for: indexPath) as? NoCardsTableViewCell {
                cell.delegate = self
                return cell
            }
            return UITableViewCell()
        }
        if let cell = tableView.dequeueReusableCell(withIdentifier: "VaccineCardTableViewCell", for: indexPath) as? VaccineCardTableViewCell {
            let expanded = indexPath.row == expandedIndexRow
            cell.configure(model: dataSource[indexPath.row], expanded: expanded)
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let requestedExpandedIndex = indexPath
        let currentExpandedIndex = IndexPath(row: self.expandedIndexRow, section: 0)
        self.expandedIndexRow = requestedExpandedIndex.row
        self.tableView.reloadRows(at: [currentExpandedIndex, requestedExpandedIndex], with: .automatic)
    }
}

// MARK: Delegate for adding card from empty data set
extension CardsBaseViewController: NoCardsTableViewCellDelegate {
    func addCardButtonFromEmptyDataSet() {
        goToAddCardOptionScreen()
    }

}
