//
//  HomeScreenViewController.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2022-03-16.
//

import UIKit

class HomeScreenViewController: BaseViewController {
    
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
    
//    @IBOutlet weak private var tableView: UITableView!
    @IBOutlet weak private var collectionView: UICollectionView!
    
    private var bannerHeight: BannerHeight = .expanded
    
    private var authManager: AuthManager = AuthManager()
        
    private let communicationSetvice: CommunicationSetvice = CommunicationSetvice(network: AFNetwork(), configService: MobileConfigService(network: AFNetwork()))
    private var communicationBanner: CommunicationBanner?
    private let connectionListener = NetworkConnection()
    
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
//        setupTableView()
        setupCollectionView()
        navSetup()
        
        connectionListener.initListener { [weak self] connected in
            guard let `self` = self else {return}
            if connected {
                self.fetchCommunicationBanner()
            }
        }
    }
    
    private func genDataSource() -> [DataSource] {
        let showRecommendedImz = authManager.isAuthenticated && !StorageService.shared.fetchRecommendations().isEmpty
        var data: [DataSource] = [
            .quickAccess(types: [
                .Records,
                .Recommendations(showRecommendedImz: showRecommendedImz),
                .Resources,
                .Proofs
            ])
        ]
        if let banner = communicationBanner {
            data.insert(.banner(data: banner), at: 0)
        }
        if authManager.authStaus != .Authenticated {
            let index = data.count - 1
            data.insert(.loginStatus(status: authManager.authStaus), at: index)
        }
        
//        var data: [DataSource] = [.text(text: "What do you want to focus on today?"), .button(type: .Records), .button(type: .Resources), .button(type: .Proofs)]
//        if authManager.isAuthenticated && !StorageService.shared.fetchRecommendations().isEmpty {
//            data.insert(.button(type: .Recommendations), at: 2)
//        }
//        if let banner = communicationBanner {
//            data.insert(.banner(data: banner), at: 1)
//        }
//        return data
        return data
    }

    
}

// MARK: Navigation setup
extension HomeScreenViewController {
    fileprivate func navTitle(firstName: String? = nil) -> String {
        if authManager.isAuthenticated, let name = firstName ?? StorageService.shared.fetchAuthenticatedPatient()?.name?.firstName ?? authManager.firstName  {
            let sentenceCaseName = name.nameCase()
            return "Hi \(sentenceCaseName),"
        } else {
            return "Hello"
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
//            tableView.reloadData()
        default:
            break
        }
    }
    
    @objc private func reloadFromForcedLogout(_ notification: Notification) {
        navSetup()
        self.collectionView.reloadData()
//            self.tableView.reloadData()
    }
    
    // Note: Not using authenticated value right now, may just remove it. Leaving in for now in case some requirements change or if there are any edge cases not considered
    // FIXME: Either use the userInfo value or remove it - need to test more first (comment above)
    @objc private func authStatusChanged(_ notification: Notification) {
        guard let userInfo = notification.userInfo as? [String: Bool] else { return }
        guard let authenticated = userInfo[Constants.AuthStatusKey.key] else { return }
        self.navSetup()
        self.collectionView.reloadData()
//            self.tableView.reloadData()
    }
    
    @objc private func patientAPIFetched(_ notification: Notification) {
        guard let userInfo = notification.userInfo as? [String: String?] else { return }
        guard let firstName = userInfo["firstName"] else { return }
        self.navSetup(firstName: firstName)
        self.collectionView.reloadData()
//            self.tableView.reloadData()
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
//        layout.itemSize =  cellSize() // Prob need to remove this
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
            cell.configure(forType: type)
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
        alert(title: "Coming soon", message: "Will be implemented in the next build")
    }
}

// MARK: Table View Setup
//extension HomeScreenViewController: UITableViewDelegate, UITableViewDataSource {
//
//    private func setupTableView() {
//        tableView.register(UINib.init(nibName: TextTableViewCell.getName, bundle: .main), forCellReuseIdentifier: TextTableViewCell.getName)
//        tableView.register(UINib.init(nibName: HomeScreenTableViewCell.getName, bundle: .main), forCellReuseIdentifier: HomeScreenTableViewCell.getName)
//        tableView.register(UINib.init(nibName: CommunicationBannerTableViewCell.getName, bundle: .main), forCellReuseIdentifier: CommunicationBannerTableViewCell.getName)
//        tableView.rowHeight = UITableView.automaticDimension
////        tableView.estimatedRowHeight = 231
//        tableView.delegate = self
//        tableView.dataSource = self
//    }
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return dataSource.count
//    }
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let data = dataSource[indexPath.row]
//        switch data {
//        case .text(text: let text):
//            guard let cell = tableView.dequeueReusableCell(withIdentifier: TextTableViewCell.getName, for: indexPath) as? TextTableViewCell else { return UITableViewCell() }
//            cell.configure(forType: .plainText, text: text, withFont: UIFont.bcSansBoldWithSize(size: 20), labelSpacingAdjustment: 30, textColor: AppColours.appBlue)
//            return cell
//        case .button(type: let type):
//            guard let cell = tableView.dequeueReusableCell(withIdentifier: HomeScreenTableViewCell.getName, for: indexPath) as? HomeScreenTableViewCell else { return UITableViewCell() }
//            cell.configure(forType: type, auth: authManager.isAuthenticated)
//            return cell
//        case .banner(data: let data):
//            guard let cell = tableView.dequeueReusableCell(withIdentifier: CommunicationBannerTableViewCell.getName, for: indexPath) as? CommunicationBannerTableViewCell else { return UITableViewCell() }
//            cell.configure(data: communicationBanner, delegate: self)
//            cell.selectionStyle = .none
//            return cell
//        }
//    }
//
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let data = dataSource[indexPath.row]
//        switch data {
//        case .button(type: let type):
//            goToTabForType(type: type)
//        default: break
//        }
//    }
//}

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
           
//            self.tableView.reloadData()
            self.collectionView.reloadData()
        }
    }
    
    func shouldUpdateUI() {
//        tableView.performBatchUpdates(nil)
        collectionView.performBatchUpdates(nil)
    }
    
    func onExpand(banner: CommunicationBanner?) {
//        tableView.reloadData()
        // TODO: Amir - we may have to look into this and do it more dynamically based on content
        bannerHeight = .expanded
        collectionView.reloadData()
    }
    
    func onClose(banner: CommunicationBanner?) {
//        tableView.performBatchUpdates(nil)
        bannerHeight = .collapsed
        collectionView.performBatchUpdates(nil)
    }
    
    func onDismiss(banner: CommunicationBanner?) {
        guard let banner = banner else {
            return
        }

        communicationSetvice.dismiss(message: banner)
        communicationBanner = nil
//        tableView.reloadData()
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

// MARK: Login delegate
extension HomeScreenViewController: HomeScreenAuthCollectionViewCellDelegate {
    func loginTapped() {
        showLogin(initialView: .Landing, showTabOnSuccess: .AuthenticatedRecords)
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
                showLogin(initialView: .Landing, showTabOnSuccess: .AuthenticatedRecords)
            }
        case .Proofs:
            let vm = HealthPassViewController.ViewModel(fedPassStringToOpen: nil)
            show(route: .HealthPass, withNavigation: true, viewModel: vm)
        case .Resources:
            show(route: .Resource, withNavigation: true)
        case .Recommendations:
            show(route: .Recommendations, withNavigation: true)
        }
    }
}

