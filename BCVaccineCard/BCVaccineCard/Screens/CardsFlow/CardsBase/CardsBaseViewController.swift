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
    
    private var dataSource: [AppVaccinePassportModel] = [] {
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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Note: This refreshes the data source. Should find a better way to do this once gateway is working - will use a completion handler or something like that, as this is inefficient
        retrieveDataSource()
        
    }
    
}

// MARK: Navigation setup
extension CardsBaseViewController {
    private func navSetup() {
        self.navDelegate?.setNavigationBarWith(title: Constants.Strings.MyCardFlow.navHeader, andImage: UIImage(named: "add-card-icon"), action: #selector(self.addCardButton))
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
            let vc = ZoomedInPopUpVC.constructZoomedInPopUpVC(withQRImage: image)
            self.present(vc, animated: true, completion: nil)
            return
        }
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
            self.deleteCardAt(indexPath: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "") { action, view, completion in
            self.deleteCardAt(indexPath: indexPath)
        }
        delete.image = UIImage(named: "unlink")
        delete.backgroundColor = .white
        let config = UISwipeActionsConfiguration(actions: [delete])
        return config
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "") { action, view, completion in
            self.deleteCardAt(indexPath: indexPath)
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
        saveToDefaults()
    }
}

// MARK: Adjusting data source functions
extension CardsBaseViewController {
    private func deleteCardAt(indexPath: IndexPath) {
        alert(title: Constants.Strings.MyCardFlow.MyCardsConfirmations.removeTitle, message: Constants.Strings.MyCardFlow.MyCardsConfirmations.removeDescription, buttonOneTitle: Constants.Strings.GenericText.cancel, buttonOneCompletion: {
            // Do Nothing here
        }, buttonTwoTitle: Constants.Strings.GenericText.yes) { [weak self] in
            guard let `self` = self else {return}
            guard self.dataSource.count > indexPath.row else { return }
            self.dataSource.remove(at: indexPath.row)
            self.saveToDefaults()
            self.tableView.reloadData()
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
