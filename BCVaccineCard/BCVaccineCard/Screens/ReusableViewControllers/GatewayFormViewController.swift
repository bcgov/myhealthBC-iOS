//
//  ViewController.swift
//  ClientVaxPass-POC
//
//  Created by Connor Ogilvie on 2021-09-09.

import UIKit
import BCVaccineValidator


// TODO: ROUTE REFACTOR - FORMS

enum GatewayFormSource: Equatable {
    case healthPassHomeScreen
    case vaccineCardsScreen
    case qrMethodSelectionScreen
    case fetchHealthRecordsScreen
    
    var getVC: UIViewController {
        switch self {
        case .healthPassHomeScreen:
            return HealthPassViewController()
        case .vaccineCardsScreen:
            return CovidVaccineCardsViewController()
        case .qrMethodSelectionScreen:
            return QRRetrievalMethodViewController()
        case .fetchHealthRecordsScreen:
            return FetchHealthRecordsViewController()
        }
    }
}

enum GatewayFormViewControllerFetchType: Equatable {
    case bcVaccineCardAndFederalPass
    case federalPassOnly(dob: String, dov: String, code : String)
    case vaccinationRecord
    
    enum RequestType: Equatable {
        case getVaccineCard
    }
    
    var getRequestType: RequestType {
        switch self {
        case .bcVaccineCardAndFederalPass, .federalPassOnly, .vaccinationRecord:
            return .getVaccineCard
        }
    }
    
    var getNavTitle: String {
        switch self {
        case .bcVaccineCardAndFederalPass: return .addAHealthPass
        case .federalPassOnly: return .getFederalProof
        case .vaccinationRecord: return .formRecordNavTitle
        }
    }
    
    var canGoToNextFormField: Bool {
        switch self {
        case .federalPassOnly: return false
        default: return true
        }
    }
    
    var isFedPassOnly: Bool {
        switch self {
        case .federalPassOnly: return true
        default: return false
        }
    }
    
    var originalCode: String? {
        switch self {
        case .federalPassOnly(_, _, let code):
            return code
        default:
            return nil
        }
    }
    
    func getDataSource(currentProgress: GatewayInProgressDetails?) -> [FormData] {
        switch self {
        case .bcVaccineCardAndFederalPass:
            return [
                FormData(specificCell: .phnForm, configuration: FormData.Configuration(text: currentProgress?.phn, isTextField: true), isFieldVisible: true),
                FormData(specificCell: .dobForm, configuration: FormData.Configuration(text: currentProgress?.dob, isTextField: true), isFieldVisible: true),
                FormData(specificCell: .dovForm, configuration: FormData.Configuration(text: currentProgress?.dateOfVax, isTextField: true), isFieldVisible: true),
                FormData(specificCell: .rememberCheckbox, configuration: FormData.Configuration(text: .rememberePHNandDOB, isTextField: false), isFieldVisible: true),
                FormData(specificCell: .clickablePrivacyPolicy, configuration:
                            FormData.Configuration(text: .privacyPolicyStatement(context: .privacyVaccineStatusText),
                                                   font: UIFont.bcSansRegularWithSize(size: 13),
                                                   linkedStrings: [
                    LinkedStrings(text: .privacyPolicyStatementEmail, link: .privacyPolicyStatementEmailLink),
                    LinkedStrings(text: .privacyPolicyStatementPhoneNumber, link: .privacyPolicyStatementPhoneNumberLink)], isTextField: false), isFieldVisible: true)]
        case .federalPassOnly(let dob, let dov, _):
            return [
                FormData(specificCell: .phnForm, configuration: FormData.Configuration(text: currentProgress?.phn, isTextField: true), isFieldVisible: true),
                FormData(specificCell: .dobForm, configuration: FormData.Configuration(text: dob, isTextField: true), isFieldVisible: false),
                FormData(specificCell: .dovForm, configuration: FormData.Configuration(text: dov, isTextField: true), isFieldVisible: false),
                FormData(specificCell: .clickablePrivacyPolicy, configuration:
                            FormData.Configuration(text: .privacyPolicyStatement(context: .privacyVaccineStatusText),
                                                   font: UIFont.bcSansRegularWithSize(size: 13),
                                                   linkedStrings: [
                    LinkedStrings(text: .privacyPolicyStatementEmail, link: .privacyPolicyStatementEmailLink),
                    LinkedStrings(text: .privacyPolicyStatementPhoneNumber, link: .privacyPolicyStatementPhoneNumberLink)], isTextField: false), isFieldVisible: true)]
        case .vaccinationRecord:
            return [
                FormData(specificCell: .phnForm, configuration: FormData.Configuration(text: currentProgress?.phn, isTextField: true), isFieldVisible: true),
                FormData(specificCell: .dobForm, configuration: FormData.Configuration(text: currentProgress?.dob, isTextField: true), isFieldVisible: true),
                FormData(specificCell: .dovForm, configuration: FormData.Configuration(text: currentProgress?.dateOfVax, isTextField: true), isFieldVisible: true),
                FormData(specificCell: .rememberCheckbox, configuration: FormData.Configuration(text: .rememberePHNandDOB, isTextField: false), isFieldVisible: true),
                FormData(specificCell: .clickablePrivacyPolicy, configuration:
                            FormData.Configuration(text: .privacyPolicyStatement(context: .privacyVaccineStatusText),
                                                   font: UIFont.bcSansRegularWithSize(size: 13),
                                                   linkedStrings: [
                    LinkedStrings(text: .privacyPolicyStatementEmail, link: .privacyPolicyStatementEmailLink),
                    LinkedStrings(text: .privacyPolicyStatementPhoneNumber, link: .privacyPolicyStatementPhoneNumberLink)], isTextField: false), isFieldVisible: true)]
        }
    }
}

