//
//  HealthRecordsViewController.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-11-10.
//
//TODO: This will have a collection view that will display a users name. Above the collection view is the header add view

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
            // TODO: Go to FetchHealthRecordsViewController here
        }
    }
}

// MARK: Fetch Data Source
extension HealthRecordsViewController {
    private func fetchDataSource() {
        dataSource = StorageService.shared.getHealthRecordsDataSource()
        if dataSource.isEmpty {
            // TODO: Go to FetchHealthRecordsViewController
        } else {
            addRecordHeaderSetup()
            setupCollectionView()
        }
        
    }
}

// MARK: Collection View setup
extension HealthRecordsViewController {
    private func setupCollectionView() {
        // TODO: Collection view setup logic
    }
}
