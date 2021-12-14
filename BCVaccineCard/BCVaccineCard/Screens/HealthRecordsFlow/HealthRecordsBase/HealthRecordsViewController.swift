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
        setup()
        setupCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateData()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            return UIStatusBarStyle.darkContent
        } else {
            return UIStatusBarStyle.default
        }
    }
 
    private func setup() {
        navSetup()
        fetchData { [weak self] records in
            guard let `self` = self else {return}
            self.dataSource = records.dataSource()
            if self.dataSource.isEmpty {
                let vc = FetchHealthRecordsViewController.constructFetchHealthRecordsViewController()
                self.navigationController?.pushViewController(vc, animated: false)
            } else {
                self.addRecordHeaderSetup()
                self.setupCollectionView()
            }
        }
    }
    
    private func updateData() {
        fetchData { [weak self] records in
            guard let `self` = self else {return}
            self.dataSource = records.dataSource()
            self.addRecordHeaderSetup()
            self.collectionView.reloadData()
            if self.dataSource.isEmpty {
                let vc = FetchHealthRecordsViewController.constructFetchHealthRecordsViewController()
                self.navigationController?.pushViewController(vc, animated: false)
            }
        }
    }
    
    private func fetchData(completion: @escaping([HealthRecord])-> Void) {
        view.startLoadingIndicator(backgroundColor: .white)
        StorageService.shared.getHeathRecords {[weak self] records in
            guard let `self` = self else {return}
            self.view.endLoadingIndicator()
            return completion(records)
        }
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

// MARK: Collection View setup
extension HealthRecordsViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    private func setupCollectionView() {
        collectionView.register(UINib.init(nibName: HealthRecordsUserCollectionViewCell.getName, bundle: .main), forCellWithReuseIdentifier: HealthRecordsUserCollectionViewCell.getName)
        let layout = UICollectionViewFlowLayout()
        // TODO: Need to test this on larger screen sizes, as this works on SE - then add values to constants file
        // FIXME: Name label doesnt quite fit for anything other than short names - also weird UI issue when returning to screen
        let spacingPerItem: CGFloat = 10
        let itemsPerRow: CGFloat = 2
        let maxCellHeight: CGFloat = 130
        let availableWidth = UIScreen.main.bounds.width
        var width: CGFloat = (availableWidth / itemsPerRow) - (spacingPerItem * itemsPerRow)
        width += (spacingPerItem/itemsPerRow)
        let maxHeightNeededForNames = dataSource.map({$0.userName}).maxHeightNeeded(width: width, font: HealthRecordsUserView.nameFont)
        let height: CGFloat = maxHeightNeededForNames >= maxCellHeight ? maxHeightNeededForNames : maxCellHeight
        
        layout.minimumLineSpacing = spacingPerItem
        layout.sectionInset = UIEdgeInsets(top: 0, left: spacingPerItem, bottom: 0, right: spacingPerItem)
        layout.itemSize =  CGSize(width: width, height: height)
        collectionView.collectionViewLayout = layout
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
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
        let userName = dataSource[indexPath.row].userName
        let vc = UsersListOfRecordsViewController.constructUsersListOfRecordsViewController(name: userName)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let availabelWidth = collectionView.frame.width
//        let widthPerItem = availabelWidth / 2.0
//        let heightPerItem = widthPerItem * (118.0/152.0)
//        return CGSize(width: widthPerItem, height: heightPerItem)
//    }
    
    
}
