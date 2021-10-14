//
//  HealthPassViewController.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-10-06.
// initial

import UIKit

class HealthPassViewController: BaseViewController {
    
    class func constructHealthPassViewController() -> HealthPassViewController {
        if let vc = Storyboard.healthPass.instantiateViewController(withIdentifier: String(describing: HealthPassViewController.self)) as? HealthPassViewController {
            return vc
        }
        return HealthPassViewController()
    }
    
    @IBOutlet weak private var tableView: UITableView!
    
    private var dataSource: AppVaccinePassportModel?
    private var savedCardsCount = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
        navSetup()
        // This is being called here, due to the fact that a user can adjust the primary card, then return to the screen
        setup()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            return UIStatusBarStyle.darkContent
        } else {
            return UIStatusBarStyle.default
        }
    }
    
    private func setup() {
        retrieveDataSource()
        setupTableView()
        self.tableView.reloadData()
    }

}

// MARK: Navigation setup
extension HealthPassViewController {
    private func navSetup() {
        self.navDelegate?.setNavigationBarWith(title: .healthPasses,
                                               leftNavButton: nil,
                                               rightNavButton: NavButton(image: UIImage(named: "nav-settings"), action: #selector(self.settingsButton)),
                                               navStyle: .large,
                                               targetVC: self)
        applyNavAccessibility()
    }
    
    @objc private func settingsButton() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        goToSettingsScreen()
    }
    
    private func goToSettingsScreen() {
        let vc = SettingsViewController.constructSettingsViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func goToAddCardOptionScreen() {
        // NOTE: Not sure if I should add UIImpactFeedbackGenerator here or not??
        let vc = QRRetrievalMethodViewController.constructQRRetrievalMethodViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: DataSource Management
extension HealthPassViewController {
    private func retrieveDataSource() {
        fetchFromDefaults()
    }
}

// MARK: Fetching and Saving conversions between local data source and app data source
extension HealthPassViewController {
    private func fetchFromDefaults() {
        guard let localDS = Defaults.vaccinePassports, localDS.count > 0 else {
            self.dataSource = nil
            self.savedCardsCount = 0
            return
        }
        self.savedCardsCount = localDS.count
        self.dataSource = localDS.first?.transform()
    }
}

// MARK: Table View Logic
extension HealthPassViewController: UITableViewDelegate, UITableViewDataSource {
    private func setupTableView() {
        //TODO: Note: Need a new table view cell created here as per designs
        tableView.register(UINib.init(nibName: VaccineCardTableViewCell.getName, bundle: .main), forCellReuseIdentifier: VaccineCardTableViewCell.getName)
        tableView.register(UINib.init(nibName: AddCardsTableViewCell.getName, bundle: .main), forCellReuseIdentifier: AddCardsTableViewCell.getName)
        tableView.register(UINib.init(nibName: ButtonTableViewCell.getName, bundle: .main), forCellReuseIdentifier: ButtonTableViewCell.getName)
        tableView.register(UINib.init(nibName: NoCardsTableViewCell.getName, bundle: .main), forCellReuseIdentifier: NoCardsTableViewCell.getName)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 330
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // TODO: Once we have the other pass section, we will need to adjust this logic (along with the data source though)
        guard self.dataSource != nil else { return 1 }
        return savedCardsCount > 1 ? 3 : 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let card = dataSource else {
            if let cell = tableView.dequeueReusableCell(withIdentifier: NoCardsTableViewCell.getName, for: indexPath) as? NoCardsTableViewCell {
                let height = tableView.bounds.height - 50
                cell.configure(withOwner: self, height: height)
                return cell
            }
            return UITableViewCell()
        }
        // NOTE: Obviously this will be refactored when future features are built with different sections - just no point doing it now until we know what it will look like
        if indexPath.row == 0 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: AddCardsTableViewCell.getName, for: indexPath) as? AddCardsTableViewCell {
                cell.configure(savedCards: self.savedCardsCount, delegateOwner: self)
                return cell
            }
        } else if indexPath.row == 1 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: VaccineCardTableViewCell.getName, for: indexPath) as? VaccineCardTableViewCell {
                cell.configure(model: card, expanded: true, editMode: false)
                return cell
            }
        } else if indexPath.row == 2 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: ButtonTableViewCell.getName, for: indexPath) as? ButtonTableViewCell {
                cell.configure(savedCards: self.savedCardsCount, delegateOwner: self)
                return cell
            }
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let image = dataSource?.image else { return }
        guard indexPath.row == 1 else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        let vc = ZoomedInPopUpVC.constructZoomedInPopUpVC(withQRImage: image, parentVC: self.navigationController, delegateOwner: self)
        self.present(vc, animated: true, completion: nil)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard savedCardsCount == 1, dataSource != nil, indexPath.row == 1 else { return nil }
        let delete = UIContextualAction(style: .destructive, title: "") { action, view, completion in
            self.deleteCard()
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
        guard savedCardsCount == 1, dataSource != nil, indexPath.row == 1  else { return nil }
        let delete = UIContextualAction(style: .destructive, title: "") { action, view, completion in
            self.deleteCard()
        }
        delete.isAccessibilityElement = true
        delete.accessibilityTraits = .button
        delete.accessibilityLabel = "Unlink button"
        delete.image = UIImage(named: "unlink")
        delete.backgroundColor = .white
        let config = UISwipeActionsConfiguration(actions: [delete])
        return config
    }
    
    private func deleteCard() {
        alert(title: .unlinkCardTitle, message: .unlinkCardMessage, buttonOneTitle: .cancel, buttonOneCompletion: {
            // This logic is so that a swipe to delete that is cancelled, gets reloaded and isn't showing a swiped state after cancelled
            self.tableView.isEditing = false
            self.tableView.reloadData()
        }, buttonTwoTitle: .yes) { [weak self] in
            guard let `self` = self else {return}
            self.savedCardsCount = 0
            self.dataSource = nil
            Defaults.vaccinePassports = nil
            self.tableView.reloadData()
        }

        
    }
}

