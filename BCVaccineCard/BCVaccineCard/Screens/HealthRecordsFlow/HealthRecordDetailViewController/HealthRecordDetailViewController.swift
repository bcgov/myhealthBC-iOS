//
//  HealthRecordDetailViewController.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-11-29.
// TODO: This view controller will be a table view with "Delete" in the navigation bar, and will be customizable depending on what the record is, etc. Will likely use an enum here for imm record, or test result

import UIKit


class HealthRecordDetailViewController: BaseViewController {
    
    class func constructHealthRecordDetailViewController(dataSource: HealthRecordsDetailDataSource, userNumberHealthRecords: Int, source: GatewayData) -> HealthRecordDetailViewController {
        if let vc = Storyboard.records.instantiateViewController(withIdentifier: String(describing: HealthRecordDetailViewController.self)) as? HealthRecordDetailViewController {
            vc.dataSource = dataSource
            vc.userNumberHealthRecords = userNumberHealthRecords
            vc.source = source
            return vc
        }
        return HealthRecordDetailViewController()
    }
    
    @IBOutlet weak private var tableView: UITableView!
    
    private var dataSource: HealthRecordsDetailDataSource!
    private var userNumberHealthRecords: Int!
    private var source: GatewayData!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setNeedsStatusBarAppearanceUpdate()
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setupContent()
        super.viewDidAppear(animated)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            return UIStatusBarStyle.darkContent
        } else {
            return UIStatusBarStyle.default
        }
    }
    
    func setupContent() {
        let recordsView: HealthRecordsView = HealthRecordsView()
        recordsView.frame = .zero
        recordsView.bounds = view.bounds
        view.addSubview(recordsView)
        recordsView.layoutIfNeeded()
        recordsView.addEqualSizeContraints(to: self.view, safe: true)
        // Note: keep this here so the child views in HealthRecordsView get sized properly
        view.layoutSubviews()
        recordsView.configure(models: dataSource.records)
        view.layoutSubviews()
    }
    
}

// MARK: Navigation setup
extension HealthRecordDetailViewController {
    private func navSetup() {
        let rightNavButton = NavButton(
            title: .delete,
            image: nil, action: #selector(self.deleteButton),
            accessibility: Accessibility(traits: .button, label: AccessibilityLabels.HealthRecordsDetailScreen.navRightIconTitle, hint: AccessibilityLabels.HealthRecordsDetailScreen.navRightIconHint))
        
        self.navDelegate?.setNavigationBarWith(title: dataSource.title,
                                               leftNavButton: nil,
                                               rightNavButton: rightNavButton,
                                               navStyle: .small,
                                               targetVC: self,
                                               backButtonHintString: nil)
//        if source.fromGateway {
//            self.navigationController?.delegate = self
//        }
    }
    
    @objc private func deleteButton() {
        alertConfirmation(title: dataSource.deleteAlertTitle, message: dataSource.deleteAlertMessage, confirmTitle: .delete, confirmStyle: .destructive) {
            [weak self] in
            guard let `self` = self else {return}
            switch self.dataSource.type {
            case .covidImmunizationRecord(model: let model, immunizations: _):
                StorageService.shared.deleteVaccineCard(vaccineQR: model.code)
            case .covidTestResultRecord:
                guard let recordId = self.dataSource.id else {return}
                StorageService.shared.deleteTestResult(id: recordId)
            }
            if self.userNumberHealthRecords > 1 {
                self.navigationController?.popViewController(animated: true)
            } else {
                self.popBack(toControllerType: HealthRecordsViewController.self)
            }
        } onCancel: {
        }
    }
}

//extension HealthRecordDetailViewController: UINavigationControllerDelegate {
//    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
//        if let name = source.details?.name, let birthday = source.details?.dob {
//            var navStack: [UIViewController] = []
//            guard let firstVC = navigationController.viewControllers.first else { return }
//            navStack.append(firstVC)
//            var containsUserRecordsVC = false
//            for (_, vc) in navigationController.viewControllers.enumerated() {
//                if vc is UsersListOfRecordsViewController {
//                    containsUserRecordsVC = true
//                }
//            }
//            if containsUserRecordsVC == false {
//                let birthDate = Date.Formatter.yearMonthDay.date(from: birthday)
//                let secondVC = UsersListOfRecordsViewController.constructUsersListOfRecordsViewController(name: name, birthdate: birthDate)
//                navStack.append(secondVC)
//            }
//            let thirdVC = viewController
//            navStack.append(thirdVC)
//            navigationController.setViewControllers(navStack, animated: false)
//            print("")
////            for (index, vc) in navigationController.viewControllers.enumerated() {
////                if vc is GatewayFormViewController {
////                    navigationController.viewControllers.remove(at: index)
////                }
////            }
////            for (index, vc) in navigationController.viewControllers.enumerated() {
////                if vc is FetchHealthRecordsViewController {
////                    navigationController.viewControllers.remove(at: index)
////                }
////            }
//        }
//    }
//}

struct GatewayData {
    let details: GatewayFormCompletionHandlerDetails?
    let fromGateway: Bool
}
