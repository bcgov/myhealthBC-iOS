//
//  CovidVaccineCardsViewController.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-09-15.
//

import UIKit
import BCVaccineValidator
import PDFKit
import SwipeCellKit

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
    
    private var expandedIndexRow = 0
    
    private var dataSource: [VaccineCard] = [] {
        didSet {
            buttonHiddenStatus()
        }
    }
    
    private var inEditMode = false {
        didSet {
            tableViewLeadingConstraint.constant = inEditMode ? 0.0 : 8.0
            tableViewTrailingConstraint.constant = inEditMode ? 0.0 : 8.0
            self.tableView.setEditing(inEditMode, animated: false)
            self.tableView.reloadData()
            adjustNavBar()
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
        
        Notification.Name.storageChangeEvent.onPost(object: nil, queue: .main) {[weak self] notification in
            guard let `self` = self, let event = notification.object as? StorageService.StorageEvent<Any> else {return}
            switch event.entity {
            case .VaccineCard:
                self.fetchFromStorage()
                if self.expandedIndexRow > self.dataSource.count - 1 {
                    self.expandedIndexRow = 0
                    self.tableView.reloadData()
                }
            default:
                break
            }
        }
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
            let accessibilityValue = "\(model.name ?? ""), \(AccessibilityLabels.VaccineCardView.qrCodeImage)"
            cell.accessibilityValue = accessibilityValue
            cell.accessibilityHint = AccessibilityLabels.VaccineCardView.expandedAction
            UIAccessibility.setFocusTo(cell)
        }
    }
}

// MARK: Navigation setup
extension CovidVaccineCardsViewController {
    private func navSetup() {
        let hasCards = !self.dataSource.isEmpty
        let editModeNavButton = inEditMode ? NavButton(title: .done,
                                                    image: nil, action: #selector(self.doneButton),
                                                    accessibility: Accessibility(traits: .button, label: AccessibilityLabels.CovidVaccineCardsScreen.navRightDoneIconTitle, hint: AccessibilityLabels.CovidVaccineCardsScreen.navRightDoneIconHint)) :
                                          NavButton(title: .edit,
                                                    image: nil, action: #selector(self.editButton),
                                                    accessibility: Accessibility(traits: .button, label: AccessibilityLabels.CovidVaccineCardsScreen.navRightEditIconTitle, hint: AccessibilityLabels.CovidVaccineCardsScreen.navRightEditIconHint))
        let rightNavButton = hasCards ? editModeNavButton : nil
        self.navDelegate?.setNavigationBarWith(title: .bcVaccineCards,
                                               leftNavButton: nil,
                                               rightNavButton: rightNavButton,
                                               navStyle: .small,
                                               targetVC: self,
                                               backButtonHintString: .healthPasses)
    }
    
    @objc private func doneButton() {
        expandedIndexRow = 0
        inEditMode = false
        accessibilityFocusForEditing()
    }
    
    @objc private func editButton() {
        tableView.isEditing = false
        expandedIndexRow = 0
        inEditMode = true
        accessibilityFocusForEditing()
    }
    
    private func accessibilityFocusForEditing() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            guard !self.dataSource.isEmpty else { return }
            let indexPath = IndexPath(row: self.dataSource.count - 1, section: 0)
            guard let cell = self.tableView.cellForRow(at: indexPath) else { return }
            UIAccessibility.setFocusTo(cell)
        }

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
//            self.bottomButton.isHidden = self.dataSource.isEmpty
            self.adjustNavBar()
            
        }
        
    }
    private func adjustNavBar() {
        self.navSetup()
    }
}

