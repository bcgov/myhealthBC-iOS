//
//  HealthRecordDetailViewController.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-11-29.
// TODO: This view controller will be a table view with "Delete" in the navigation bar, and will be customizable depending on what the record is, etc. Will likely use an enum here for imm record, or test result

import UIKit


class HealthRecordDetailViewController: BaseViewController {
    
    class func constructHealthRecordDetailViewController(dataSource: HealthRecordsDetailDataSource, authenticatedRecord: Bool, userNumberHealthRecords: Int) -> HealthRecordDetailViewController {
        if let vc = Storyboard.records.instantiateViewController(withIdentifier: String(describing: HealthRecordDetailViewController.self)) as? HealthRecordDetailViewController {
            vc.dataSource = dataSource
            vc.authenticatedRecord = authenticatedRecord
            vc.userNumberHealthRecords = userNumberHealthRecords
            return vc
        }
        return HealthRecordDetailViewController()
    }
    
    @IBOutlet weak private var tableView: UITableView!
    
    private var dataSource: HealthRecordsDetailDataSource!
    private var authenticatedRecord: Bool!
    private var userNumberHealthRecords: Int!
    private var pdfData: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navSetup()
        setupStorageListener()
    }
    
    // TODO: We should look into this - not sure we should pop to root VC from detail view on a storage change
    func setupStorageListener() {
        Notification.Name.storageChangeEvent.onPost(object: nil, queue: .main) { [weak self] notification in
            guard let `self` = self else {return}
            if let event = notification.object as? StorageService.StorageEvent<Any> {
                switch event.entity {
                case .VaccineCard :
                    if let object = event.object as? VaccineCard, object.patient?.name == self.dataSource.name {
                        self.navigationController?.popToRootViewController(animated: true)
                    }
                    // Note: Check this - this appears to be where the issue is - will have to check lines below, as this appears to be what's causing the issue
                case .CovidLabTestResult:
                    if let object = event.object as? CovidLabTestResult, object.patient?.name == self.dataSource.name {
                        guard event.event != .ManuallyAddedPendingTestBackgroundRefetch else { return }
                        self.navigationController?.popToRootViewController(animated: true)
                    }
                case .Medication:
                    if let object = event.object as? Perscription, object.patient?.name == self.dataSource.name {
                        self.navigationController?.popToRootViewController(animated: true)
                    }
                case .LaboratoryOrder:
                    if let object = event.object as? LaboratoryOrder, object.patient?.name == self.dataSource.name {
                        self.navigationController?.popToRootViewController(animated: true)
                    }
                default:
                    break
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setNeedsStatusBarAppearanceUpdate()
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
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
        var rightNavButton: NavButton?
        switch dataSource.type {
        case .laboratoryOrder(model: let labOrder):
            if let pdf = labOrder.pdf {
                self.pdfData = pdf
                rightNavButton = NavButton(image: UIImage(named: "nav-download"), action: #selector(self.showPDFView), accessibility: Accessibility(traits: .button, label: AccessibilityLabels.HealthRecordsDetailScreen.navRightIconTitlePDF, hint: AccessibilityLabels.HealthRecordsDetailScreen.navRightIconHintPDF))
            }
        default:
            rightNavButton = self.authenticatedRecord ? nil :
            NavButton(
                title: .delete,
                image: nil, action: #selector(self.deleteButton),
                accessibility: Accessibility(traits: .button, label: AccessibilityLabels.HealthRecordsDetailScreen.navRightIconTitle, hint: AccessibilityLabels.HealthRecordsDetailScreen.navRightIconHint))
        }
        
        self.navDelegate?.setNavigationBarWith(title: dataSource.title,
                                               leftNavButton: nil,
                                               rightNavButton: rightNavButton,
                                               navStyle: .small,
                                               navTitleSmallAlignment: .Center,
                                               targetVC: self,
                                               backButtonHintString: nil)
    }
    
    @objc private func deleteButton(manuallyAdded: Bool) {
        alertConfirmation(title: dataSource.deleteAlertTitle, message: dataSource.deleteAlertMessage, confirmTitle: .delete, confirmStyle: .destructive) {
            [weak self] in
            guard let `self` = self else {return}
            switch self.dataSource.type {
            case .covidImmunizationRecord(model: let model, immunizations: _):
                StorageService.shared.deleteVaccineCard(vaccineQR: model.code, manuallyAdded: manuallyAdded)
                self.routerWorker?.routingAction(scenario: .ManuallyDeletedAllOfAnUnauthPatientRecords(affectedTabs: [.healthPass]))
            case .covidTestResultRecord:
                guard let recordId = self.dataSource.id else {return}
                StorageService.shared.deleteCovidTestResult(id: recordId, sendDeleteEvent: true)
            case .medication, .laboratoryOrder:
                print("Not able to delete these records currently, as they are auth-only records")
            }
            if self.userNumberHealthRecords > 1 {
                self.navigationController?.popViewController(animated: true)
            } else {
                self.routerWorker?.routingAction(scenario: .ManuallyDeletedAllOfAnUnauthPatientRecords(affectedTabs: [.records]))
            }
        } onCancel: {
        }
    }
    
    @objc private func showPDFView() {
        guard let pdf = self.pdfData else { return }
        self.showPDFDocument(pdfString: pdf, navTitle: dataSource.title, documentVCDelegate: self, navDelegate: self.navDelegate)
    }
}

// MARK: This is for showing the PDF view using native behaviour
extension HealthRecordDetailViewController: UIDocumentInteractionControllerDelegate {
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        guard let navController = self.navigationController else { return self }
        return navController
    }
}