struct GatewayFormCompletionHandlerDetails {
    let id: String
    let fedPassId: String?
    let name: String?
    let dob: String?
    let patient: Patient?
}

struct GatewayInProgressDetails {
    var phn: String?
    var dob: String?
    var dateOfTest: String?
    var dateOfVax: String?
}

class GatewayFormViewController: BaseViewController {
    
    struct ViewModel {
        var rememberDetails: RememberedGatewayDetails
        var fetchType: GatewayFormViewControllerFetchType
        var currentProgress: GatewayInProgressDetails? = nil
        var onAddCard: ((VaccineCard?) -> Void)?
        var onAddFederalPass: ((VaccineCard?) -> Void)?
        
        var dataSource: [FormData] = []
        
        var navTitle: String {
            return fetchType.getNavTitle
        }
        
        init(rememberDetails: RememberedGatewayDetails,
             fetchType: GatewayFormViewControllerFetchType,
             currentProgress: GatewayInProgressDetails? = nil,
             onAddCard: @escaping (VaccineCard?) -> Void,
             onAddFederalPass: @escaping (VaccineCard?) -> Void
        ) {
            self.rememberDetails = rememberDetails
            self.fetchType = fetchType
            self.currentProgress = currentProgress
            self.onAddCard = onAddCard
            self.onAddFederalPass = onAddFederalPass
            self.dataSource = fetchType.getDataSource(currentProgress: currentProgress)
        }
        
        
    }
    
    class func construct(viewModel: ViewModel) -> GatewayFormViewController {
        if let vc = Storyboard.reusable.instantiateViewController(withIdentifier: String(describing: GatewayFormViewController.self)) as? GatewayFormViewController {
            vc.viewModel = viewModel
            return vc
        }
        return GatewayFormViewController()
    }
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet weak var cancelButton: AppStyleButton!
    @IBOutlet weak var submitButton: AppStyleButton!
    
    private var viewModel: ViewModel?
    private var dropDownView: DropDownView?
    private var whiteSpaceFormattedPHN: String?
    // For Request
    // TODO: Will need to refactor this a bit when we get the endpoint for test results
    private var storageModel: HGStorageModel?
    
    private var submitButtonEnabled: Bool = false {
        didSet {
            submitButton.enabled = submitButtonEnabled
        }
    }
    
    private var rememberedPHNSelected: Bool = false {
        didSet {
            guard let ds = viewModel?.dataSource else {return}
            guard let indexPath = getIndexPathForSpecificCell(.rememberCheckbox, inDS: ds, usingOnlyShownCells: true) else { return }
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Putting this here in case user goes to help screen
        self.tabBarController?.tabBar.isHidden = true
        navSetup()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Note - sometimes tabBarController will be nil due to when it's released in memory
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            return UIStatusBarStyle.darkContent
        } else {
            return UIStatusBarStyle.default
        }
    }
    
