//
//  HomeScreenViewController.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2022-03-16.
//

import UIKit

class HomeScreenViewController: BaseViewController {
    // TODO: Modify HomeScreenCell type to use same enum that we have everywhere
    enum DataSource {
        case banner(data: CommunicationBanner)
        case loginStatus(status: AuthStatus)
        case quickAccess(types: [HomeScreenCellType]) // Note: Will have to modify this slightly once we are hitting the API
        
        var isQuickAccessSection: Bool {
            switch self {
            case .banner, .loginStatus: return false
            case .quickAccess: return true
            }
        }
    }
    
    enum BannerHeight: Int {
        case expanded = 150
        case collapsed = 75
        
        var getCGFloat: CGFloat {
            return CGFloat(self.rawValue)
        }
    }
    
    class func construct() -> HomeScreenViewController {
        if let vc = Storyboard.home.instantiateViewController(withIdentifier: String(describing: HomeScreenViewController.self)) as? HomeScreenViewController {
            return vc
        }
        return HomeScreenViewController()
    }
    
    @IBOutlet weak private var collectionView: UICollectionView!
    
    private var bannerHeight: BannerHeight = .expanded
    
    private var authManager: AuthManager = AuthManager()
        
    private let communicationSetvice: CommunicationSetvice = CommunicationSetvice(network: AFNetwork(), configService: MobileConfigService(network: AFNetwork()))
    private var communicationBanner: CommunicationBanner?
    private let connectionListener = NetworkConnection()
    
    private var actionSheetController: UIAlertController?
    
    private var dataSource: [DataSource] {
        genDataSource()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            return UIStatusBarStyle.darkContent
        } else {
            return UIStatusBarStyle.default
        }
    }
    
    private func setup() {
        addObservablesForChangeInAuthenticationStatus()
        setupCollectionView()
        navSetup()
        
        connectionListener.initListener { [weak self] connected in
            guard let `self` = self else {return}
            if connected {
                self.fetchCommunicationBanner()
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadCollectionView), name: .refetchQuickLinksFromCoreData, object: nil)
    }
    
    @objc private func reloadCollectionView(_ notification: Notification) {
        self.collectionView.reloadData()
    }
    
    // TODO: Adjust this so that it doesn't get called so many times, pretty excessive right now
    private func genDataSource() -> [DataSource] {
        var data: [DataSource] = [
            .quickAccess(types: [
                .Records,
                .Resources,
                .Proofs
            ])
        ]
        let quickAccess = data[0]
        switch quickAccess {
        case .quickAccess(types: let types):
            var newTypes = types
            if authManager.isAuthenticated && !StorageService.shared.fetchRecommendations().isEmpty {
                newTypes.insert(.Recommendations, at: 1)
            } else if !authManager.isAuthenticated {
                newTypes.insert(.ImmunizationSchedule, at: 1)
            }
            if authManager.isAuthenticated {
                let quickLinkPreferences = reduceQuickLinksPreferencesAndSort()
                newTypes.append(contentsOf: quickLinkPreferences)
            }
            data[0] = .quickAccess(types: newTypes)
        default: break
        }
        
        if let banner = communicationBanner {
            data.insert(.banner(data: banner), at: 0)
        }
        if authManager.authStaus != .Authenticated {
            let index = data.count - 1
            data.insert(.loginStatus(status: authManager.authStaus), at: index)
        }
        return data
    }
    
    private func reduceQuickLinksPreferencesAndSort() -> [HomeScreenCellType] {
        let phn = StorageService.shared.fetchAuthenticatedPatient()?.phn ?? ""
        let quickLinksPreferences = Defaults.getStoresPreferencesFor(phn: phn)
        let sortedQuickLinks = quickLinksPreferences.filter { $0.enabled == true }.sorted { $0.addedDate ?? Date() < $1.addedDate ?? Date() }
        return convertQuickLinkIntoDataSource(quickLinks: sortedQuickLinks)
    }
    
    private func convertQuickLinkIntoDataSource(quickLinks: [QuickLinksPreferences]) -> [HomeScreenCellType] {
        var links: [HomeScreenCellType] = []
        for model in quickLinks {
            let link = HomeScreenCellType.QuickLink(type: model.type)
            links.append(link)
        }
        return links
    }
    
