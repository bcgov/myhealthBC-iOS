//
//  CovidVaccineCardsViewController.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-09-15.
//

import UIKit
import BCVaccineValidator

class CovidVaccineCardsViewController: BaseViewController {
    
    class func constructCovidVaccineCardsViewController() -> CovidVaccineCardsViewController {
        if let vc = Storyboard.healthPass.instantiateViewController(withIdentifier: String(describing: CovidVaccineCardsViewController.self)) as? CovidVaccineCardsViewController {
            return vc
        }
        return CovidVaccineCardsViewController()
    }
    
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
        setNeedsStatusBarAppearanceUpdate()
        navSetup()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
//        return .lightContent
        if #available(iOS 13.0, *) {
            return UIStatusBarStyle.darkContent
        } else {
            return UIStatusBarStyle.default
        }
    }
    
    private func setup() {
        cardChangedObservableSetup()
        retrieveDataSource()
        setupTableView()
    }
    
}

// MARK: Card change observable setup
extension CovidVaccineCardsViewController {
    private func cardChangedObservableSetup() {
        NotificationCenter.default.addObserver(self, selector: #selector(onNotification(notification:)), name: .cardAddedNotification, object: nil)
    }
    
    @objc func onNotification(notification:Notification) {
        fetchFromStorage()
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
            guard let cell = self.tableView.cellForRow(at: indexPath), self.dataSource.count > indexPath.row else { return }
            let model = self.dataSource[indexPath.row]
            cell.accessibilityLabel = AccessibilityLabels.CovidVaccineCardsScreen.proofOfVaccineCardAdded
            let accessibilityValue = "\(model.codableModel.name), \(model.codableModel.status.getTitle), \(model.getFormattedIssueDate()), \(AccessibilityLabels.VaccineCardView.qrCodeImage)"
            cell.accessibilityValue = accessibilityValue
            cell.accessibilityHint = AccessibilityLabels.VaccineCardView.expandedAction
            UIAccessibility.setFocusTo(cell)
        }
    }
}

// MARK: Navigation setup
extension CovidVaccineCardsViewController {
    private func navSetup() {
        self.navDelegate?.setNavigationBarWith(title: .bcVaccineCards,
                                               leftNavButton: nil,
                                               rightNavButton: NavButton(image: UIImage(named: "add-plus"), action: #selector(self.addCardButton), accessibility: Accessibility(traits: .button, label: AccessibilityLabels.CovidVaccineCardsScreen.navRightIconTitle, hint: AccessibilityLabels.CovidVaccineCardsScreen.navRightIconHint)),
                                               navStyle: .small,
                                               targetVC: self,
                                               backButtonHintString: .healthPasses)
    }
    
    @objc private func addCardButton() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        goToAddCardOptionScreen()
    }
    