    private func setup() {
        setupButtons()
        setupTableView()
    }
    
    private func setupButtons() {
        cancelButton.configure(withStyle: .white, buttonType: .cancel, delegateOwner: self, enabled: true)
        submitButton.configure(withStyle: .blue, buttonType: .submit, delegateOwner: self, enabled: false)
    }
    
    private func updateCurrentProgress(type: FormTextFieldType, text: String?) {
        switch type {
        case .personalHealthNumber:
            viewModel?.currentProgress?.phn = text
        case .dateOfBirth:
            viewModel?.currentProgress?.dob = text
        case .dateOfVaccination:
            viewModel?.currentProgress?.dateOfVax = text
        case .dateOfTest:
            viewModel?.currentProgress?.dateOfTest = text
        }
    }

}

// MARK: Navigation setup
extension GatewayFormViewController {
    private func navSetup() {
        self.navDelegate?.setNavigationBarWith(title: viewModel?.navTitle ?? "",
                                               leftNavButton: nil,
                                               rightNavButton: NavButton(image: UIImage(named: "help-icon"), action: #selector(self.helpIconButton), accessibility: Accessibility(traits: .button, label: AccessibilityLabels.HealthGatewayScreen.navRightIconTitle, hint: AccessibilityLabels.HealthGatewayScreen.navRightIconHint)),
                                               navStyle: .small,
                                               navTitleSmallAlignment: .Center,
                                               targetVC: self, backButtonHintString: AccessibilityLabels.GatewayForm.navHint)
    }
    
    @objc private func helpIconButton() {
        self.openHelpScreen()
    }
}

// MARK: Table View Logic
extension GatewayFormViewController: UITableViewDelegate, UITableViewDataSource {
    private func setupTableView() {
        tableView.register(UINib.init(nibName: TextTableViewCell.getName, bundle: .main), forCellReuseIdentifier: TextTableViewCell.getName)
        tableView.register(UINib.init(nibName: FormTableViewCell.getName, bundle: .main), forCellReuseIdentifier: FormTableViewCell.getName)
        tableView.register(UINib.init(nibName: CheckboxTableViewCell.getName, bundle: .main), forCellReuseIdentifier: CheckboxTableViewCell.getName)
        tableView.register(UINib.init(nibName: InteractiveLabelTableViewCell.getName, bundle: .main), forCellReuseIdentifier: InteractiveLabelTableViewCell.getName)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.dataSource.filter { $0.isFieldVisible }.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let viewModel = self.viewModel else {
            return UITableViewCell()
        }
        let shownDS = viewModel.dataSource.filter { $0.isFieldVisible }
        let formData = shownDS[indexPath.row]
        let config = formData.configuration
        switch formData.specificCell.getCellType {
        case .text(type: let type):
            if let cell = tableView.dequeueReusableCell(withIdentifier: TextTableViewCell.getName, for: indexPath) as? TextTableViewCell, let text = config.text, let font = config.font {
                cell.configure(forType: type, text: text, withFont: font)
                cell.accessibilityTraits = .staticText
                return cell
            }
            return UITableViewCell()
        case .form(type: let type):
            if let cell = tableView.dequeueReusableCell(withIdentifier: FormTableViewCell.getName, for: indexPath) as? FormTableViewCell {
                cell.configure(formType: type, delegateOwner: self, rememberedDetails: viewModel.rememberDetails, text: config.text)
                return cell
            }
            return UITableViewCell()
        case .checkbox:
            if let cell = tableView.dequeueReusableCell(withIdentifier: CheckboxTableViewCell.getName, for: indexPath) as? CheckboxTableViewCell, let text = config.text {
                cell.configure(selected: self.rememberedPHNSelected, text: text, delegateOwner: self)
                return cell
            }
            return UITableViewCell()
        case .clickableText:
            if let cell = tableView.dequeueReusableCell(withIdentifier: InteractiveLabelTableViewCell.getName, for: indexPath) as? InteractiveLabelTableViewCell, let text = config.text, let linkedStrings = config.linkedStrings, let font = config.font {
                cell.configure(string: text, linkedStrings: linkedStrings, textColor: AppColours.textBlack, font: font)
                return cell
            }
            return UITableViewCell()
        }
    }
}

// MARK: Remember PHN and DOB
extension GatewayFormViewController: CheckboxTableViewCellDelegate {
    func checkboxTapped(selected: Bool) {
        self.rememberedPHNSelected = selected
    }
    