//    private func convertQuickLinkIntoQuickLinksNames(coreDataModel: [QuickLinkPreferences]) -> [ManageHomeScreenViewController.QuickLinksNames] {
//        var links: [ManageHomeScreenViewController.QuickLinksNames] = []
//        for model in coreDataModel {
//            if let name = model.quickLink, let type = ManageHomeScreenViewController.QuickLinksNames(rawValue: name) {
//                links.append(type)
//            }
//        }
//        return links
//    }

    
}

// MARK: Navigation setup
extension HomeScreenViewController {
    fileprivate func navTitle(firstName: String? = nil) -> String {
        if authManager.isAuthenticated, let name = firstName ?? StorageService.shared.fetchAuthenticatedPatient()?.name?.firstName ?? authManager.firstName  {
            let sentenceCaseName = name.nameCase()
            return "Hi \(sentenceCaseName),"
        } else {
            return "Home"
        }
    }
    
    private func navSetup(firstName: String? = nil) {
        var title: String = navTitle(firstName: firstName)
        var rightbuttons: [NavButton] = []
        let settingsButton = NavButton(image: UIImage(named: "nav-settings"),
                                       action: #selector(self.settingsButton),
                                       accessibility: Accessibility(traits: .button,
                                                                    label: AccessibilityLabels.MyHealthPassesScreen.navRightIconTitle,
                                                                    hint: AccessibilityLabels.MyHealthPassesScreen.navRightIconHint))
        rightbuttons.append(settingsButton)
        if AuthManager().isAuthenticated {
            let notificationsButton = NavButton(image: UIImage(named: "notifications"),
                                           action: #selector(self.notificationsButton),
                                           accessibility: Accessibility(traits: .button,
                                                                        label: "Notificatioms",
                                                                        hint: "Open Notifications"))
            rightbuttons.append(notificationsButton)
        }
        

        
        self.navDelegate?.setNavigationBarWith(title: title,
                                               leftNavButton: nil,
                                               rightNavButtons: rightbuttons,
                                               navStyle: .large,
                                               navTitleSmallAlignment: .Center,
                                               targetVC: self,
                                               backButtonHintString: nil)
    }
    
    @objc func notificationsButton() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        let network = AFNetwork()
        let authManager = AuthManager()
        let configService = MobileConfigService(network: network)
        let service = NotificationService(network: network, authManager: authManager, configService: configService)
        guard let patient = StorageService.shared.fetchAuthenticatedPatient()
        else {
            return
        }
        guard NetworkConnection.shared.hasConnection else {
            showToast(message: "No internet connection")
            return
        }
        
        service.fetchAndStore(for: patient, loadingStyle: .empty) { results in
            let vm = NotificationsViewController.ViewModel(patient: patient, network: network, authManager: authManager, configService: configService)
            self.show(route: .Notifications, withNavigation: true, viewModel: vm)
        }
    }
}

