//
//  HealthPassViewController.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-10-06.
// initial

import UIKit
import SwipeCellKit

class HealthPassViewController: BaseViewController {
    
    class func constructHealthPassViewController(fedPassStringToOpen: String?) -> HealthPassViewController {
        if let vc = Storyboard.healthPass.instantiateViewController(withIdentifier: String(describing: HealthPassViewController.self)) as? HealthPassViewController {
            vc.fedPassStringToOpen = fedPassStringToOpen
            return vc
        }
        return HealthPassViewController()
    }
    
    @IBOutlet weak private var tableView: UITableView!
    lazy var authManager: AuthManager = AuthManager()
    
    private var dataSource: VaccineCard?
    private var savedCardsCount: Int {
        return StorageService.shared.fetchVaccineCards().count
    }
    private var fedPassStringToOpen: String?
    
    override var getPassesFlowType: PassesFlowVCs? {
        return .HealthPassViewController(fedPassToOpen: self.fedPassStringToOpen)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        authManager = AuthManager()
        refreshOnStorageChange()
        setFedPassObservable()
        setupListeners()
        showFedPassIfNeccessary()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
        navSetup()
        setupTableView()
        // This is being called here, due to the fact that a user can adjust the primary card, then return to the screen
        setup()
        self.tabBarController?.tabBar.isHidden = false
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
    }
    
    private func showFedPassIfNeccessary() {
        guard let fedPassStringToOpen = fedPassStringToOpen else { return }
        self.showPDFDocument(pdfString: fedPassStringToOpen, navTitle: .canadianCOVID19ProofOfVaccination, documentVCDelegate: self, navDelegate: self.navDelegate)
    }
    
}

// MARK: Listeners
extension HealthPassViewController {
    private func setupListeners() {
        NotificationManager.listenToLoginDataClearedOnLoginRejection(observer: self, selector: #selector(reloadFromForcedLogout))
    }
    
    @objc private func reloadFromForcedLogout(_ notification: Notification) {
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
                                               navTitleSmallAlignment: .Center,
                                               targetVC: self,
                                               backButtonHintString: nil)
        
        
    }
    
    private func goToAddCardOptionScreen(showAuth: Bool) {
        func showScreen() {
            let vc = QRRetrievalMethodViewController.constructQRRetrievalMethodViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        if showAuth && !authManager.isAuthenticated {
            showLogin(initialView: .Landing, sourceVC: .HealthPassVC) { authenticationStatus in
                if authenticationStatus != .Completed {
                    showScreen()
                } else {
                    let recordFlowDetails = RecordsFlowDetails(currentStack: self.getCurrentStacks.recordsStack)
                    let passesFlowDetails = PassesFlowDetails(currentStack: self.getCurrentStacks.passesStack)
                    let scenario = AppUserActionScenarios.LoginSpecialRouting(values: ActionScenarioValues(currentTab: .healthPass, recordFlowDetails: recordFlowDetails, passesFlowDetails: passesFlowDetails, loginSourceVC: .HealthPassVC, authenticationStatus: authenticationStatus))
                    self.routerWorker?.routingAction(scenario: scenario, delayInSeconds: 0.5)
                }
            }
        } else {
            showScreen()
        }
    }
}


// MARK: DataSource Management
extension HealthPassViewController {
    private func retrieveDataSource() {
        fetchFromStorage()
    }
    
    private func refreshOnStorageChange() {
        Notification.Name.storageChangeEvent.onPost(object: nil, queue: .main) {[weak self] notification in
            guard let `self` = self, let event = notification.object as? StorageService.StorageEvent<Any> else {return}
            switch event.entity {
            case .VaccineCard, .Patient:
                self.fetchFromStorage()
            default:
                break
            }
           
        }
    }
}

// MARK: For fed pass observable
extension HealthPassViewController {
    private func setFedPassObservable() {
//        NotificationCenter.default.addObserver(self, selector: #selector(fedPassOnlyAdded(notification:)), name: .fedPassOnlyAdded, object: nil)
    }
    
//    @objc func fedPassOnlyAdded(notification:Notification) {
//        guard let userInfo = notification.userInfo as? [String: Any] else { return }
//        guard let pass = userInfo["pass"] as? String else { return }
//        guard let source = userInfo["source"] as? GatewayFormSource, source == .healthPassHomeScreen else { return }
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//            self.showPDFDocument(pdfString: pass, navTitle: .canadianCOVID19ProofOfVaccination, documentVCDelegate: self, navDelegate: self.navDelegate)
//        }
//    }
}

// MARK: Fetching and Saving conversions between local data source and app data source
extension HealthPassViewController {
    