    private func storePHNDetails() {
        guard let viewModel = self.viewModel, let model = self.storageModel else { return }
        if model.phn == self.whiteSpaceFormattedPHN?.removeWhiteSpaceFormatting, self.whiteSpaceFormattedPHN != nil {
            let rememberProperties = GatewayStorageProperties(phn: self.whiteSpaceFormattedPHN!, dob: model.dob)
           // Store new remember details if necessary
            guard rememberProperties.phn != viewModel.rememberDetails.storageArray?.first?.phn else { return }
            // NOTE: This is where we can append data to existing storage for abilitly to store multiple pieces of data
            let rememberKeychainStorage = RememberedGatewayDetails(storageArray: [rememberProperties])
            Defaults.rememberGatewayDetails = rememberKeychainStorage
        }
    }
    
    // TODO: Adjust this logic here
    private func removePHNDetailsIfNeccessary() {
        let rememberKeychainStorage = RememberedGatewayDetails(storageArray: nil)
        // Note: If remember details is unchecked, and the phn used is not the same as the remembered phn, then we do nothing
//        if self.storageModel?.phn.removeWhiteSpaceFormatting == self.rememberDetails.storageArray?.first?.phn.removeWhiteSpaceFormatting {
//            Defaults.rememberGatewayDetails = rememberKeychainStorage
//        }
    }
    
}

// MARK: Helper functions
extension GatewayFormViewController {
    private func getIndexPathForSpecificCell(_ specificCell: FormData.SpecificCell, inDS dataSource: [FormData], usingOnlyShownCells: Bool) -> IndexPath? {
        var ds = dataSource
        if usingOnlyShownCells {
            ds = dataSource.filter({ $0.isFieldVisible })
        }
        var indexPath: IndexPath?
        if let index = ds.firstIndex(where: { $0.specificCell == specificCell }) {
            indexPath = IndexPath(row: index, section: 0)
        }
        return indexPath
    }
}

// MARK: Drop down
extension GatewayFormViewController: DropDownViewDelegate {
    func didChooseStoragePHN(details: GatewayStorageProperties) {
        guard var viewModel = self.viewModel else {
            return
        }
        if details.phn == viewModel.rememberDetails.storageArray?.first?.phn {
            self.rememberedPHNSelected = true
            var indexPaths: [IndexPath] = []
            guard let firstIP = getIndexPathForSpecificCell(.phnForm, inDS: viewModel.dataSource, usingOnlyShownCells: true) else { return }
            indexPaths.append(firstIP)
            self.viewModel?.dataSource[firstIP.row].configuration.text = details.phn
            if viewModel.fetchType.canGoToNextFormField {
                guard let secondIP = getIndexPathForSpecificCell(.dobForm, inDS: viewModel.dataSource, usingOnlyShownCells: true) else {
                    return
                }
                indexPaths.append(secondIP)
                self.viewModel?.dataSource[secondIP.row].configuration.text = details.dob
            }
            self.tableView.reloadRows(at: indexPaths, with: .automatic)
            submitButtonEnabled = shouldButtonBeEnabled()
        }
        if let dropDownView = dropDownView {
            self.dismissDropDownView(dropDownView: dropDownView)
        }
    }
    
    private func handleDropDownView() {
        guard let viewModel = self.viewModel else {
            return
        }
        if let dropDownView = self.dropDownView {
            // Dismiss drop down view
            dismissDropDownView(dropDownView: dropDownView)
        } else {
            // Configure and present drop down view
            self.dropDownView = DropDownView()
            self.tableView.addSubview(dropDownView!)
            self.dropDownView?.translatesAutoresizingMaskIntoConstraints = false
            // TODO: Make this safer - don't like default value here
            guard let indexPath = self.getIndexPathForSpecificCell(.phnForm, inDS: viewModel.dataSource, usingOnlyShownCells: true) else { return }
            guard let relativeView = tableView.cellForRow(at: indexPath) else { return }
            let padding: CGFloat = 12.0
            let leadingConstraint = dropDownView!.leadingAnchor.constraint(equalTo: relativeView.leadingAnchor, constant: -padding)
            let trailingConstraint = dropDownView!.trailingAnchor.constraint(equalTo: relativeView.trailingAnchor, constant: padding)
            let count: CGFloat = CGFloat(viewModel.rememberDetails.storageArray?.count ?? 1)
            let heightConstraint = dropDownView!.heightAnchor.constraint(equalToConstant: (count * Constants.UI.RememberPHNDropDownRowHeight.height) + padding)
            let topConstraint = dropDownView!.topAnchor.constraint(equalTo: relativeView.topAnchor, constant: 80)
            self.tableView.addConstraints([leadingConstraint, trailingConstraint, heightConstraint, topConstraint])
            self.dropDownView?.configure(rememberGatewayDetails: viewModel.rememberDetails, delegateOwner: self)
        }
    }
    
