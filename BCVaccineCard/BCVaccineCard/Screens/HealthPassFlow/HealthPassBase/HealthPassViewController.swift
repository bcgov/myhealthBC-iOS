//
//  HealthPassViewController.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-10-06.
// initial

import UIKit
import SwipeCellKit

class HealthPassViewController: BaseViewController {
    
    class func constructHealthPassViewController() -> HealthPassViewController {
        if let vc = Storyboard.healthPass.instantiateViewController(withIdentifier: String(describing: HealthPassViewController.self)) as? HealthPassViewController {
            return vc
        }
        return HealthPassViewController()
    }
    
    @IBOutlet weak private var tableView: UITableView!
    
    private var dataSource: VaccineCard?
    private var savedCardsCount: Int {
        return StorageService.shared.fetchVaccineCards(for: AuthManager().userId()).count
    }

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
                                               rightNavButton: NavButton(image: UIImage(named: "nav-settings"), action: #selector(self.settingsButton), accessibility: Accessibility(traits: .button, label: AccessibilityLabels.MyHealthPassesScreen.navRightIconTitle, hint: AccessibilityLabels.MyHealthPassesScreen.navRightIconHint)),
                                               navStyle: .large,
                                               targetVC: self,
                                               backButtonHintString: nil)
        
        
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
        let vc = QRRetrievalMethodViewController.constructQRRetrievalMethodViewController(backScreenString: .healthPasses)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: DataSource Management
extension HealthPassViewController {
    private func retrieveDataSource() {
        fetchFromStorage()
    }
}

// MARK: Fetching and Saving conversions between local data source and app data source
extension HealthPassViewController {
    private func fetchFromStorage() {
        let cards = StorageService.shared.fetchVaccineCards(for: AuthManager().userId())
        guard cards.count > 0 else {
            self.dataSource = nil
            return
        }
        self.dataSource = cards.first
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

// MARK: Table View Logic
extension HealthPassViewController: UITableViewDelegate, UITableViewDataSource, SwipeTableViewCellDelegate {
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
                cell.isAccessibilityElement = false
                cell.delegate = self
                cell.configure(model: card, expanded: true, editMode: false, delegateOwner: self)
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
        guard let image = dataSource?.code?.generateQRCode() else { return }
        guard indexPath.row == 1 else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        let vc = ZoomedInPopUpVC.constructZoomedInPopUpVC(withQRImage: image, parentVC: self.navigationController, delegateOwner: self)
        self.present(vc, animated: true, completion: nil)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right, savedCardsCount == 1 else {return nil}
        let deleteAction = SwipeAction(style: .destructive, title: "Unlink") { [weak self] action, indexPath in
            guard let `self` = self else {return}
            self.deleteCard()
        }
        deleteAction.hidesWhenSelected = true
        deleteAction.image = UIImage(named: "unlink")
        deleteAction.backgroundColor = .white
        deleteAction.textColor = Constants.UI.Theme.primaryColor
        deleteAction.isAccessibilityElement = true
        deleteAction.accessibilityLabel = AccessibilityLabels.UnlinkFunctionality.unlinkButton
        deleteAction.accessibilityTraits = .button
        return [deleteAction]
    }
    
    private func deleteCard() {
        alert(title: .unlinkCardTitle, message: .unlinkCardMessage, buttonOneTitle: .cancel, buttonOneCompletion: {
            // This logic is so that a swipe to delete that is cancelled, gets reloaded and isn't showing a swiped state after cancelled
            self.tableView.isEditing = false
            self.tableView.reloadData()
        }, buttonTwoTitle: .yes) { [weak self] in
            guard let `self` = self else {return}
            if let card = self.dataSource {
                StorageService.shared.deleteVaccineCard(vaccineQR: card.code ?? "")
            }
            self.dataSource = nil
            AnalyticsService.shared.track(action: .RemoveCard)
            self.tableView.reloadData()
        }
    }
}

// MARK: Federal pass action button delegate
extension HealthPassViewController: FederalPassViewDelegate {
    func federalPassButtonTapped(model: AppVaccinePassportModel?) {
        if let pass = model?.codableModel.fedCode {
            self.openFederalPass(pass: pass, vc: self, id: nil, completion: { [weak self] _ in
                guard let `self` = self else { return }
                self.tabBarController?.tabBar.isHidden = false
            })
        } else {
            guard let model = model else { return }
            self.goToHealthGateway(fetchType: .federalPassOnly(dob: model.codableModel.birthdate, dov: model.codableModel.vaxDates.last ?? "2021-01-01", code: model.codableModel.code), source: .healthPassHomeScreen, owner: self, completion: { [weak self] _ in
                guard let `self` = self else { return }
                self.tabBarController?.tabBar.isHidden = false
                self.navigationController?.popViewController(animated: true)
            })
        }
    }

}

// MARK: Add card button table view cell delegate here
extension HealthPassViewController: AddCardsTableViewCellDelegate {
    func addCardButtonTapped() {
        let vc = QRRetrievalMethodViewController.constructQRRetrievalMethodViewController(backScreenString: .healthPasses)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension HealthPassViewController: AppStyleButtonDelegate {
    func buttonTapped(type: AppStyleButton.ButtonType) {
        if type == .viewAll {
            let vc = CovidVaccineCardsViewController.constructCovidVaccineCardsViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        if type == .addAHealthPass {
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