// MARK: Table View Logic
extension CovidVaccineCardsViewController: UITableViewDelegate, UITableViewDataSource, SwipeTableViewCellDelegate {
    
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
        guard !dataSource.isEmpty,
              let cell = tableView.dequeueReusableCell(
                withIdentifier: VaccineCardTableViewCell.getName,
                for: indexPath) as? VaccineCardTableViewCell
        else {
            return UITableViewCell()
        }
        let expanded = indexPath.row == expandedIndexRow && !inEditMode
        let model = dataSource[indexPath.row]
        cell.configure(model: model, expanded: expanded, editMode: inEditMode, delegateOwner: self)
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard !self.inEditMode else { return }
        guard let _ = tableView.cellForRow(at: indexPath) as? VaccineCardTableViewCell,
              let code = dataSource[indexPath.row].code
        else { return }
        if self.expandedIndexRow != indexPath.row {
            let requestedExpandedIndex = indexPath
            let currentExpandedIndex = IndexPath(row: self.expandedIndexRow, section: 0)
            self.expandedIndexRow = requestedExpandedIndex.row
            self.tableView.reloadRows(at: [requestedExpandedIndex, currentExpandedIndex], with: .automatic)
            let cell = self.tableView.cellForRow(at: requestedExpandedIndex)
            UIAccessibility.setFocusTo(cell)
        } else {
            QRMaker.image(for: code) { img in
                guard let image = img else { return }
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                let vc = ZoomedInPopUpVC.constructZoomedInPopUpVC(withQRImage: image, parentVC: self.navigationController, delegateOwner: self)
                self.present(vc, animated: true, completion: nil)
                self.tabBarController?.tabBar.isHidden = true
                return
            }
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        // TODO: Check for authentication here to prevent deleting authenticated record
        guard !dataSource.isEmpty || !inEditMode else { return .none }
        return .delete
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.deleteCardAt(indexPath: indexPath, reInitEditMode: true)
        }
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        // TODO: Check if we need an authentication check here
        return .unlinkTitle
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        guard !dataSource.isEmpty, dataSource.count > sourceIndexPath.row, dataSource.count > destinationIndexPath.row else { return }
        let movedObject = dataSource[sourceIndexPath.row]
        dataSource.remove(at: sourceIndexPath.row)
        dataSource.insert(movedObject, at: destinationIndexPath.row)
        if let card = StorageService.shared.fetchVaccineCard(code: movedObject.code ?? "") {
            StorageService.shared.updateVaccineCardSortOrder(card: card, newPosition: destinationIndexPath.row)
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else {return nil}
        let deleteAction = SwipeAction(style: .destructive, title: "Unlink") { [weak self] action, indexPath in
            guard let `self` = self else {return}
            self.deleteCardAt(indexPath: indexPath, reInitEditMode: false)
        }
        deleteAction.hidesWhenSelected = true
        deleteAction.image = UIImage(named: "unlink")
        deleteAction.backgroundColor = .white
        deleteAction.textColor = Constants.UI.Theme.primaryColor
        deleteAction.isAccessibilityElement = true
        deleteAction.accessibilityLabel = AccessibilityLabels.UnlinkFunctionality.unlinkCard
        deleteAction.accessibilityTraits = .button
        return [deleteAction]
    }
}

// MARK: Federal pass action button delegate
extension CovidVaccineCardsViewController: FederalPassViewDelegate {
    func federalPassButtonTapped(model: AppVaccinePassportModel?) {
        if let pass =  model?.codableModel.fedCode {
            self.openFederalPass(pass: pass, vc: self, id: nil, completion: { [weak self] _ in
                guard let `self` = self else { return }
                self.tabBarController?.tabBar.isHidden = false
            })
        } else {
            guard let model = model else { return }
            self.goToHealthGateway(fetchType: .federalPassOnly(dob: model.codableModel.birthdate, dov: model.codableModel.vaxDates.last ?? "2021-01-01", code: model.codableModel.code), source: .vaccineCardsScreen, owner: self, completion: { [weak self] id in
                guard let `self` = self else { return }
                self.tabBarController?.tabBar.isHidden = false
                self.navigationController?.popViewController(animated: true)
                guard let id = id else { return }
                self.postCardAddedNotification(id: id)
            })
        }
    }

}

// MARK: Adjusting data source functions
extension CovidVaccineCardsViewController {
    private func deleteCardAt(indexPath: IndexPath, reInitEditMode: Bool) {
        alert(title: .unlinkCardTitle, message: .unlinkCardMessage,
              buttonOneTitle: .cancel, buttonOneCompletion: {
            if reInitEditMode {
                self.tableView.setEditing(false, animated: true)
                self.tableView.setEditing(true, animated: true)
            }
        }, buttonTwoTitle: .yes) { [weak self] in
            guard let `self` = self else {return}
            guard self.dataSource.count > indexPath.row else { return }
            let item = self.dataSource[indexPath.row]
            StorageService.shared.deleteVaccineCard(vaccineQR: item.code ?? "")
        }
    }
}

// MARK: Fetching and Saving conversions between local data source and app data source
extension CovidVaccineCardsViewController {
    
    private func fetchFromStorage() {
        let cards = StorageService.shared.fetchVaccineCards()
        self.dataSource = cards
        self.adjustNavBar()
        self.tableView.reloadData()
    }
}

// MARK: Zoomed in pop up QR delegate
extension CovidVaccineCardsViewController: ZoomedInPopUpVCDelegate {
    func closeButtonTapped() {
        self.tabBarController?.tabBar.isHidden = false
    }
}


