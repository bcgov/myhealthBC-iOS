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
            tableViewLeadingConstraint.constant = inEditMode ? 0.0 : 8.0
            tableViewTrailingConstraint.constant = inEditMode ? 0.0 : 8.0
            tableView.isEditing = inEditMode
            adjustButtonName()
            self.tableView.reloadData()
            self.tableView.layoutSubviews()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navSetup()
    }
    
    private func setup() {
        cardChangedObservableSetup()
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
            guard self.tableView.numberOfRows(inSection: 0) == self.dataSource.count else { return }
            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
            guard let cell = self.tableView.cellForRow(at: indexPath) else { return }
            cell.accessibilityLabel = "Your proof of vaccination has been added to your wallet. Vaccination Card Expanded"
            UIAccessibility.setFocusTo(cell)
        }
    }
}

// MARK: Navigation setup
extension CardsBaseViewController {
    private func navSetup() {
        self.navDelegate?.setNavigationBarWith(title: Constants.Strings.MyCardFlow.navHeader, andImage: UIImage(named: "add-card-icon"), action: #selector(self.addCardButton))
        applyNavAccessibility()
    }
    
    @objc private func addCardButton() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        goToAddCardOptionScreen()
    }
    
    private func goToAddCardOptionScreen() {
        let vc = QRRetrievalMethodViewController.constructQRRetrievalMethodViewController()
        self.removeRightButtonTarget(action: #selector(addCardButton))
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
        let value = self.inEditMode ? AppStyleButton.ButtonType.done.getTitle : AppStyleButton.ButtonType.manageCards.getTitle
        let hint = self.inEditMode ? "Tapping 'done' will stop the editing of cards and save any changes." : "Tapping 'manage cards' will allow you to edit the order of your cards, and remove any cards you no longer want in your wallet."
        bottomButton.configure(withStyle: .white, buttonType: buttonType, delegateOwner: self, enabled: true, accessibilityValue: value, accessibilityHint: hint)
        
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
            tableView.isEditing = false
        }
        expandedIndexRow = 0
        inEditMode = type == .manageCards
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            guard !self.dataSource.isEmpty else { return }
            let indexPath = IndexPath(row: self.dataSource.count - 1, section: 0)
            guard let cell = self.tableView.cellForRow(at: indexPath) else { return }
            UIAccessibility.setFocusTo(cell)
        }
        
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
            let model = dataSource[indexPath.row]
            cell.configure(model: model, expanded: expanded, editMode: inEditMode)
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
            let vc = ZoomedInPopUpVC.constructZoomedInPopUpVC(withQRImage: image, parentVC: self.navigationController, delegateOwner: self)
            self.present(vc, animated: true, completion: nil)
            self.tabBarController?.tabBar.isHidden = true
            return
        }
        let requestedExpandedIndex = indexPath
        let currentExpandedIndex = IndexPath(row: self.expandedIndexRow, section: 0)
        self.expandedIndexRow = requestedExpandedIndex.row
        self.tableView.reloadRows(at: [currentExpandedIndex, requestedExpandedIndex], with: .none)
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
        delete.isAccessibilityElement = true
        delete.accessibilityTraits = .button
        delete.accessibilityLabel = "Unlink button"
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
        delete.isAccessibilityElement = true
        delete.accessibilityTraits = .button
        delete.accessibilityLabel = "Unlink button"
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

// MARK: Zoomed in pop up QR delegate
extension CardsBaseViewController: ZoomedInPopUpVCDelegate {
    func closeButtonTapped() {
        self.tabBarController?.tabBar.isHidden = false
    }
}

// MARK: Accessibility
extension CardsBaseViewController {
    private func applyNavAccessibility() {
        if let nav = self.navigationController as? CustomNavigationController, let rightNavButton = nav.getRightBarButton() {
            rightNavButton.accessibilityTraits = .button
            rightNavButton.accessibilityLabel = "Add Card"
            rightNavButton.accessibilityHint = "Tapping this button will bring you to a new screen with different options to retrieve your QR code"
        }
    }
}


