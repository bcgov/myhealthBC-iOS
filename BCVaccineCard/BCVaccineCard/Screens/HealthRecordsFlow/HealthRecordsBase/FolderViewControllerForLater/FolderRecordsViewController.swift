//
//  FolderRecordsViewController.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-11-10.

import UIKit
// NOTE: This View Controller is currently not being used, but we will be using it (or at least components of it) down the line. Leaving for now
class FolderRecordsViewController: BaseViewController {
    
    class func constructFolderRecordsViewController() -> FolderRecordsViewController {
        if let vc = Storyboard.records.instantiateViewController(withIdentifier: String(describing: FolderRecordsViewController.self)) as? FolderRecordsViewController {
            return vc
        }
        return FolderRecordsViewController()
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
        self.addRecordHeaderSetup()
        self.setupCollectionView()
        collectionView.reloadData()
    }
    
    
    // MARK: Data
    private func refreshOnStorageChange() {
        Notification.Name.storageChangeEvent.onPost(object: nil, queue: .main) {[weak self] notification in
            guard let `self` = self, let event = notification.object as? StorageService.StorageEvent<Any> else {return}
            self.loadDataAndSetInitialVC()
        }
    }
    
    private func fetchData() -> [HealthRecord] {
        StorageService.shared.getHeathRecords()
    }
    
    // Note: stack will be set from router worker (keep this function only for "selected" function below
    private func showRecords(for patient: Patient, animated: Bool, navStyle: UsersListOfRecordsViewController.NavStyle, authenticated: Bool, hasUpdatedUnauthPendingTest: Bool) {
        let vc = UsersListOfRecordsViewController.constructUsersListOfRecordsViewController(patient: patient, authenticated: authenticated, navStyle: navStyle, hasUpdatedUnauthPendingTest: hasUpdatedUnauthPendingTest)
        lastPatientSelected = patient
        self.navigationController?.pushViewController(vc, animated: animated)
    }
    
    // MARK: Helpers
    private func selected(data: HealthRecordsDataSource) {
        let patient = data.patient

        if authManager.isAuthenticated {
            closeRecordWhenAuthExpires(patient: patient)
        }
        showRecords(for: patient, animated: true, navStyle: .multiUser, authenticated: data.authenticated, hasUpdatedUnauthPendingTest: false)
    }
    
    private func closeRecordWhenAuthExpires(patient: Patient) {
        lastPatientSelected = patient
        Notification.Name.refreshTokenExpired.onPost(object: nil, queue: .main) {[weak self] _ in
            guard let `self` = self, patient == self.lastPatientSelected else {return}
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
}

// MARK: Navigation setup
extension FolderRecordsViewController {
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
extension FolderRecordsViewController: AddCardsTableViewCellDelegate {
    private func addRecordHeaderSetup() {
        addRecordView.configureForHealthRecords(delegateOwner: self)
    }
    
    // TODO: CONNOR: Remove this
    func addCardButtonTapped(screenType: ReusableHeaderAddView.ScreenType) {
        if screenType == .healthRecords {
            // Leaving for now
        }
    }
}

// MARK: Collection View setup
extension FolderRecordsViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    private func setupCollectionView() {
        collectionView.register(UINib.init(nibName: HealthRecordsUserCollectionViewCell.getName, bundle: .main), forCellWithReuseIdentifier: HealthRecordsUserCollectionViewCell.getName)
        let layout = UICollectionViewFlowLayout()
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