    private func dismissDropDownView(dropDownView: DropDownView) {
        dropDownView.removeFromSuperview()
        self.dropDownView = nil
    }

}

// MARK: Request formatting
extension GatewayFormViewController {
    
    private func requestForVaccineCard() {
        guard let viewModel = self.viewModel else {
            return
        }
        guard let phnIndexPath = getIndexPathForSpecificCell(.phnForm, inDS: viewModel.dataSource, usingOnlyShownCells: false) else { return }
        guard let phn = viewModel.dataSource[phnIndexPath.row].configuration.text else { return }
        guard let dobIndexPath = getIndexPathForSpecificCell(.dobForm, inDS: viewModel.dataSource, usingOnlyShownCells: false) else { return }
        guard let birthday = viewModel.dataSource[dobIndexPath.row].configuration.text else { return }
        guard let dovIndexPath = getIndexPathForSpecificCell(.dovForm, inDS: viewModel.dataSource, usingOnlyShownCells: false) else { return }
        guard let vaxDate = viewModel.dataSource[dovIndexPath.row].configuration.text else { return }
        guard let model = formatGatewayDataForVaccineRequest(phn: phn, birthday: birthday, vax: vaxDate) else { return }
        self.whiteSpaceFormattedPHN = phn
        self.storageModel = HGStorageModel(phn: model.phn, dob: model.dateOfBirth)
        
        let service = VaccineCardService(network: AFNetwork(), authManager: AuthManager(), configService: MobileConfigService(network: AFNetwork()))
        service.fetch(phn: phn, dateOfBirth: birthday, dateOfVaccine: vaxDate) { [weak self] response in
            guard let `self` = self else {return}
            let qrResult = response?.transformResponseIntoQRCode()
            guard let code = qrResult?.qrString else {
                self.handleError(title: .error, error: ResultError(resultMessage: response?.resultError?.resultMessage))
                return
            }
            BCVaccineValidator.shared.validate(code: code) { [weak self] result in
                guard let `self` = self else { return }
                guard let data = result.result else {
                    self.handleError(title: .error, error: ResultError(resultMessage: .invalidQRCodeMessage))
                    return
                }
                DispatchQueue.main.async { [weak self] in
                    guard let `self` = self else {return}
                    self.handleVaccineCard(scanResult: data, fedCode: response?.resourcePayload?.federalVaccineProof?.data)
                }
            }
            
        }
    }
    
    private func formatGatewayDataForVaccineRequest(phn: String, birthday: String, vax: String) -> GatewayVaccineCardRequest? {
        let formattedPHN = phn.removeWhiteSpaceFormatting
        return GatewayVaccineCardRequest(phn: formattedPHN, dateOfBirth: birthday, dateOfVaccine: vax)
    }
}

// MARK: Update data source
extension GatewayFormViewController {
    func updateDataSource(formField: FormTextFieldType, text: String?) {
        guard let viewModel = self.viewModel else {
            return
        }
        let specificCell = FormData.getSpecificCellFromFormTextField(formField)
        guard let indexPath = getIndexPathForSpecificCell(specificCell, inDS: viewModel.dataSource, usingOnlyShownCells: true) else { return }
        self.viewModel?.dataSource[indexPath.row].configuration.text = text
        if formField == .personalHealthNumber {
            // Basically - if the user updates the text and it is not equal to the stored PHN, then remove the data
            // TODO: CONNOR: Need to update logic here - keep it simple. Only time remembered details are removed is if they are overwritten by a new phn
//            if text != self.rememberDetails.storageArray?.first?.phn {
//                self.rememberedPHNSelected = false
//            } else
            if text == viewModel.rememberDetails.storageArray?.first?.phn {
                self.rememberedPHNSelected = true
            }
        }
        
    }
}

// MARK: Custom Text Field Delegates
extension GatewayFormViewController: FormTextFieldViewDelegate {
    func fieldTapped(field: UITextField) {
        self.resignFirstResponder()
        field.becomeFirstResponder()
    }
    
