//
//  HealthRecordsViewController.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-11-10.
//
//TODO: This will have a collection view that will display a users name. Above the collection view is the header add view
// FIGMA: https://www.figma.com/file/ga1F6q5Kvi6CD6FLS27fXq/My-Health-BC?node-id=3275%3A42427

import UIKit

class HealthRecordsViewController: BaseViewController {
    
    class func constructHealthRecordsViewController() -> HealthRecordsViewController {
        if let vc = Storyboard.records.instantiateViewController(withIdentifier: String(describing: HealthRecordsViewController.self)) as? HealthRecordsViewController {
            return vc
        }
        return HealthRecordsViewController()
    }
    
    let spacingPerItem: CGFloat = 10
    
    @IBOutlet weak private var addRecordView: ReusableHeaderAddView!
    @IBOutlet weak private var collectionView: UICollectionView!
    
    private let authManager: AuthManager = AuthManager()
    private var dataSource: [HealthRecordsDataSource] = []
    private var recentlyAddedId: String?
    // Note: This is used when we want to automatically go to a users records
    private var authenticatedPatientToShow: Patient?
   
    var lastPatientSelected: Patient? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setupCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadDataAndSetInitialVC()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            return UIStatusBarStyle.darkContent
        } else {
            return UIStatusBarStyle.default
        }
    }
 
    private func setup() {
        loadDataAndSetInitialVC()
        refreshOnStorageChange()
    }
    
    private func loadDataAndSetInitialVC() {
        navSetup()
        let records = fetchData()
        self.dataSource = records.dataSource()
        self.navigationController?.popToRootViewController(animated: false)
        if self.dataSource.isEmpty {
            self.showFetchVC(hasHealthRecords: false)
        } else if dataSource.count == 1, let singleUser = dataSource.first {
            showRecords(for: singleUser.patient, animated: false, navStyle: .singleUser, authenticated: singleUser.authenticated, hasUpdatedUnauthPendingTest: false)
        } else {
            self.addRecordHeaderSetup()
            self.setupCollectionView()
            if let patient = authenticatedPatientToShow {
                self.goToUserRecordsViewControllerForPatient(patient)
            }
            collectionView.reloadData()
        }
    }
    
    
    // MARK: Data
    private func refreshOnStorageChange() {
        Notification.Name.storageChangeEvent.onPost(object: nil, queue: .main) {[weak self] notification in
            guard let `self` = self, let event = notification.object as? StorageService.StorageEvent<Any> else {return}
            if event.event == .ManuallyAddedRecord {
                self.loadDataAndSetInitialVC()
            }
            // TODO: Here we will need to check for the case where we are doing the initial medical records fetch for protective word - easiest might just be an event type, same as ManuallyAddedRecord
            guard event.event != .ManuallyAddedRecord || event.event != .ProtectedMedicalRecordsInitialFetch else { return }
            switch event.entity {
            case .VaccineCard, .CovidLabTestResult, .Perscription, .LaboratoryOrder:
                self.loadDataAndSetInitialVC()
                if let lastPatientSelected = self.lastPatientSelected, !self.dataSource.isEmpty, let lastPatientRecordInDataSouce = self.dataSource.first(where: {$0.patient == lastPatientSelected}) {
                    self.showRecords(for: lastPatientRecordInDataSouce.patient, animated: false, navStyle: self.dataSource.count == 1 ? .singleUser :.multiUser, authenticated: lastPatientRecordInDataSouce.authenticated, hasUpdatedUnauthPendingTest: true)
                }
            default:
                break
            }
        }
    }
    
//    private func updateData() {
//        let records = fetchData()
//        self.dataSource = records.dataSource()
//        self.addRecordHeaderSetup()
//        self.collectionView.reloadData()
//        if self.dataSource.isEmpty {
//            self.showFetchVC()
//        } else {
//            // FIXME: Need a way of dismissing dismissFetchHealthRecordsViewController() for the case where data is nil, user enters app, goes to health records tab (so it is instantiated and viewDidLoad is called), then user goes to healthPasses tab, scans a QR code, then user goes back to health records tab.... issue is that the fetchVC will still be shown
//            // Possible solution: Listener on tab bar controller, check when tab is changed - something like that. Need to think on this
//            self.dismissFetchHealthRecordsViewControllerIfNeeded()
//
//        }
//    }
    
    private func fetchData() -> [HealthRecord] {
        StorageService.shared.getHeathRecords()
    }
    
    // MARK: Routing