// MARK: Add card button table view cell delegate here
extension HealthPassViewController: AddCardsTableViewCellDelegate {
    func addCardButtonTapped() {
        let vc = QRRetrievalMethodViewController.constructQRRetrievalMethodViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
 // MARK: Primary Vaccine Card button delegates here
//extension HealthPassViewController: PrimaryVaccineCardTableViewCellDelegate {
//    func addCardButtonTapped() {
//        let vc = QRRetrievalMethodViewController.constructQRRetrievalMethodViewController()
//        self.navigationController?.pushViewController(vc, animated: true)
//    }
//
//    func tapToZoomInButtonTapped() {
//        guard let image = dataSource?.image else { return }
//        UIImpactFeedbackGenerator(style: .light).impactOccurred()
//        let vc = ZoomedInPopUpVC.constructZoomedInPopUpVC(withQRImage: image, parentVC: self.navigationController, delegateOwner: self)
//        self.present(vc, animated: true, completion: nil)
//        self.tabBarController?.tabBar.isHidden = true
//    }
//}

extension HealthPassViewController: AppStyleButtonDelegate {
    func buttonTapped(type: AppStyleButton.ButtonType) {
        if type == .viewAll {
            let vc = CovidVaccineCardsViewController.constructCovidVaccineCardsViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        if type == .addCard {
            goToAddCardOptionScreen()
        }
    }
}

// MARK: Zoomed in pop up QR delegate
extension HealthPassViewController: ZoomedInPopUpVCDelegate {
    func closeButtonTapped() {
        self.tabBarController?.tabBar.isHidden = false
    }
}

// MARK: Accessibility
// FIXME: Need to fix these values
extension HealthPassViewController {
    private func applyNavAccessibility() {
        if let nav = self.navigationController as? CustomNavigationController {
            if let rightNavButton = nav.getRightBarButtonItem() {
                rightNavButton.accessibilityTraits = .button
                rightNavButton.accessibilityLabel = "Add Card"
                rightNavButton.accessibilityHint = "Tapping this button will bring you to a new screen with different options to retrieve your QR code"
            }
            if let leftNavButton = nav.getLeftBarButtonItem() {
                // TODO: Need to investigate here - not a priority right now though, as designs will likely change
            }
        }
            
        
    }
}