    private func goToAddCardOptionScreen() {
        let vc = QRRetrievalMethodViewController.constructQRRetrievalMethodViewController(backScreenString: AccessibilityLabels.CovidVaccineCardsScreen.navHint)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: DataSource Management
extension CovidVaccineCardsViewController {
    private func retrieveDataSource() {
        fetchFromStorage()
        inEditMode = false
    }
}

// MARK: Bottom Button Functionalty
extension CovidVaccineCardsViewController {
    private func buttonHiddenStatus() {
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else {return}
            self.bottomButton.isHidden = self.dataSource.isEmpty
        }
        
    }
    private func adjustButtonName() {
        guard !self.dataSource.isEmpty else { return }
        let buttonType: AppStyleButton.ButtonType = inEditMode ? .done : .manageCards
        let value = self.inEditMode ? AppStyleButton.ButtonType.done.getTitle : AppStyleButton.ButtonType.manageCards.getTitle
        let hint = self.inEditMode ? AccessibilityLabels.CovidVaccineCardsScreen.inEditMode : AccessibilityLabels.CovidVaccineCardsScreen.notInEditMode
        bottomButton.configure(withStyle: .white, buttonType: buttonType, delegateOwner: self, enabled: true, accessibilityValue: value, accessibilityHint: hint)
    }
}

// MARK: Bottom Button Tapped Delegate
extension CovidVaccineCardsViewController: AppStyleButtonDelegate {
    func buttonTapped(type: AppStyleButton.ButtonType) {
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
extension CovidVaccineCardsViewController: UITableViewDelegate, UITableViewDataSource {
    private func setupTableView() {
        tableView.register(UINib.init(nibName: VaccineCardTableViewCell.getName, bundle: .main), forCellReuseIdentifier: VaccineCardTableViewCell.getName)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 330
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard !dataSource.isEmpty else { return UITableViewCell() }
        if let cell = tableView.dequeueReusableCell(withIdentifier: VaccineCardTableViewCell.getName, for: indexPath) as? VaccineCardTableViewCell {
            let expanded = indexPath.row == expandedIndexRow && !inEditMode
            let model = dataSource[indexPath.row]
            cell.configure(model: model, expanded: expanded, editMode: inEditMode, delegateOwner: self)
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
        self.tableView.reloadRows(at: [requestedExpandedIndex, currentExpandedIndex], with: .automatic)
        let cell = self.tableView.cellForRow(at: requestedExpandedIndex)
        UIAccessibility.setFocusTo(cell)
        
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
        delete.accessibilityLabel = AccessibilityLabels.UnlinkFunctionality.unlinkButton
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
        delete.accessibilityLabel = AccessibilityLabels.UnlinkFunctionality.unlinkButton
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
        StorageService.shared.changeVaccineCardSortOrder(cardQR: movedObject.codableModel.code, newPosition: destinationIndexPath.row)
    }
}

// MARK: Federal pass action button delegate
extension CovidVaccineCardsViewController: FederalPassViewDelegate {
    func federalPassButtonTapped(hasPass: Bool) {
        if hasPass {
            // TODO: Open pass here
        } else {
            // TODO: Go To health gateway to fetch pass - will need to configure so that HG can get DOB and DOV from BC Vaccine card and we hide the last two HG form cells
            // NOTE: Will need to refactor HG a bit to adjust for this logic (in terms of remembering, and index references, need to make safe)
            
        }
    }

}

// MARK: Adjusting data source functions
extension CovidVaccineCardsViewController {
    private func deleteCardAt(indexPath: IndexPath) {
        alert(title: .unlinkCardTitle, message: .unlinkCardMessage, buttonOneTitle: .cancel, buttonOneCompletion: {
            // This logic is so that a swipe to delete that is cancelled, gets reloaded and isn't showing a swiped state after cancelled
            self.tableView.isEditing = self.inEditMode
            // Note: Have to reload the entire table view here, not just the one cell, as it causes issues
            self.tableView.reloadData()
        }, buttonTwoTitle: .yes) { [weak self] in
            guard let `self` = self else {return}
            guard self.dataSource.count > indexPath.row else { return }
            let item = self.dataSource[indexPath.row]
            StorageService.shared.deleteVaccineCard(vaccineQR: item.codableModel.code)
            self.dataSource.remove(at: indexPath.row)
            if self.dataSource.isEmpty {
                self.inEditMode = false
            } else {
                self.tableView.reloadData()
            }
        }
    }
}

// MARK: Fetching and Saving conversions between local data source and app data source
extension CovidVaccineCardsViewController {
    
    private func fetchFromStorage() {
        StorageService.shared.getVaccineCardsForCurrentUser { [weak self] cards in
            guard let `self` = self else {return}
            DispatchQueue.main.async { [weak self] in
                guard let `self` = self else {return}
                self.dataSource = cards
                self.adjustButtonName()
                self.tableView.reloadData()
            }
        }
    }
}

// MARK: Zoomed in pop up QR delegate
extension CovidVaccineCardsViewController: ZoomedInPopUpVCDelegate {
    func closeButtonTapped() {
        self.tabBarController?.tabBar.isHidden = false
    }
}


