//
//  CardsBaseViewController.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-09-15.
//

import UIKit

let cardAddedNotification = Notification.Name("cardAddedNotification")

class CardsBaseViewController: BaseViewController {
    
    @IBOutlet weak private var tableView: UITableView!
    // NOTE: This is for fixing the indentation of table view when in edit mode
    @IBOutlet weak private var tableViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak private var tableViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak private var bottomButton: AppStyleButton!
    
    private var expandedIndexRow = 0
    
    private var dataSource: [AppVaccinePassportModel] = [] {
        didSet {
            buttonHiddenStatus()
        }
    }
    
    private var inEditMode = false {
        didSet {
            tableViewLeadingConstraint.constant = inEditMode ? 0.0 : 24.0
            tableViewTrailingConstraint.constant = inEditMode ? 0.0 : 24.0
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
        cardChangedObservableSetup()
        navSetup()
        retrieveDataSource()
        setupTableView()
    }
    
}

// MARK: Card change observable setup
extension CardsBaseViewController {
    private func cardChangedObservableSetup() {
        NotificationCenter.default.addObserver(self, selector: #selector(onNotification(notification:)), name: cardAddedNotification, object: nil)
    }
    
    @objc func onNotification(notification:Notification) {
        fetchFromDefaults()
        guard let id = notification.userInfo?["id"] as? String else { return }
        var indexPath: IndexPath?
        if let index = self.dataSource.firstIndex(where: { $0.id == id }) {
            expandedIndexRow = index
            indexPath = IndexPath(row: expandedIndexRow, section: 0)
        }
        inEditMode = false
        if let indexPath = indexPath {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                guard self.tableView.numberOfRows(inSection: 0) == self.dataSource.count else { return }
                self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
            }
        }
    }
}

// MARK: Navigation setup
extension CardsBaseViewController {
    private func navSetup() {
        self.navDelegate?.setNavigationBarWith(title: Constants.Strings.MyCardFlow.navHeader, andImage: UIImage(named: "add-card-icon"), action: #selector(self.addCardButton))
    }
    
    @objc private func addCardButton() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
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
        fetchFromDefaults()
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
            saveToDefaults()
        }
        // Note: This is a fix for when a user may swipe to edit, then while editing, taps manage cards
        if type == .manageCards {
            inEditMode = false
        }
        expandedIndexRow = 0
        inEditMode = type == .manageCards
    }

}

// MARK: Table View Logic
extension CardsBaseViewController: UITableViewDelegate, UITableViewDataSource {
    private func setupTableView() {
        tableView.register(UINib.init(nibName: VaccineCardTableViewCell.getName, bundle: .main), forCellReuseIdentifier: VaccineCardTableViewCell.getName)
        tableView.register(UINib.init(nibName: NoCardsTableViewCell.getName, bundle: .main), forCellReuseIdentifier: NoCardsTableViewCell.getName)
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
            if let cell = tableView.dequeueReusableCell(withIdentifier: NoCardsTableViewCell.getName, for: indexPath) as? NoCardsTableViewCell {
                cell.configure(withOwner: self)
                tableView.isEditing = false
                return cell
            }
            return UITableViewCell()
        }
        if let cell = tableView.dequeueReusableCell(withIdentifier: VaccineCardTableViewCell.getName, for: indexPath) as? VaccineCardTableViewCell {
            let expanded = indexPath.row == expandedIndexRow && !inEditMode
            cell.configure(model: dataSource[indexPath.row], expanded: expanded)
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard !self.inEditMode else { return }
        guard let _ = tableView.cellForRow(at: indexPath) as? VaccineCardTableViewCell else { return }
        guard self.expandedIndexRow != indexPath.row else {
            guard let image = dataSource[indexPath.row].image else { return }
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            let vc = ZoomedInPopUpVC.constructZoomedInPopUpVC(withQRImage: image, parentVC: self.navigationController)
            self.present(vc, animated: true, completion: nil)
            return
        }
        let requestedExpandedIndex = indexPath
        let currentExpandedIndex = IndexPath(row: self.expandedIndexRow, section: 0)
        self.expandedIndexRow = requestedExpandedIndex.row
        self.tableView.reloadRows(at: [currentExpandedIndex, requestedExpandedIndex], with: .automatic)
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        guard !dataSource.isEmpty else { return .none }
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.deleteCardAt(indexPath: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard !dataSource.isEmpty else { return nil }
        let delete = UIContextualAction(style: .destructive, title: "") { action, view, completion in
            self.deleteCardAt(indexPath: indexPath)
        }
        delete.image = UIImage(named: "unlink")
        delete.backgroundColor = .white
        let config = UISwipeActionsConfiguration(actions: [delete])
        return config
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard !dataSource.isEmpty else { return nil }
        let delete = UIContextualAction(style: .destructive, title: "") { action, view, completion in
            self.deleteCardAt(indexPath: indexPath)
        }
        delete.image = UIImage(named: "unlink")
        delete.backgroundColor = .white
        let config = UISwipeActionsConfiguration(actions: [delete])
        return config
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        guard !dataSource.isEmpty, dataSource.count > sourceIndexPath.row, dataSource.count > destinationIndexPath.row else { return }
        let movedObject = dataSource[sourceIndexPath.row]
        dataSource.remove(at: sourceIndexPath.row)
        dataSource.insert(movedObject, at: destinationIndexPath.row)
        saveToDefaults()
    }
}

// MARK: Adjusting data source functions
extension CardsBaseViewController {
    private func deleteCardAt(indexPath: IndexPath) {
        alert(title: Constants.Strings.MyCardFlow.MyCardsConfirmations.removeTitle, message: Constants.Strings.MyCardFlow.MyCardsConfirmations.removeDescription, buttonOneTitle: Constants.Strings.GenericText.cancel, buttonOneCompletion: {
            // This logic is so that a swipe to delete that is cancelled, gets reloaded and isn't showing a swiped state after cancelled
            self.tableView.isEditing = self.inEditMode
            // Note: Have to reload the entire table view here, not just the one cell, as it causes issues
            self.tableView.reloadData()
        }, buttonTwoTitle: Constants.Strings.GenericText.yes) { [weak self] in
            guard let `self` = self else {return}
            guard self.dataSource.count > indexPath.row else { return }
            self.dataSource.remove(at: indexPath.row)
            self.saveToDefaults()
            if self.dataSource.isEmpty {
                self.inEditMode = false
            } else {
                self.tableView.reloadData()
            }
        }
    }
}

// MARK: Fetching and Saving conversions between local data source and app data source
extension CardsBaseViewController {
    private func saveToDefaults() {
        Defaults.vaccinePassports = dataSource.map({ $0.transform() })
    }
    
    private func fetchFromDefaults() {
        let localDS = Defaults.vaccinePassports ?? []
        self.dataSource = localDS.map({ $0.transform() })
    }
}