//    func dismissFetchHealthRecordsViewControllerIfNeeded() {
//        guard let vcs = self.navigationController?.viewControllers.compactMap({$0 as? FetchHealthRecordsViewController}),
//              let vc = vcs.first else {return}
//        popBack(toControllerType: HealthRecordsViewController.self)
//    }

    func showFetchVC(hasHealthRecords: Bool) {
        // Leaving this for now, but I feel like this logic in setup function can get removed now with the check added in tab bar controller
        let vc = FetchHealthRecordsViewController.constructFetchHealthRecordsViewController(hideNavBackButton: true, showSettingsIcon: true, hasHealthRecords: hasHealthRecords, completion: {})
        lastPatientSelected = nil
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    func showRecords(for patient: Patient, animated: Bool, navStyle: UsersListOfRecordsViewController.NavStyle, authenticated: Bool, hasUpdatedUnauthPendingTest: Bool) {
        let vc = UsersListOfRecordsViewController.constructUsersListOfRecordsViewController(patient: patient, authenticated: authenticated, navStyle: navStyle, hasUpdatedUnauthPendingTest: hasUpdatedUnauthPendingTest)
        lastPatientSelected = patient
        self.navigationController?.pushViewController(vc, animated: animated)
    }
    
    // MARK: Helpers
    func selected(data: HealthRecordsDataSource) {
        let patient = data.patient

        if authManager.isAuthenticated {
            closeRecordWhenAuthExpires(patient: patient)
        }
        showRecords(for: patient, animated: true, navStyle: .multiUser, authenticated: data.authenticated, hasUpdatedUnauthPendingTest: false)
    }
    
    func closeRecordWhenAuthExpires(patient: Patient) {
        lastPatientSelected = patient
        Notification.Name.refreshTokenExpired.onPost(object: nil, queue: .main) {[weak self] _ in
            guard let `self` = self, patient == self.lastPatientSelected else {return}
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
}

// MARK: Navigation setup
extension HealthRecordsViewController {
    private func navSetup() {
        self.navDelegate?.setNavigationBarWith(title: .healthRecords,
                                               leftNavButton: nil,
                                               rightNavButton: NavButton(image: UIImage(named: "nav-settings"), action: #selector(self.settingsButton), accessibility: Accessibility(traits: .button, label: AccessibilityLabels.MyHealthPassesScreen.navRightIconTitle, hint: AccessibilityLabels.MyHealthPassesScreen.navRightIconHint)),
                                               navStyle: .large,
                                               navTitleSmallAlignment: .Center,
                                               targetVC: self,
                                               backButtonHintString: nil)
        
        
    }
}

// MARK: Add Record Header Setup
extension HealthRecordsViewController: AddCardsTableViewCellDelegate {
    private func addRecordHeaderSetup() {
        addRecordView.configureForHealthRecords(delegateOwner: self)
    }
    
    func addCardButtonTapped(screenType: ReusableHeaderAddView.ScreenType) {
        if screenType == .healthRecords {
            let vc = FetchHealthRecordsViewController.constructFetchHealthRecordsViewController(hideNavBackButton: false, showSettingsIcon: false, hasHealthRecords: !self.dataSource.isEmpty, completion: {})
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

// MARK: Collection View setup
extension HealthRecordsViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    private func setupCollectionView() {
        collectionView.register(UINib.init(nibName: HealthRecordsUserCollectionViewCell.getName, bundle: .main), forCellWithReuseIdentifier: HealthRecordsUserCollectionViewCell.getName)
        let layout = UICollectionViewFlowLayout()
        // TODO: Need to test this on larger screen sizes, as this works on SE - then add values to constants file
        // FIXME: Name label doesnt quite fit for anything other than short names - also weird UI issue when returning to screen
        layout.minimumLineSpacing = spacingPerItem
        layout.sectionInset = UIEdgeInsets(top: 0, left: spacingPerItem, bottom: 0, right: spacingPerItem)
        layout.itemSize =  defaultCellSize()
        collectionView.collectionViewLayout = layout
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func defaultCellSize() -> CGSize {
        let itemsPerRow: CGFloat = 2
        let maxCellHeight: CGFloat = 140
        let availableWidth = UIScreen.main.bounds.width
        var width: CGFloat = (availableWidth / itemsPerRow) - (spacingPerItem * itemsPerRow)
        width += (spacingPerItem/itemsPerRow)
        let maxHeightNeededForNames = dataSource.map({$0.patient.name ?? ""}).maxHeightNeeded(width: width, font: HealthRecordsUserView.nameFont)
        let height: CGFloat = maxHeightNeededForNames >= maxCellHeight ? maxHeightNeededForNames : maxCellHeight
        return CGSize(width: width, height: height)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let defaultSize = defaultCellSize()
        return defaultSize
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let numberCells = dataSource.count % 2 == 0 ? dataSource.count : dataSource.count + 1
        return numberCells
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == dataSource.count {
            // This means that we load the empty cell
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmptyCollectionCell", for: indexPath)
            return cell
        } else if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HealthRecordsUserCollectionViewCell.getName, for: indexPath) as? HealthRecordsUserCollectionViewCell {
            cell.configure(data: dataSource[indexPath.row])
            cell.layoutIfNeeded()
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.row < dataSource.count else { return }
        let data = dataSource[indexPath.row]
        selected(data: data)
    }
}

// MARK: Function to go to user records view controller
extension HealthRecordsViewController {
    func setPatientToShow(patient: Patient) {
        authenticatedPatientToShow = patient
    }
    
    private func goToUserRecordsViewControllerForPatient(_ patient: Patient) {
        if let index = dataSource.firstIndex(where: { $0.patient == patient }) {
            let data = dataSource[index]
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.selected(data: data)
                self.authenticatedPatientToShow = nil
            }
        }
    }
}
