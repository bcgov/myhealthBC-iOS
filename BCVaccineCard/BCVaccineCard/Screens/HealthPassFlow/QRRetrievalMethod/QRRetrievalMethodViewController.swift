//
//  QRRetrievalMethodViewController.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-09-16.
//

//FIXME: CONNOR: - Ready To Test: Adjust this entire file to properly use Router Worker

import UIKit
import BCVaccineValidator
import SwiftUI

class QRRetrievalMethodViewController: BaseViewController {
    
    class func constructQRRetrievalMethodViewController() -> QRRetrievalMethodViewController {
        if let vc = Storyboard.healthPass.instantiateViewController(withIdentifier: String(describing: QRRetrievalMethodViewController.self)) as? QRRetrievalMethodViewController {
//            vc.backScreenString = backScreenString
            return vc
        }
        return QRRetrievalMethodViewController()
    }
    
    enum CellType {
        case text(text: String), image(image: UIImage), method(type: TableViewButtonView.ButtonType, style: TableViewButtonView.ButtonStyle)
    }
    
    @IBOutlet weak private var tableView: UITableView!
    private var dataSource: [CellType] = []
//    private var backScreenString: String!
    
    private var ImagePickerCallback: ((_ image: UIImage?)->(Void))? = nil
    private weak var imagePicker: UIImagePickerController? = nil
    
    override var getPassesFlowType: PassesFlowVCs? {
        return .QRRetrievalMethodViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
        // Calling this again, just in case - don't want any users to be stuck in a weird state where the tab bar isn't shown
        self.tabBarController?.tabBar.isHidden = false
        navSetup()
        self.tableView.contentInsetAdjustmentBehavior = .never
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
        setupDataSource()
        setupTableView()
    }
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Going to camera
        if let destination = segue.destination as? CameraViewController {
            destination.setup { [weak self] result in
                guard let `self` = self, let data = result else {return}
                self.storeValidatedQRCode(data: data, source: .scanner)
            }
        }
    }
}

// MARK: Navigation setup
extension QRRetrievalMethodViewController {
    private func navSetup() {
        self.navDelegate?.setNavigationBarWith(title: .addAHealthPass,
                                               leftNavButton: nil,
                                               rightNavButton: nil,
                                               navStyle: .small,
                                               navTitleSmallAlignment: .Center,
                                               targetVC: self,
                                               backButtonHintString: .healthPasses)
    }
}

