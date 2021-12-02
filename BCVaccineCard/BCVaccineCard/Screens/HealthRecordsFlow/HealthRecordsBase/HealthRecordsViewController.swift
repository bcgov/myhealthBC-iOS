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
    
    @IBOutlet weak private var addRecordView: ReusableHeaderAddView!
    @IBOutlet weak private var collectionView: UICollectionView!
    
    private var dataSource: [HealthRecordsDataSource] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
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
        fetchDataSource()
    }

}

// MARK: Navigation setup
extension HealthRecordsViewController {
    private func navSetup() {
        self.navDelegate?.setNavigationBarWith(title: .healthRecords,
                                               leftNavButton: nil,
                                               rightNavButton: nil,
                                               navStyle: .large,
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
            let vc = FetchHealthRecordsViewController.constructFetchHealthRecordsViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

// MARK: Fetch Data Source
extension HealthRecordsViewController {
    private func fetchDataSource() {
        dataSource = StorageService.shared.getHeathRecords().dataSource()
        if dataSource.isEmpty {
            let vc = FetchHealthRecordsViewController.constructFetchHealthRecordsViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            addRecordHeaderSetup()
            setupCollectionView()
        }
        
    }
}

// MARK: Collection View setup
extension HealthRecordsViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    private func setupCollectionView() {
        collectionView.register(UINib.init(nibName: HealthRecordsUserCollectionViewCell.getName, bundle: .main), forCellWithReuseIdentifier: HealthRecordsUserCollectionViewCell.getName)
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HealthRecordsUserCollectionViewCell.getName, for: indexPath) as? HealthRecordsUserCollectionViewCell {
            cell.configure(data: dataSource[indexPath.row])
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let userName = dataSource[indexPath.row].userName
        let vc = UsersListOfRecordsViewController.constructUsersListOfRecordsViewController(name: userName)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availabelWidth = view.frame.width - 40
        let widthPerItem = availabelWidth / 2.0
        let heightPerItem = widthPerItem * (118.0/152.0)
        return CGSize(width: widthPerItem, height: heightPerItem)
    }
    
    
}