    func resignFirstResponderUI(formField: FormTextFieldType) {
        self.view.endEditing(true)
    }
    
    func goToNextFormTextField(formField: FormTextFieldType) {
        if viewModel?.fetchType.canGoToNextFormField == true {
            goToNextTextField(formField: formField)
        } else {
            self.view.endEditing(true)
        }
    }
    
    func didFinishEditing(formField: FormTextFieldType, text: String?) {
        updateDataSource(formField: formField, text: text)
        submitButtonEnabled = shouldButtonBeEnabled()
    }
    
    func textFieldTextDidChange(formField: FormTextFieldType, newText: String) {
        updateDataSource(formField: formField, text: newText)
        submitButtonEnabled = shouldButtonBeEnabled()
        self.updateCurrentProgress(type: formField, text: newText)
    }
    
    func rightTextFieldButtonTapped(formField: FormTextFieldType) {
        if formField == .personalHealthNumber {
            handleDropDownView()
        }
    }
    
    func resizeForm(formField: FormTextFieldType) {
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
    }
    
    private func goToNextTextField(formField: FormTextFieldType) {
        guard let viewModel = self.viewModel else {
            return
        }
        let specificCell = FormData.getSpecificCellFromFormTextField(formField)
        let shownDS = viewModel.dataSource.filter { $0.isFieldVisible }
        guard var indexPath = getIndexPathForSpecificCell(specificCell, inDS: viewModel.dataSource, usingOnlyShownCells: true), indexPath.row < (shownDS.count - 1) else { return }
        let newRow = indexPath.row + 1
        indexPath.row = newRow
        if shownDS[indexPath.row].specificCell.isTextField, let cell = self.tableView.cellForRow(at: indexPath) as? FormTableViewCell {
            // Go to this cell
            cell.formTextFieldView.openKeyboardAction()
        } else if let firstIndexPath = getIndexPathForSpecificCell(.phnForm, inDS: viewModel.dataSource, usingOnlyShownCells: true) {
            // find first index of text field in data source (Note: This is hardcorded as PHN - if the order changes, then this will have to change too
            if let firstCell = self.tableView.cellForRow(at: firstIndexPath) as? FormTableViewCell {
                firstCell.formTextFieldView.openKeyboardAction()
            }
        }
    }
}

// MARK: Check for authenticated patient
extension GatewayFormViewController {
    private func isPHNOfAuthenticatedPatient() -> (auth: Bool, patient: Patient?) {
        guard let viewModel = self.viewModel else {
            return (false, nil)
        }
        guard let phnIndexPath = getIndexPathForSpecificCell(.phnForm, inDS: viewModel.dataSource, usingOnlyShownCells: false) else { return (false, nil) }
        guard let phn = viewModel.dataSource[phnIndexPath.row].configuration.text?.removeWhiteSpaceFormatting else { return (false, nil) }
        guard let patient = StorageService.shared.fetchPatient(phn: phn) else { return (false, nil) }
        return (hasAuthRecords(patient: patient), patient)
    }
    
    private func hasAuthRecords(patient: Patient) -> Bool {
        for vaccineCard in patient.vaccineCardArray {
            if vaccineCard.authenticated {
                return true
            }
        }
        for testResult in patient.testResultArray {
            if testResult.authenticated {
                return true
            }
        }
        for prescription in patient.prescriptionArray {
            if prescription.authenticated {
                return true
            }
        }
        for labOrder in patient.labOrdersArray {
            if labOrder.authenticated {
                return true
            }
        }
        return false
    }
    