// MARK: Data Source Setup
extension QRRetrievalMethodViewController {
    private func setupDataSource() {
        self.dataSource = [
            .text(text: .qrDescriptionText),
            .image(image: #imageLiteral(resourceName: "options-screen-image")),
            .method(type: .goToUploadImage, style: .blue),
            .method(type: .goToCameraScan, style: .white),
            .method(type: .goToEnterGateway, style: .white)
        ]
    }
}

// MARK: Table View Logic
extension QRRetrievalMethodViewController: UITableViewDelegate, UITableViewDataSource {
    private func setupTableView() {
        tableView.register(UINib.init(nibName: TextTableViewCell.getName, bundle: .main), forCellReuseIdentifier: TextTableViewCell.getName)
        tableView.register(UINib.init(nibName: ImageTableViewCell.getName, bundle: .main), forCellReuseIdentifier: ImageTableViewCell.getName)
        tableView.register(UINib.init(nibName: QRSelectionTableViewCell.getName, bundle: .main), forCellReuseIdentifier: QRSelectionTableViewCell.getName)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = dataSource[indexPath.row]
        switch data {
        case .text(text: let text):
            if let cell = tableView.dequeueReusableCell(withIdentifier: TextTableViewCell.getName, for: indexPath) as? TextTableViewCell {
                cell.configure(forType: .plainText, text: text, withFont: UIFont.bcSansRegularWithSize(size: 17), labelSpacingAdjustment: 0)
                return cell
            }
        case .image(image: let image):
            if let cell = tableView.dequeueReusableCell(withIdentifier: ImageTableViewCell.getName, for: indexPath) as? ImageTableViewCell {
                cell.configure(image: image)
                return cell
            }
        case .method(type: let type, style: let style):
            if let cell = tableView.dequeueReusableCell(withIdentifier: QRSelectionTableViewCell.getName, for: indexPath) as? QRSelectionTableViewCell {
                cell.configure(withStyle: style, buttonType: type)
                cell.isAccessibilityElement = true
                cell.accessibilityTraits = .button
                cell.accessibilityLabel = "\(type.getTitle)"
                cell.accessibilityHint = "\(type.accessibilityHint)"
                return cell
            }
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let data = dataSource[indexPath.row]
        switch data {
        case .text: return Constants.UI.CellSpacing.QROptionsScreen.staticText
        case .image:
            let buffer: CGFloat = 20
            let occupied = Constants.UI.CellSpacing.QROptionsScreen.staticText + (3 * Constants.UI.CellSpacing.QROptionsScreen.optionButtonHeight) + buffer
            return tableView.bounds.height - occupied
            
        case .method: return Constants.UI.CellSpacing.QROptionsScreen.optionButtonHeight
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = dataSource[indexPath.row]
        switch item {
        case .text, .image: return
        case .method(type: let type, style: _):
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            // The delay is necessary for the haptic feedback to occur immediately.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                switch type {
                case .goToEnterGateway:
                    self.goToEnterGateway()
                case .goToCameraScan:
                    self.goToCameraScan()
                case .goToUploadImage:
                    self.goToUploadImage()
                }
            }
            
        }
    }
}

// MARK: Table View Button Methods
extension QRRetrievalMethodViewController {
    func authenticateBeforeDisplayingGatewayForm() {
        if !AuthManager().isAuthenticated {
            showLogin(initialView: .Landing, sourceVC: .QRRetrievalVC, completion: {[weak self] authenticationStatus in
                guard let `self` = self else {return}
                if authenticationStatus != .Completed {
                    self.goToEnterGateway()
                } else {
                    let recordFlowDetails = RecordsFlowDetails(currentStack: self.getCurrentStacks.recordsStack)
                    let passesFlowDetails = PassesFlowDetails(currentStack: self.getCurrentStacks.passesStack)
                    let scenario = AppUserActionScenarios.LoginSpecialRouting(values: ActionScenarioValues(currentTab: .healthPass, recordFlowDetails: recordFlowDetails, passesFlowDetails: passesFlowDetails, loginSourceVC: .QRRetrievalVC, authenticationStatus: authenticationStatus))
                    self.routerWorker?.routingAction(scenario: scenario, delayInSeconds: 0.5)
                }
            })
        } else {
            goToEnterGateway()
        }
    }
    //FIXME: CONNOR: - Ready To Test: Adjust this function - stack will be set from router worker
    func goToEnterGateway() {
        // TODO: Should look at refactoring this a bit
        var rememberDetails = RememberedGatewayDetails(storageArray: nil)
        if let details = Defaults.rememberGatewayDetails {
            rememberDetails = details
        }
        let vc = GatewayFormViewController.constructGatewayFormViewController(rememberDetails: rememberDetails, fetchType: .bcVaccineCardAndFederalPass)
        vc.completionHandler = { [weak self] details in
            guard let `self` = self else { return }
            DispatchQueue.main.async {  [weak self] in
                guard let `self` = self else { return }
                self.view.accessibilityElementsHidden = true
                self.tableView.accessibilityElementsHidden = true
                self.view.isAccessibilityElement = false
                self.tableView.isAccessibilityElement = false
                AnalyticsService.shared.track(action: .AddQR, text: .Get)
//                self.popBackToProperViewController(id: details.id)
                DispatchQueue.main.async {
//                    self.routerWorker?.routingAction(scenario: .ManualFetch(actioningPatient: details.patient, addedRecord: nil, recentlyAddedCardId: details.id, fedPassStringToOpen: nil, fedPassAddedFromHealthPassVC: nil))
                    
                    let recordFlowDetails = RecordsFlowDetails(currentStack: self.getCurrentStacks.recordsStack, actioningPatient: details.patient, addedRecord: nil)
                    let passesFlowDetails = PassesFlowDetails(currentStack: self.getCurrentStacks.passesStack, recentlyAddedCardId: details.id, fedPassStringToOpen: nil, fedPassAddedFromHealthPassVC: nil)
                    let values = ActionScenarioValues(currentTab: self.getCurrentTab, recordFlowDetails: recordFlowDetails, passesFlowDetails: passesFlowDetails)
                    self.routerWorker?.routingAction(scenario: .ManualFetch(values: values))
                }
                
            }
        }
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func goToCameraScan() {
        performSegue(withIdentifier: "showCamera", sender: self)
    }
    
    func goToUploadImage() {
        showImagePicker { [weak self] image in
            guard let `self` = self, let image = image else {return}
            guard let codes = image.findQRCodes(), !codes.isEmpty else {
                self.alert(title: .noQRFound, message: "")
                return
            }
            guard codes.count == 1, let code = codes.first else {
                self.alert(title: .multipleQRCodesTitle, message: .multipleQRCodesMessage)
                return
            }
            
            BCVaccineValidator.shared.validate(code: code.lowercased()) { [weak self] result in
                guard let `self` = self else { return }
                guard let data = result.result else {
                    self.alert(title: .invalidQRCodeMessage, message: "")
                    return
                }
                DispatchQueue.main.async { [weak self] in
                    guard let `self` = self else {return}
                    self.storeValidatedQRCode(data: data, source: .imported)
                }
                
            }
        }
    }
    // TODO: Need to verify this logic here
    private func storeValidatedQRCode(data: ScanResultModel, source: Source) {
        switch source {
        case .healthGateway:
            AnalyticsService.shared.track(action: .AddQR, text: .Get)
        case .scanner:
            AnalyticsService.shared.track(action: .AddQR, text: .Scan)
        case .imported:
            AnalyticsService.shared.track(action: .AddQR, text: .Upload)
        }
        let model = convertScanResultModelIntoLocalData(data: data, source: source).transform()
        model.state { [weak self] state in
            guard let `self` = self else {return}
            switch state {
            case .exists, .isOutdated:
                self.alert(title: .duplicateTitle, message: .duplicateMessage) { [weak self] in
                    guard let `self` = self else {return}
                    self.navigationController?.popViewController(animated: true)
//                    DispatchQueue.main.async {
////                        self.routerWorker?.routingAction(scenario: <#T##AppUserActionScenarios#>)
//                    }
                        // TODO: Create another scenario for going to a record that already exists
                }
            case .isNew:
                self.storeVaccineCard(model: model.transform(), authenticated: false, manuallyAdded: true, completion: { [weak self] coreDataReturnObject in
                    DispatchQueue.main.async {[weak self] in
                        guard let self = self else {return}
                        // TODO: Maybe show this on tab bar controller instead?
                        self.tabBarController?.showBanner(message: .vaxAddedBannerAlert, style: .Top)
                        //                        self.navigationController?.showBanner(message: .vaxAddedBannerAlert, style: .Top)
                        //                        self.popBackToProperViewController(id: model.id ?? "")
//                        self.routerWorker?.routingAction(scenario: .ManualFetch(actioningPatient: coreDataReturnObject.patient, addedRecord: nil, recentlyAddedCardId: coreDataReturnObject.id, fedPassStringToOpen: nil, fedPassAddedFromHealthPassVC: nil))
                        
                        let recordFlowDetails = RecordsFlowDetails(currentStack: self.getCurrentStacks.recordsStack, actioningPatient: coreDataReturnObject.patient, addedRecord: nil)
                        let passesFlowDetails = PassesFlowDetails(currentStack: self.getCurrentStacks.passesStack, recentlyAddedCardId: coreDataReturnObject.id, fedPassStringToOpen: nil, fedPassAddedFromHealthPassVC: nil)
                        let values = ActionScenarioValues(currentTab: self.getCurrentTab, recordFlowDetails: recordFlowDetails, passesFlowDetails: passesFlowDetails)
                        self.routerWorker?.routingAction(scenario: .ManualFetch(values: values))
                    }
                })
            case .canUpdateExisting:
                self.alert(title: .updatedCard, message: "\(String.updateCardFor) \(model.transform().name)", buttonOneTitle: "Yes", buttonOneCompletion: { [weak self] in
                    guard let `self` = self else {return}
                    self.updateCardInLocalStorage(model: model.transform(), manuallyAdded: true, completion: { [weak self] coreDataReturnObject in
                        guard let `self` = self else {return}
                        DispatchQueue.main.async {
//                            self.routerWorker?.routingAction(scenario: .ManualFetch(actioningPatient: coreDataReturnObject.patient, addedRecord: nil, recentlyAddedCardId: coreDataReturnObject.id, fedPassStringToOpen: nil, fedPassAddedFromHealthPassVC: nil))
                            let recordFlowDetails = RecordsFlowDetails(currentStack: self.getCurrentStacks.recordsStack, actioningPatient: coreDataReturnObject.patient, addedRecord: nil)
                            let passesFlowDetails = PassesFlowDetails(currentStack: self.getCurrentStacks.passesStack, recentlyAddedCardId: coreDataReturnObject.id, fedPassStringToOpen: nil, fedPassAddedFromHealthPassVC: nil)
                            let values = ActionScenarioValues(currentTab: self.getCurrentTab, recordFlowDetails: recordFlowDetails, passesFlowDetails: passesFlowDetails)
                            self.routerWorker?.routingAction(scenario: .ManualFetch(values: values))
                        }
                    })
                }, buttonTwoTitle: "No") { [weak self] in
                    guard let `self` = self else {return}
                    //                    self.navigationController?.popViewController(animated: true)
//                    DispatchQueue.main.async {
//                        self.popBackToProperViewController(id: model.id ?? "")
//                    }
                    // Note: May need to look into this and see if we require something else
                    self.navigationController?.popViewController(animated: true)
                }
            case .UpdatedFederalPass:
                self.updateFedCodeForCardInLocalStorage(model: model.transform(), manuallyAdded: true) { [weak self] coreDataReturnObject in
                    guard let self = self else {return}
                    DispatchQueue.main.async {[weak self] in
                        guard let self = self else {return}
                        self.tabBarController?.showBanner(message: .vaxAddedBannerAlert, style: .Top)
//                        self.routerWorker?.routingAction(scenario: .ManualFetch(actioningPatient: coreDataReturnObject.patient, addedRecord: nil, recentlyAddedCardId: coreDataReturnObject.id, fedPassStringToOpen: nil, fedPassAddedFromHealthPassVC: nil))
                        // TODO: Double check this flow here - may need to adjust to show federal pass
                        let recordFlowDetails = RecordsFlowDetails(currentStack: self.getCurrentStacks.recordsStack, actioningPatient: coreDataReturnObject.patient, addedRecord: nil)
                        let passesFlowDetails = PassesFlowDetails(currentStack: self.getCurrentStacks.passesStack, recentlyAddedCardId: coreDataReturnObject.id, fedPassStringToOpen: nil, fedPassAddedFromHealthPassVC: nil)
                        let values = ActionScenarioValues(currentTab: self.getCurrentTab, recordFlowDetails: recordFlowDetails, passesFlowDetails: passesFlowDetails)
                        self.routerWorker?.routingAction(scenario: .ManualFetch(values: values))
                    }
                }
                
            }
        }
    }
}

// MARK: Logic for handling what screen to go back to
extension QRRetrievalMethodViewController {
//    func popBackToProperViewController(id: String) {
//        // If we only have one card (or no cards), then go back to health pass with popBackTo
//        // If we have more than one card, we should check if 2nd controller in stack is CovidVaccineCardsViewController, if so, pop back, if not, instantiate, insert at 1, then pop back
//        guard StorageService.shared.fetchVaccineCards().count > 1 else {
//            self.popBack(toControllerType: HealthPassViewController.self)
//            return
//        }
//        // check for controller in stack
//        guard let viewControllerStack = self.navigationController?.viewControllers else { return }
//        var containsCovidVaxCardsVC = false
//        for (index, vc) in viewControllerStack.enumerated() {
//            if vc is CovidVaccineCardsViewController {
//                containsCovidVaxCardsVC = true
//            }
//        }
//        guard containsCovidVaxCardsVC == false else {
//            postCardAddedNotification(id: id)
//            //            self.navigationController?.popViewController(animated: true)
//            self.popBack(toControllerType: CovidVaccineCardsViewController.self)
//            return
//        }
//        guard viewControllerStack.count > 0 else { return }
//        guard viewControllerStack[0] is HealthPassViewController else { return }
//        let vc = CovidVaccineCardsViewController.constructCovidVaccineCardsViewController(recentlyAddedCardId: id, fedPassStringToOpen: nil)
//        self.navigationController?.viewControllers.insert(vc, at: 1)
//        // Note for Amir - This is because calling post notification wont work as the view did load hasn't been called yet where we add the notification observer, and we do this here, as there is logic in that view controller that refers to outlets, so it has to load first, otherwise we'll get a crash with outlets not being set yet.
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//            self.postCardAddedNotification(id: id)
//        }
//        self.popBack(toControllerType: CovidVaccineCardsViewController.self)
//    }
}

// MARK: Image Picker
extension QRRetrievalMethodViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func showImagePicker(selected: @escaping(_ image: UIImage?)-> Void) {
        self.ImagePickerCallback = selected
        let picker = UIImagePickerController()
        imagePicker = picker
        picker.modalPresentationStyle = UIModalPresentationStyle.currentContext
        picker.delegate = self
        if let tabBarVC = self.navigationController?.parent as? UITabBarController {
            tabBarVC.view.startLoadingIndicator()
            tabBarVC.present(picker, animated: true, completion: {
                tabBarVC.view.endLoadingIndicator()
            })
        } else {
            view.startLoadingIndicator()
            self.present(picker, animated: true, completion: { [weak self] in
                guard let `self` = self else {return}
                self.view.endLoadingIndicator()
            })
        }
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let listener = ImagePickerCallback else {return}
        var newImage: UIImage? = nil
        
        if let possibleImage = info[.editedImage] as? UIImage {
            newImage = possibleImage
        } else if let possibleImage = info[.originalImage] as? UIImage {
            newImage = possibleImage
        }
        
        listener(newImage)
        self.ImagePickerCallback = nil
        self.imagePicker?.dismiss(animated: true, completion: { [weak self] in
            guard let `self` = self else {return}
            self.imagePicker = nil
        })
        return
    }
}