// MARK: Observable logic for authentication status change
extension HomeScreenViewController {
    private func addObservablesForChangeInAuthenticationStatus() {
        NotificationCenter.default.addObserver(self, selector: #selector(authStatusChanged), name: .authStatusChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(patientAPIFetched), name: .patientAPIFetched, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(storageChangeEvent), name: .storageChangeEvent, object: nil)
        NotificationManager.listenToLoginDataClearedOnLoginRejection(observer: self, selector: #selector(reloadFromForcedLogout))
    }
        
    @objc private func storageChangeEvent(_ notification: Notification) {
        guard let event = notification.object as? StorageService.StorageEvent<Any> else {return}
        switch event.entity {
        case .Recommendation:
            collectionView.reloadData()
        default:
            break
        }
    }
    
    @objc private func reloadFromForcedLogout(_ notification: Notification) {
        navSetup()
        self.collectionView.reloadData()
    }
    
    // Note: Not using authenticated value right now, may just remove it. Leaving in for now in case some requirements change or if there are any edge cases not considered
    // FIXME: Either use the userInfo value or remove it - need to test more first (comment above)
    @objc private func authStatusChanged(_ notification: Notification) {
        guard let userInfo = notification.userInfo as? [String: Bool] else { return }
        guard let authenticated = userInfo[Constants.AuthStatusKey.key] else { return }
        self.navSetup()
        self.collectionView.reloadData()
    }
    
    @objc private func patientAPIFetched(_ notification: Notification) {
        guard let userInfo = notification.userInfo as? [String: String?] else { return }
        guard let firstName = userInfo["firstName"] else { return }
        self.navSetup(firstName: firstName)
        self.collectionView.reloadData()
    }
}

// MARK: Collection View Setup
extension HomeScreenViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout  {
    
    private func setupCollectionView() {
        collectionView.register(UINib.init(nibName: HomeScreenRecordCollectionViewCell.getName, bundle: .main), forCellWithReuseIdentifier: HomeScreenRecordCollectionViewCell.getName)
        collectionView.register(UINib.init(nibName: CommunicationBannerCollectionViewCell.getName, bundle: .main), forCellWithReuseIdentifier: CommunicationBannerCollectionViewCell.getName)
        collectionView.register(UINib.init(nibName: HomeScreenAuthCollectionViewCell.getName, bundle: .main), forCellWithReuseIdentifier: HomeScreenAuthCollectionViewCell.getName)
        collectionView.register(UINib.init(nibName: QuickAccessCollectionReusableView.getName, bundle: .main), forSupplementaryViewOfKind: "UICollectionElementKindSectionHeader", withReuseIdentifier: QuickAccessCollectionReusableView.getName)
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        collectionView.collectionViewLayout = layout
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func cellSize(for sectionType: DataSource) -> CGSize {
        let cView = collectionView.frame
        switch sectionType {
        case .banner:
            return CGSize(width: cView.width, height: bannerHeight.getCGFloat)
        case .loginStatus(status: let status):
            let height: CGFloat = status == .UnAuthenticated ? 169 : 139
            return CGSize(width: cView.width, height: height)
        case .quickAccess:
            let width = (cView.width / 2)
            let height = width * (125/153)
            return CGSize(width: width, height: height)
        }
    }
    
    func getDataSourceType(dataSource: [DataSource], section: Int) -> DataSource? {
        guard section < dataSource.count else { return nil }
        let ds = dataSource[section]
        return ds
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let ds = getDataSourceType(dataSource: self.dataSource, section: indexPath.section) else {
            // TODO: Come up with better default size
            return CGSize(width: 100, height: 100)
        }
        return cellSize(for: ds)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let type = dataSource[section]
        switch type {
        case .banner, .loginStatus: return 1
        case .quickAccess(types: let types): return types.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let dataSection = dataSource[indexPath.section]
        switch dataSection {
        case .banner(data: let data):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CommunicationBannerCollectionViewCell.getName, for: indexPath) as? CommunicationBannerCollectionViewCell else { return UICollectionViewCell() }
            cell.configure(data: communicationBanner, delegate: self)
            return cell
        case .loginStatus(status: let status):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeScreenAuthCollectionViewCell.getName, for: indexPath) as? HomeScreenAuthCollectionViewCell else { return UICollectionViewCell() }
            let type: HomeScreenAuthCollectionViewCell.ContentType = authManager.authStaus == .AuthenticationExpired ? .LoginExpired : .Unauthenticated
            cell.configure(type: type, delegateOwner: self)
            return cell
        case .quickAccess(types: let types):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeScreenRecordCollectionViewCell.getName, for: indexPath) as? HomeScreenRecordCollectionViewCell else { return UICollectionViewCell() }
            let type = types[indexPath.row]
            cell.configure(forType: type, delegateOwner: self, indexPath: indexPath)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let ds = getDataSourceType(dataSource: self.dataSource, section: indexPath.section), ds.isQuickAccessSection else {
            return UICollectionReusableView()
        }
        switch kind {
        case "UICollectionElementKindSectionHeader":
            guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: QuickAccessCollectionReusableView.getName, for: indexPath) as? QuickAccessCollectionReusableView else { return UICollectionReusableView() }
            headerView.configure(status: self.authManager.authStaus, delegateOwner: self)
            return headerView

        default:
            return UICollectionReusableView()
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        guard let ds = getDataSourceType(dataSource: self.dataSource, section: section), ds.isQuickAccessSection else {
            return CGSize(width: 0, height: 0)
        }
        return CGSize(width: collectionView.frame.width, height: 50)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let ds = getDataSourceType(dataSource: dataSource, section: indexPath.section) else { return }
        switch ds {
        case .banner(data: let data): break
        case .loginStatus(status: let status): break
        case .quickAccess(types: let types):
            let type = types[indexPath.row]
            goToTabForType(type: type)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

// MARK: Header logic
extension HomeScreenViewController: QuickAccessCollectionReusableViewDelegate {
    func manageButtonTapped() {
        var vm = ManageHomeScreenViewController.ViewModel()
        vm.createDataSourceForManageScreen()
        show(route: .ManageHomeScreen, withNavigation: true, viewModel: vm)
    }
}

// MARK: Communications Banner
extension HomeScreenViewController: CommunicationBannerCollectionViewCellDelegate {
    func fetchCommunicationBanner() {
        communicationSetvice.fetchMessage {[weak self] result in
            guard let `self` = self else {
                return
            }
            
            if let message = result, message.shouldDisplay {
                self.communicationBanner = message
            } else {
                self.communicationBanner = nil
            }
           
            self.collectionView.reloadData()
        }
    }
    
    func shouldUpdateUI() {
        collectionView.performBatchUpdates(nil)
    }
    
    func onExpand(banner: CommunicationBanner?) {
        // TODO: Amir - we may have to look into this and do it more dynamically based on content
        bannerHeight = .expanded
        collectionView.reloadData()
    }
    
    func onClose(banner: CommunicationBanner?) {
        bannerHeight = .collapsed
        collectionView.performBatchUpdates(nil)
    }
    
    func onDismiss(banner: CommunicationBanner?) {
        guard let banner = banner else {
            return
        }

        communicationSetvice.dismiss(message: banner)
        communicationBanner = nil
        collectionView.reloadData()
        fetchCommunicationBanner()
    }
    
    func onLearnMore(banner: CommunicationBanner?) {
        guard let banner = banner else {
            return
        }
        let learnMoreVC = CommunicationMessageUIViewController()
        learnMoreVC.banner = banner
        navigationController?.pushViewController(learnMoreVC, animated: true)
    }
    
}

// MARK: Quick Links
extension HomeScreenViewController: HomeScreenRecordCollectionViewCellDelegate {
    func moreOptions(indexPath: IndexPath?) {
            // 1: Create PUT API request
            // 2: Create alert from bottom
            // 3: On remove option, hit API for delete preference/quick link
                // reduce data source to array of QuickLinksNames which we will convert to json string
                // On Success: Store again to core data (we will delete existing and store fresh) and then refresh screen (just re-load collection view, as data source is a computed property)
                // On Failure: Show alert to user that delete was unsuccessful and to try again later
        guard let indexPath = indexPath else {
            showGeneralAlertFailure()
            return
        }
        showMoreOptions(indexPath: indexPath)
    }
    
    private func showGeneralAlertFailure() {
        alert(title: "Error", message: "Unable to remove link at this time, please try again later")
    }
    
    private func getQuickLink(indexPath: IndexPath) -> QuickLinksPreferences.QuickLinksNames? {
        let ds = dataSource[indexPath.section]
        switch ds {
        case .quickAccess(types: let types):
            let type = types[indexPath.row]
            switch type {
            case .QuickLink(type: let type):
                return type
            default: return nil
            }
        default: return nil
        }
    }
    // Look into adding completion block here
    private func modifyLocallyStoredPreferences(remove name: String) {
        let phn = StorageService.shared.fetchAuthenticatedPatient()?.phn ?? ""
        var storedPrefences = Defaults.getStoresPreferencesFor(phn: phn)
        if storedPrefences.isEmpty {
            storedPrefences = QuickLinksPreferences.constructEmptyPreferences()
        }
        if let index = storedPrefences.firstIndex(where: { $0.type.rawValue == name }) {
            storedPrefences[index].enabled = false
            Defaults.updateStoredPreferences(phn: phn, newPreferences: storedPrefences)
        }
    }
    
    private func showMoreOptions(indexPath: IndexPath) {
        guard let quickLinkToRemove = getQuickLink(indexPath: indexPath) else {
            showGeneralAlertFailure()
            return
        }
        let name = quickLinkToRemove.rawValue
        actionSheetController = UIAlertController(title: "Remove \(name)", message: "Remove the section from homepage", preferredStyle: .actionSheet)
        actionSheetController?.setTitleAttr(font: UIFont.bcSansBoldWithSize(size: 15), color: AppColours.textBlack)
        actionSheetController?.setMessage(font: UIFont.bcSansRegularWithSize(size: 12), color: AppColours.textGray)
        
        actionSheetController?.addAction(UIAlertAction(title: "Remove", style: .default, handler: { _ in
            
//            let quickLinkPreferences = StorageService.shared.fetchQuickLinksPreferences()
//            var version: Int
//            if name == ManageHomeScreenViewController.QuickLinksNames.OrganDonor.rawValue {
//                version = StorageService.shared.fetchQuickLinksVersion(forOrganDonor: true)
//            } else {
//                version = StorageService.shared.fetchQuickLinksVersion(forOrganDonor: false)
//            }
//            var quickLinks = self.convertQuickLinkIntoQuickLinksNames(coreDataModel: quickLinkPreferences)
////            var organDonorWasInQuickLinks = false
//            if let index = quickLinks.firstIndex(of: quickLinkToRemove) {
////                if quickLinkToRemove == .OrganDonor {
////                    organDonorWasInQuickLinks = true
////                }
//                quickLinks.remove(at: index)
//            }
//            var preferenceString: String?
//            if quickLinkToRemove == .OrganDonor {
//                preferenceString = "true"
//            } else {
//                preferenceString = ManageHomeScreenViewController.ViewModel.constructJsonStringForAPIPreferences(quickLinks: quickLinks)
//            }
//            guard let preferenceString = preferenceString else {
//                self.showGeneralAlertFailure()
//                return
//            }
//            let type: UserProfilePreferencePUTRequestModel.PreferenceType = quickLinkToRemove == .OrganDonor ? .OrganDonor : .NormalQuickLinks
//            self.patientService?.updateQuickLinkPreferences(preferenceString: preferenceString, preferenceType: type, version: version, completion: { result, showAlert in
//                if let result = result {
//                    guard let patient = StorageService.shared.fetchAuthenticatedPatient() else { return }
//                    self.patientService?.fetchAndStoreQuickLinksPreferences(for: patient, useLoader: true, completion: { preferences in
//                        print(preferences)
//                        self.collectionView.reloadData()
//                        self.dismissActionSheet()
//                    })
//                } else if showAlert {
//                    self.showGeneralAlertFailure()
//                }
//            })
            
            self.modifyLocallyStoredPreferences(remove: name)
            self.collectionView.reloadData()
            self.dismissActionSheet()
    
        }))
        
        actionSheetController?.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { [self] _ in
            self.dismissActionSheet()
        }))
        
        guard let actionSheetController = actionSheetController else { return }
        self.present(actionSheetController, animated: true) {
            actionSheetController.view.superview?.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.dismissActionSheetTouchOutside))
            guard let views = actionSheetController.view.superview?.subviews, views.count > 0 else { return }
            views[0].addGestureRecognizer(tap)
        }
    }

    private func dismissActionSheet() {
        actionSheetController?.dismiss(animated: true)
        actionSheetController = nil
        
    }
    
    @objc func dismissActionSheetTouchOutside() {
        dismissActionSheet()
    }
}

// MARK: Login delegate
extension HomeScreenViewController: HomeScreenAuthCollectionViewCellDelegate {
    func loginTapped() {
        showLogin(initialView: .Landing)
    }
}

// MARK: Navigation logic for each type here
extension HomeScreenViewController {
    private func goToTabForType(type: HomeScreenCellType) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        switch type {
        case .Records:
            if authManager.isAuthenticated {
                show(tab: .AuthenticatedRecords)
            } else {
                // TODO: Not sure what we should show here, ask claire
                showLogin(initialView: .Landing)
            }
        case .Proofs:
            let vm = HealthPassViewController.ViewModel(fedPassStringToOpen: nil)
            show(route: .HealthPass, withNavigation: true, viewModel: vm)
        case .Resources:
            show(route: .Resource, withNavigation: true)
        case .Recommendations:
            show(route: .Recommendations, withNavigation: true)
        case .ImmunizationSchedule:
            show(route: .ImmunizationSchedule, withNavigation: true)
        case .QuickLink(type: let type):
            switch type {
            case .OrganDonor:
                show(tab: .Services)
            default:
                show(tab: .AuthenticatedRecords, appliedFilter: type.getFilterType)
            }
        }
    }
}