    private func showAlertToRedirectAuthenticatedUserToRecordsView(patient: Patient) {
        alert(title: "Warning", message: "Your records already exist in the app", buttonOneTitle: .ok, buttonOneCompletion: { [weak self] in
            guard let `self` = self else {return}
            // TODO: ROUTE REFACTOR - Where to go?
            DispatchQueue.main.async {
//                let recordFlowDetails = RecordsFlowDetails(currentStack: self.getCurrentStacks.recordsStack, actioningPatient: patient, addedRecord: nil)
//                let passesFlowDetails = PassesFlowDetails(currentStack: self.getCurrentStacks.passesStack, recentlyAddedCardId: nil, fedPassStringToOpen: nil, fedPassAddedFromHealthPassVC: nil)
//                let values = ActionScenarioValues(currentTab: self.getCurrentTab, recordFlowDetails: recordFlowDetails, passesFlowDetails: passesFlowDetails)
//
//                self.routerWorker?.routingAction(scenario: .ManualFetch(values: values))
            }
        }, buttonTwoTitle: "Retry") {}
    }
}

// MARK: For Button tap and enabling
extension GatewayFormViewController: AppStyleButtonDelegate {
    func buttonTapped(type: AppStyleButton.ButtonType) {
        if type == .cancel {
            self.navigationController?.popViewController(animated: true)
        } else if type == .submit {
            let tuple = isPHNOfAuthenticatedPatient()
            if tuple.auth, let patient = tuple.patient {
                showAlertToRedirectAuthenticatedUserToRecordsView(patient: patient)
            } else {
                if viewModel?.fetchType.getRequestType == .getVaccineCard {
                    requestForVaccineCard()
                }
            }
        }
    }
    
    func shouldButtonBeEnabled() -> Bool {
        guard let viewModel = self.viewModel else {
            return false
        }
        let formData = viewModel.dataSource.compactMap { $0.transform() }
        let countArray: [Bool] = formData.map { textFieldData in
            guard let text = textFieldData.text else {
                return false
            }
            let error = textFieldData.type.setErrorValidationMessage(text: text)
            return error == nil
        }
        return countArray.filter { $0 == true }.count == viewModel.dataSource.filter({ $0.specificCell.isTextField }).count
    }

}

// MARK: Health Gateway worker
extension GatewayFormViewController: HealthGatewayAPIWorkerDelegate {
    func handleVaccineCard(scanResult: ScanResultModel, fedCode: String?) {
        guard let viewModel = self.viewModel else {
            return
        }
        var model = convertScanResultModelIntoLocalData(data: scanResult, source: .healthGateway)
        model.fedCode = fedCode
        // store prefered PHN if needed here
        self.rememberedPHNSelected ? storePHNDetails() : removePHNDetailsIfNeccessary()
        handleCardInCoreData(localModel: model, replacing: viewModel.fetchType.originalCode)
    }
    
    func handleError(title: String, error: ResultError) {
        if error.resultMessage == "Unknown" {
            alert(title: title, message: .unknownErrorMessage)
        } else {
            alert(title: title, message: error.resultMessage ?? .healthGatewayError)
        }
        
    }
    
    func updateCardInLocalStorage(model: AppVaccinePassportModel) {
        self.updateCardInLocalStorage(model: model.transform(), manuallyAdded: true, completion: { [weak self] coreDataReturnObject in
            guard let `self` = self else {return}
            guard let viewModel = self.viewModel else {
                return
            }
            viewModel.onAddCard?(coreDataReturnObject)
        })
    }
    
    func storeCardInLocalStorage(model: AppVaccinePassportModel, sortOrder: Int64? = nil) {
     
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.storeVaccineCard(model: model.transform(),
                                  authenticated: false,
                                  sortOrder: sortOrder,
                                  manuallyAdded: true,
                                  completion: { [weak self] coreDataReturnObject in
                guard let `self` = self else {return}
                guard let viewModel = self.viewModel else {
                    return
                }
               viewModel.onAddCard?(coreDataReturnObject)
            })
        }
    }
    