    private func fetchFromStorage() {
        DispatchQueue.global(qos: .background).async {
            let cards: [VaccineCard]
            if let patient = StorageService.shared.fetchAuthenticatedPatient() {
                cards = StorageService.shared.fetchAllVaccineCards(forPatient: patient)
            } else {
                cards = StorageService.shared.fetchVaccineCards()
            }
            guard cards.count > 0 else {
                self.dataSource = nil
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                return
            }
            self.dataSource = cards.first
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
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
        guard indexPath.row == 1,
              let dataSource = self.dataSource,
              let code = dataSource.code
        else {
            return
        }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        self.tableView.isUserInteractionEnabled = false
        QRMaker.image(for: code) {[weak self] img in
            guard let `self` = self, let image = img else {return}
            let vc = ZoomedInPopUpVC.constructZoomedInPopUpVC(withQRImage: image, parentVC: self.navigationController, delegateOwner: self)
            self.present(vc, animated: true, completion: nil)
            self.tabBarController?.tabBar.isHidden = true
            self.tableView.isUserInteractionEnabled = true
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right, savedCardsCount == 1, self.dataSource?.authenticated == false else {return nil}
        let deleteAction = SwipeAction(style: .destructive, title: "Unlink") { [weak self] action, indexPath in
            guard let `self` = self else {return}
            self.deleteCard(manuallyAdded: true)
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
    
    private func deleteCard(manuallyAdded: Bool) {
        alert(title: .unlinkCardTitle, message: .unlinkCardMessage, buttonOneTitle: .cancel, buttonOneCompletion: {
            // This logic is so that a swipe to delete that is cancelled, gets reloaded and isn't showing a swiped state after cancelled
            self.tableView.isEditing = false
            self.tableView.reloadData()
        }, buttonTwoTitle: .yes) { [weak self] in
            guard let `self` = self else {return}
            if let card = self.dataSource {
                let patient = card.patient
                StorageService.shared.deleteVaccineCard(vaccineQR: card.code ?? "", manuallyAdded: manuallyAdded)
                if let patient = patient, patient.authenticated == false {
                    let records = StorageService.shared.getHeathRecords().detailDataSource(patient: patient)
                    if records.count == 0, let name = patient.name, let birthday = patient.birthday {
                        StorageService.shared.deletePatient(name: name, birthday: birthday)
                    }
                }
                DispatchQueue.main.async {
                    
                    let recordFlowDetails = RecordsFlowDetails(currentStack: self.getCurrentStacks.recordsStack)
                    let passesFlowDetails = PassesFlowDetails(currentStack: self.getCurrentStacks.passesStack)
                    let values = ActionScenarioValues(currentTab: self.getCurrentTab, affectedTabs: [.records], recordFlowDetails: recordFlowDetails, passesFlowDetails: passesFlowDetails)
                    self.routerWorker?.routingAction(scenario: .ManuallyDeletedAllOfAnUnauthPatientRecords(values: values))
                }
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
//            self.openPDFView(pdfString: pass, vc: self, id: nil, type: .fedPass, completion: { [weak self] _ in
//                guard let `self` = self else { return }
//                self.tabBarController?.tabBar.isHidden = false
//            })
            self.showPDFDocument(pdfString: pass, navTitle: .canadianCOVID19ProofOfVaccination, documentVCDelegate: self, navDelegate: self.navDelegate)
        } else {
            guard let model = model else { return }
            self.goToHealthGateway(fetchType: .federalPassOnly(dob: model.codableModel.birthdate, dov: model.codableModel.vaxDates.last ?? "2021-01-01", code: model.codableModel.code), source: .healthPassHomeScreen, owner: self, navDelegate: self.navDelegate)
        }
    }
    
}

extension HealthPassViewController: UIDocumentInteractionControllerDelegate {
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        guard let navController = self.navigationController else { return self }
        return navController
    }
}

// MARK: Add card button table view cell delegate here
extension HealthPassViewController: AddCardsTableViewCellDelegate {
    
    func addCardButtonTapped(screenType: ReusableHeaderAddView.ScreenType) {
        goToAddCardOptionScreen(showAuth: true)
    }
}

extension HealthPassViewController: AppStyleButtonDelegate {
    func buttonTapped(type: AppStyleButton.ButtonType) {
        if type == .viewAll {
            let vc = CovidVaccineCardsViewController.constructCovidVaccineCardsViewController(recentlyAddedCardId: nil, fedPassStringToOpen: nil)
            self.navigationController?.pushViewController(vc, animated: true)
        }
        if type == .addAHealthPass {
            goToAddCardOptionScreen(showAuth: true)
        }
    }
}

// MARK: Zoomed in pop up QR delegate
extension HealthPassViewController: ZoomedInPopUpVCDelegate {
    func closeButtonTapped() {
        self.tabBarController?.tabBar.isHidden = false
    }
}

