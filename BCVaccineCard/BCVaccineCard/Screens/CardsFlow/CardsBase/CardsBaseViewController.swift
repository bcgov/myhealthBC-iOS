//
//  CardsBaseViewController.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-09-15.
//

import UIKit

class CardsBaseViewController: BaseViewController {
    
    @IBOutlet weak private var tableView: UITableView!
    @IBOutlet weak private var bottomButton: AppStyleButton!
    
    private var expandedIndexRow = 0
    
    private var dataSource: [VaccinePassportModel] = [] {
        didSet {
            buttonHiddenStatus()
        }
    }
    
    private var inEditMode = false {
        didSet {
            tableView.isEditing = inEditMode
            adjustButtonName()
            tableView.reloadData()
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
        // TODO: Get actual icon from figma - ask denise
        self.navDelegate?.setNavigationBarWith(title: "My Cards", andImage: UIImage(named: "plus-icon"), action: #selector(self.addCardButton))
    }
    
    @objc private func addCardButton() {
        goToAddCardOptionScreen()
    }
    
    private func goToAddCardOptionScreen() {
        let vc = QRRetrievalMethodViewController.constructQRRetrievalMethodViewController()
        self.navigationController?.pushViewController(vc, animated: true)
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
        let buttonType: AppStyleButton.ButtonType = inEditMode ? .done : .manageCards
        bottomButton.configure(withStyle: .white, buttonType: buttonType, delegateOwner: self, enabled: true)
    }
}

// MARK: Bottom Button Tapped Delegate
extension CardsBaseViewController: AppStyleButtonDelegate {
    func buttonTapped(type: AppStyleButton.ButtonType) {
        guard type != .addCard else {
            goToAddCardOptionScreen()
            return
        }
        if type == .done {
            Defaults.vaccinePassports = dataSource
        }
        expandedIndexRow = 0
        inEditMode = type == .manageCards
    }

}

// MARK: Table View Logic
extension CardsBaseViewController: UITableViewDelegate, UITableViewDataSource {
    private func setupTableView() {
        tableView.register(UINib.init(nibName: "VaccineCardTableViewCell", bundle: .main), forCellReuseIdentifier: "VaccineCardTableViewCell")
        tableView.register(UINib.init(nibName: "NoCardsTableViewCell", bundle: .main), forCellReuseIdentifier: "NoCardsTableViewCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 330
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return max(self.dataSource.count, 1)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard !dataSource.isEmpty else {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "NoCardsTableViewCell", for: indexPath) as? NoCardsTableViewCell {
                cell.configure(withOwner: self)
                return cell
            }
            return UITableViewCell()
        }
        if let cell = tableView.dequeueReusableCell(withIdentifier: "VaccineCardTableViewCell", for: indexPath) as? VaccineCardTableViewCell {
            let expanded = indexPath.row == expandedIndexRow && !inEditMode
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
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            print("Card Delete Action Called here")
        }
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "") { action, view, completion in
            print("Unlink button is clicked")
            // TODO: Alert Action here to confirm if user want's to remove this card, if so, then dataSource.remove(at: indexPath.row), then reload table view if we have to
        }
        delete.image = UIImage(named: "unlink")
        delete.backgroundColor = .white
        let config = UISwipeActionsConfiguration(actions: [delete])
        return config
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "") { action, view, completion in
            print("Unlink button is clicked")
            // TODO: Alert Action here to confirm if user want's to remove this card, if so, then dataSource.remove(at: indexPath.row), then reload table view if we have to
        }
        delete.image = UIImage(named: "unlink")
        delete.backgroundColor = .white
        let config = UISwipeActionsConfiguration(actions: [delete])
        return config
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedObject = dataSource[sourceIndexPath.row]
        dataSource.remove(at: sourceIndexPath.row)
        dataSource.insert(movedObject, at: destinationIndexPath.row)
    }
}