    func updateFederalPassInLocalStorge(model: AppVaccinePassportModel) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.updateFedCodeForCardInLocalStorage(model: model.transform(), manuallyAdded: true, completion: { [weak self] coreDataReturnObject in
                guard let `self` = self else {return}
                guard let viewModel = self.viewModel else {
                    return
                }
                viewModel.onAddFederalPass?(coreDataReturnObject)
            })
        }
    }
    
    func handleCardInCoreData(localModel: LocallyStoredVaccinePassportModel, replacing code: String?) {
        let model = localModel.transform()
        let deletedCardSortOrder: Int64?
        guard let viewModel = self.viewModel else {
            return
        }
        if viewModel.fetchType.isFedPassOnly, let codeToReplace = code {
            deletedCardSortOrder = StorageService.shared.fetchVaccineCard(code: codeToReplace)?.sortOrder
            StorageService.shared.deleteVaccineCard(vaccineQR: codeToReplace, reSort: false, manuallyAdded: false)
        } else {
            deletedCardSortOrder = nil
        }
        model.state { [weak self] state in
            guard let `self` = self else {return}
            switch state {
            case .exists, .isOutdated:
                let message: String = viewModel.fetchType == .vaccinationRecord ? .duplicateMessageImsRecord : .duplicateMessage
                self.alert(title: .duplicateTitle, message: message) { [weak self] in
                    guard let `self` = self else {return}
                    DispatchQueue.main.async {
                        let card = StorageService.shared.fetchVaccineCard(code: localModel.code)
                        self.dismiss(then: {
                            self.viewModel?.onAddCard?(card)
                        })
                    }
                }
            case .isNew:
                self.storeCardInLocalStorage(model: model, sortOrder: deletedCardSortOrder)
            case .canUpdateExisting:
                self.alert(title: .updatedCard, message: "\(String.updateCardFor) \(model.transform().name)", buttonOneTitle: "Yes", buttonOneCompletion: { [weak self] in
                    guard let `self` = self else {return}
                    self.updateCardInLocalStorage(model: model)
                }, buttonTwoTitle: "No") { [weak self] in
                    guard let `self` = self else {return}
                    DispatchQueue.main.async {
                        let card = StorageService.shared.fetchVaccineCard(code: localModel.code)
                        self.dismiss(then: {
                            self.viewModel?.onAddCard?(card)
                        })
                    }
                }
            case .UpdatedFederalPass:
                self.updateFederalPassInLocalStorge(model: model)
            }
        }
    }
    
//    func handleTestResultInCoreData(gatewayResponse: GatewayTestResultResponse, authenticated: Bool) -> CoreDataReturnObject? {
//        guard let viewModel = self.viewModel else {
//            return nil
//        }
//        // Note, this first guard statement is to handle the case when health gateway is wonky - throws success with no error but has key nil values, so in this case we don't want to store a dummy patient value, as that's what was happening
//        guard let collectionDate = gatewayResponse.resourcePayload?.records.first?.collectionDateTime,
//              !collectionDate.trimWhiteSpacesAndNewLines.isEmpty, let reportID = gatewayResponse.resourcePayload?.records.first?.reportId,
//              !reportID.trimWhiteSpacesAndNewLines.isEmpty else { return nil }
//        guard let phnIndexPath = getIndexPathForSpecificCell(.phnForm, inDS: viewModel.dataSource, usingOnlyShownCells: false) else { return nil }
//        guard let phn = viewModel.dataSource[phnIndexPath.row].configuration.text?.removeWhiteSpaceFormatting else { return nil }
//        let bday: Date?
//        if let dobIndexPath = getIndexPathForSpecificCell(.dobForm, inDS: viewModel.dataSource, usingOnlyShownCells: false),
//           let dob = viewModel.dataSource[dobIndexPath.row].configuration.text,
//           let dateOfBirth = Date.Formatter.yearMonthDay.date(from: dob) {
//            bday = dateOfBirth
//        } else {
//            bday = nil
//        }
//        guard let patient = StorageService.shared.fetchOrCreatePatient(phn: phn,
//                                                                       name: gatewayResponse.resourcePayload?.records.first?.patientDisplayName,
//                                                                       firstName: "",
//                                                                       lastName: "",
//                                                                       gender: "",
//                                                                       birthday: bday,
//                                                                       physicalAddress: nil,
//                                                                       mailingAddress: nil,
//                                                                       hdid: nil,
//                                                                       authenticated: authenticated
//        ) else {return nil}
//        guard let object = StorageService.shared.storeCovidTestResults(patient: patient ,gateWayResponse: gatewayResponse, authenticated: authenticated, manuallyAdded: true, pdf: nil) else { return nil }
//        return CoreDataReturnObject(id: object.id, patient: patient)
//    }
//
//
}


struct HGStorageModel {
    let phn: String
    let dob: String
}
