//
//  ViewController.swift
//  ClientVaxPass-POC
//
//  Created by Connor Ogilvie on 2021-09-09.
// TODO: Steps:
/// 1.) Organize file better so things are easier to find and more structured
/// 2.) Rethink how form data source is structured (perhaps have the enum have the same associated type, which is a struct. Or a protocol which implements a property which is a struct ) Basically just need to rethink the "FormDataSource" structure
/// 3.) Should implement a "Configuration" protocol of some sort, or a getter that returns configuration specific for each type of TBV cell that will be used here
/// 4.) Make sure functions, such as prepopulating the cell, updating the data source, etc.. are as extracted as possible to the struct or whatever model type is decided
/// 5.) Reduce redundancies in code where possible (indexOf functions, for example)

import UIKit
//import QueueITLibrary
import BCVaccineValidator

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
    case covid19TestResult
    
    var getNavTitle: String {
        switch self {
        case .bcVaccineCardAndFederalPass: return .addAHealthPass
        case .federalPassOnly: return .getFederalTravelPass
        case .vaccinationRecord: return .addAHealthPass // TODO: Will need to update this when we implement it
        case .covid19TestResult: return "TODO" // TODO: Add proper text
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
    
    var getDataSource: [FormData] {
        switch self {
        case .bcVaccineCardAndFederalPass:
            return [
                FormData(specificCell: .phnForm, configuration: FormData.Configuration(isTextField: true), isFieldVisible: true),
                FormData(specificCell: .dobForm, configuration: FormData.Configuration(isTextField: true), isFieldVisible: true),
                FormData(specificCell: .dovForm, configuration: FormData.Configuration(isTextField: true), isFieldVisible: true),
                FormData(specificCell: .rememberCheckbox, configuration: FormData.Configuration(text: .rememberePHNandDOB, isTextField: false), isFieldVisible: true),
                FormData(specificCell: .clickablePrivacyPolicy, configuration:
                            FormData.Configuration(text: .privacyPolicyStatement,
                                                   font: UIFont.bcSansRegularWithSize(size: 13),
                                                   linkedStrings: [
                    LinkedStrings(text: .privacyPolicyStatementEmail, link: .privacyPolicyStatementEmailLink),
                    LinkedStrings(text: .privacyPolicyStatementPhoneNumber, link: .privacyPolicyStatementPhoneNumberLink)], isTextField: false), isFieldVisible: true)]
        case .federalPassOnly(let dob, let dov, _):
            return [
                FormData(specificCell: .phnForm, configuration: FormData.Configuration(isTextField: true), isFieldVisible: true),
                FormData(specificCell: .dobForm, configuration: FormData.Configuration(text: dob, isTextField: true), isFieldVisible: false),
                FormData(specificCell: .dovForm, configuration: FormData.Configuration(text: dov, isTextField: true), isFieldVisible: false),
                FormData(specificCell: .clickablePrivacyPolicy, configuration:
                            FormData.Configuration(text: .privacyPolicyStatement,
                                                   font: UIFont.bcSansRegularWithSize(size: 13),
                                                   linkedStrings: [
                    LinkedStrings(text: .privacyPolicyStatementEmail, link: .privacyPolicyStatementEmailLink),
                    LinkedStrings(text: .privacyPolicyStatementPhoneNumber, link: .privacyPolicyStatementPhoneNumberLink)], isTextField: false), isFieldVisible: true)]
        case .vaccinationRecord:
            return [
                FormData(specificCell: .phnForm, configuration: FormData.Configuration(isTextField: true), isFieldVisible: true),
                FormData(specificCell: .dobForm, configuration: FormData.Configuration(isTextField: true), isFieldVisible: true),
                FormData(specificCell: .dovForm, configuration: FormData.Configuration(isTextField: true), isFieldVisible: true),
                FormData(specificCell: .rememberCheckbox, configuration: FormData.Configuration(text: .rememberePHNandDOB, isTextField: false), isFieldVisible: true),
                FormData(specificCell: .clickablePrivacyPolicy, configuration:
                            FormData.Configuration(text: .privacyPolicyStatement,
                                                   font: UIFont.bcSansRegularWithSize(size: 13),
                                                   linkedStrings: [
                    LinkedStrings(text: .privacyPolicyStatementEmail, link: .privacyPolicyStatementEmailLink),
                    LinkedStrings(text: .privacyPolicyStatementPhoneNumber, link: .privacyPolicyStatementPhoneNumberLink)], isTextField: false), isFieldVisible: true)]
        case .covid19TestResult:
            return [
                FormData(specificCell: .phnForm, configuration: FormData.Configuration(isTextField: true), isFieldVisible: true),
                FormData(specificCell: .dobForm, configuration: FormData.Configuration(isTextField: true), isFieldVisible: true),
                FormData(specificCell: .dotForm, configuration: FormData.Configuration(isTextField: true), isFieldVisible: true),
                FormData(specificCell: .rememberCheckbox, configuration: FormData.Configuration(text: .rememberePHNandDOB, isTextField: false), isFieldVisible: true),
                FormData(specificCell: .clickablePrivacyPolicy, configuration:
                            FormData.Configuration(text: .privacyPolicyStatement,
                                                   font: UIFont.bcSansRegularWithSize(size: 13),
                                                   linkedStrings: [
                    LinkedStrings(text: .privacyPolicyStatementEmail, link: .privacyPolicyStatementEmailLink),
                    LinkedStrings(text: .privacyPolicyStatementPhoneNumber, link: .privacyPolicyStatementPhoneNumberLink)], isTextField: false), isFieldVisible: true)]
        }
    }
}

class GatewayFormViewController: BaseViewController {
    
    class func constructGatewayFormViewController(rememberDetails: RememberedGatewayDetails, fetchType: GatewayFormViewControllerFetchType) -> GatewayFormViewController {
        if let vc = Storyboard.healthPass.instantiateViewController(withIdentifier: String(describing: GatewayFormViewController.self)) as? GatewayFormViewController {
            vc.rememberDetails = rememberDetails
            vc.fetchType = fetchType
            vc.navTitle = fetchType.getNavTitle
            vc.dataSource = fetchType.getDataSource
            return vc
        }
        return GatewayFormViewController()
    }
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet weak var cancelButton: AppStyleButton!
    @IBOutlet weak var submitButton: AppStyleButton!
    
    // Form setup
    private var dataSource: [FormData] = []
    private var fetchType: GatewayFormViewControllerFetchType!
    private var navTitle: String!
    private var submitButtonEnabled: Bool = false {
        didSet {
            submitButton.enabled = submitButtonEnabled
        }
    }
    
    // For Remembering PHN and DOB
    private var rememberDetails: RememberedGatewayDetails!
    private var dropDownView: DropDownView?
    private var whiteSpaceFormattedPHN: String?
    private var rememberedPHNSelected: Bool = false {
        didSet {
            guard let indexPath = getIndexPathForSpecificCell(.rememberCheckbox, inDS: self.dataSource, usingOnlyShownCells: true) else { return }
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
    
    // For Request
    // TODO: Will need to refactor this a bit when we get the endpoint for test results
    private var vaccineCardRequestModel: GatewayVaccineCardRequest?
    private var testResultRequestModel: GatewayTestResultRequest?
    private var worker: HealthGatewayAPIWorker?
//    private var endpoint = UrlAccessor().getVaccineCard
    
    // Completion - first string is for the ID for core data, second string is optional for fed pass only
    var completionHandler: ((String, String?) -> Void)?

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
        setupAPIWorker()
    }
    
    private func setupButtons() {
        cancelButton.configure(withStyle: .white, buttonType: .cancel, delegateOwner: self, enabled: true)
        submitButton.configure(withStyle: .blue, buttonType: .submit, delegateOwner: self, enabled: false)
    }
    
    private func setupAPIWorker() {
        self.worker = HealthGatewayAPIWorker(delegateOwner: self)
    }

}

// MARK: Navigation setup
extension GatewayFormViewController {
    private func navSetup() {
        self.navDelegate?.setNavigationBarWith(title: self.navTitle,
                                               leftNavButton: nil,
                                               rightNavButton: NavButton(image: UIImage(named: "help-icon"), action: #selector(self.helpIconButton), accessibility: Accessibility(traits: .button, label: AccessibilityLabels.HealthGatewayScreen.navRightIconTitle, hint: AccessibilityLabels.HealthGatewayScreen.navRightIconHint)),
                                               navStyle: .small,
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
        return dataSource.filter { $0.isFieldVisible }.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let shownDS = dataSource.filter { $0.isFieldVisible }
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
                cell.configure(formType: type, delegateOwner: self, rememberedDetails: self.rememberDetails, text: config.text)
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? FormTableViewCell {
            cell.formTextFieldView.openKeyboardAction()
        }
    }
}

// MARK: Remember PHN and DOB
extension GatewayFormViewController: CheckboxTableViewCellDelegate {
    func checkboxTapped(selected: Bool) {
        self.rememberedPHNSelected = selected
    }
    
    private func storePHNDetails() {
        guard let model = self.vaccineCardRequestModel else { return }
        if model.phn == self.whiteSpaceFormattedPHN?.removeWhiteSpaceFormatting, self.whiteSpaceFormattedPHN != nil {
            let rememberProperties = GatewayStorageProperties(phn: self.whiteSpaceFormattedPHN!, dob: model.dateOfBirth)
            guard rememberProperties.phn != self.rememberDetails.storageArray?.first?.phn else { return }
            // NOTE: This is where we can append data to existing storage for abilitly to store multiple pieces of data
            let rememberKeychainStorage = RememberedGatewayDetails(storageArray: [rememberProperties])
            Defaults.rememberGatewayDetails = rememberKeychainStorage
        }
    }
    
    private func removePHNDetailsIfNeccessary() {
        let rememberKeychainStorage = RememberedGatewayDetails(storageArray: nil)
        // Note: If remember details is unchecked, and the phn used is not the same as the remembered phn, then we do nothing
        if self.vaccineCardRequestModel?.phn.removeWhiteSpaceFormatting == self.rememberDetails.storageArray?.first?.phn.removeWhiteSpaceFormatting {
            Defaults.rememberGatewayDetails = rememberKeychainStorage
        }
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
    
//    private func getIndexInDataSource(formField: FormTextFieldType, dataSource: [FormData]) -> Int? {
//        return dataSource.firstIndex { $0.type == .form(type: formField) }
//    }
}

// MARK: Drop down
extension GatewayFormViewController: DropDownViewDelegate {
    func didChooseStoragePHN(details: GatewayStorageProperties) {
        if details.phn == self.rememberDetails.storageArray?.first?.phn {
            self.rememberedPHNSelected = true
            var indexPaths: [IndexPath] = []
            guard let firstIP = getIndexPathForSpecificCell(.phnForm, inDS: self.dataSource, usingOnlyShownCells: true) else { return }
            indexPaths.append(firstIP)
            dataSource[firstIP.row].configuration.text = details.phn
            // TODO: Here, should probably put if fetchType.canGoToNextField
            if fetchType == .bcVaccineCardAndFederalPass {
                guard let secondIP = getIndexPathForSpecificCell(.dobForm, inDS: self.dataSource, usingOnlyShownCells: true) else {
                    return
                }
                indexPaths.append(secondIP)
                dataSource[secondIP.row].configuration.text = details.dob
            }
            self.tableView.reloadRows(at: indexPaths, with: .automatic)
            submitButtonEnabled = shouldButtonBeEnabled()
        }
        if let dropDownView = dropDownView {
            self.dismissDropDownView(dropDownView: dropDownView)
        }
    }
    
    private func handleDropDownView() {
        if let dropDownView = self.dropDownView {
            // Dismiss drop down view
            dismissDropDownView(dropDownView: dropDownView)
        } else {
            // Configure and present drop down view
            self.dropDownView = DropDownView()
            self.tableView.addSubview(dropDownView!)
            self.dropDownView?.translatesAutoresizingMaskIntoConstraints = false
            // TODO: Make this safer - don't like default value here
            guard let indexPath = self.getIndexPathForSpecificCell(.phnForm, inDS: self.dataSource, usingOnlyShownCells: true) else { return }
            guard let relativeView = tableView.cellForRow(at: indexPath) else { return }
            let padding: CGFloat = 12.0
            let leadingConstraint = dropDownView!.leadingAnchor.constraint(equalTo: relativeView.leadingAnchor, constant: -padding)
            let trailingConstraint = dropDownView!.trailingAnchor.constraint(equalTo: relativeView.trailingAnchor, constant: padding)
            let count: CGFloat = CGFloat(rememberDetails.storageArray?.count ?? 1)
            let heightConstraint = dropDownView!.heightAnchor.constraint(equalToConstant: (count * Constants.UI.RememberPHNDropDownRowHeight.height) + padding)
            let topConstraint = dropDownView!.topAnchor.constraint(equalTo: relativeView.topAnchor, constant: 80)
            self.tableView.addConstraints([leadingConstraint, trailingConstraint, heightConstraint, topConstraint])
            self.dropDownView?.configure(rememberGatewayDetails: self.rememberDetails, delegateOwner: self)
        }
    }
    
    private func dismissDropDownView(dropDownView: DropDownView) {
        dropDownView.removeFromSuperview()
        self.dropDownView = nil
    }

}

// MARK: Request formatting
extension GatewayFormViewController {
    
    private func prepareRequestForVaccineCard() {
        guard let phnIndexPath = getIndexPathForSpecificCell(.phnForm, inDS: self.dataSource, usingOnlyShownCells: false) else { return }
        guard let phn = dataSource[phnIndexPath.row].configuration.text else { return }
        guard let dobIndexPath = getIndexPathForSpecificCell(.dobForm, inDS: self.dataSource, usingOnlyShownCells: false) else { return }
        guard let birthday = dataSource[dobIndexPath.row].configuration.text else { return }
        guard let dovIndexPath = getIndexPathForSpecificCell(.dovForm, inDS: self.dataSource, usingOnlyShownCells: false) else { return }
        guard let vaxDate = dataSource[dovIndexPath.row].configuration.text else { return }
        guard let model = formatGatewayDataForVaccineRequest(phn: phn, birthday: birthday, vax: vaxDate) else { return }
        self.whiteSpaceFormattedPHN = phn
        self.vaccineCardRequestModel = model
        showLoader()
        worker?.getVaccineCard(model: model, executingVC: self)
    }
    
    private func formatGatewayDataForVaccineRequest(phn: String, birthday: String, vax: String) -> GatewayVaccineCardRequest? {
        let formattedPHN = phn.removeWhiteSpaceFormatting
        return GatewayVaccineCardRequest(phn: formattedPHN, dateOfBirth: birthday, dateOfVaccine: vax)
    }
    
    private func prepareRequestForTestResult() {
        guard let phnIndexPath = getIndexPathForSpecificCell(.phnForm, inDS: self.dataSource, usingOnlyShownCells: false) else { return }
        guard let phn = dataSource[phnIndexPath.row].configuration.text else { return }
        guard let dobIndexPath = getIndexPathForSpecificCell(.dobForm, inDS: self.dataSource, usingOnlyShownCells: false) else { return }
        guard let birthday = dataSource[dobIndexPath.row].configuration.text else { return }
        guard let dotIndexPath = getIndexPathForSpecificCell(.dotForm, inDS: self.dataSource, usingOnlyShownCells: false) else { return }
        guard let testDate = dataSource[dotIndexPath.row].configuration.text else { return }
        guard let model = formatGatewayDataForTestResultRequest(phn: phn, birthday: birthday, test: testDate) else { return }
        self.whiteSpaceFormattedPHN = phn
        self.testResultRequestModel = model
        showLoader()
        worker?.getTestResult(model: model, executingVC: self)
    }
    
    private func formatGatewayDataForTestResultRequest(phn: String, birthday: String, test: String) -> GatewayTestResultRequest? {
        let formattedPHN = phn.removeWhiteSpaceFormatting
        return GatewayTestResultRequest(phn: formattedPHN, dateOfBirth: birthday, collectionDate: test)
    }
}

// MARK: Update data source
extension GatewayFormViewController {
    func updateDataSource(formField: FormTextFieldType, text: String?) {
        let specificCell = FormData.getSpecificCellFromFormTextField(formField)
        guard let indexPath = getIndexPathForSpecificCell(specificCell, inDS: self.dataSource, usingOnlyShownCells: true) else { return }
        self.dataSource[indexPath.row].configuration.text = text
        if formField == .personalHealthNumber {
            // Basically - if the user updates the text and it is not equal to the stored PHN, then remove the data
            if text != self.rememberDetails.storageArray?.first?.phn {
                self.rememberedPHNSelected = false
            } else if text == self.rememberDetails.storageArray?.first?.phn {
                self.rememberedPHNSelected = true
            }
        }
        
    }
}

// MARK: Custom Text Field Delegates
extension GatewayFormViewController: FormTextFieldViewDelegate {
    func resignFirstResponderUI(formField: FormTextFieldType) {
        self.view.endEditing(true)
    }
    
    func goToNextFormTextField(formField: FormTextFieldType) {
        if fetchType.canGoToNextFormField {
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
        let specificCell = FormData.getSpecificCellFromFormTextField(formField)
        let shownDS = dataSource.filter { $0.isFieldVisible }
        guard var indexPath = getIndexPathForSpecificCell(specificCell, inDS: self.dataSource, usingOnlyShownCells: true), indexPath.row < (shownDS.count - 1) else { return }
//        guard let index = self.getIndexInDataSource(formField: formField, dataSource: self.dataSource), index < (dataSource.count - 1) else { return }
        let newRow = indexPath.row + 1
        indexPath.row = newRow
        if shownDS[indexPath.row].specificCell.isTextField, let cell = self.tableView.cellForRow(at: indexPath) as? FormTableViewCell {
            // Go to this cell
            cell.formTextFieldView.openKeyboardAction()
        } else if let firstIndexPath = getIndexPathForSpecificCell(.phnForm, inDS: self.dataSource, usingOnlyShownCells: true) {
            // find first index of text field in data source (Note: This is hardcorded as PHN - if the order changes, then this will have to change too
            if let firstCell = self.tableView.cellForRow(at: firstIndexPath) as? FormTableViewCell {
                firstCell.formTextFieldView.openKeyboardAction()
            }
        }
    }
}

// MARK: For Button tap and enabling
extension GatewayFormViewController: AppStyleButtonDelegate {
    func buttonTapped(type: AppStyleButton.ButtonType) {
        if type == .cancel {
            self.navigationController?.popViewController(animated: true)
        } else if type == .submit {
            // TODO: Should refactor this: - Will do when network layer gets added
            if fetchType == .covid19TestResult {
//                // TODO: Show dummy data response here
//                guard let phnIndexPath = getIndexPathForSpecificCell(.phnForm, inDS: self.dataSource, usingOnlyShownCells: false) else { return }
//                guard let phn = dataSource[phnIndexPath.row].configuration.text?.removeWhiteSpaceFormatting else { return }
//                if let index = Constants.testResultsDummyData.firstIndex(where: { $0.phn == phn }) {
//                    let data = Constants.testResultsDummyData[index].data
//                    guard let response = data.response else { return }
//                    // TODO: add correct birthdate and phn
//                    let _ = StorageService.shared.saveTestResult(phn: phn , birthdate: Date(), gateWayResponse: response)
//                    // Note - will have to fix this obviously and route properly
//                    self.popBack(toControllerType: HealthRecordsViewController.self)
//                }
                // TODO: Add in network layer here
            } else {
                prepareRequestForVaccineCard() // Note: This should be refactored to be more reusable
            }
        }
    }
    
    func shouldButtonBeEnabled() -> Bool {
        let formData = dataSource.compactMap { $0.transform() }
        let countArray: [Bool] = formData.map { textFieldData in
            guard let text = textFieldData.text else {
                return false
            }
            let error = textFieldData.type.setErrorValidationMessage(text: text)
            return error == nil
        }
        return countArray.filter { $0 == true }.count == dataSource.filter({ $0.specificCell.isTextField }).count
    }

}

// MARK: Health Gateway worker
extension GatewayFormViewController: HealthGatewayAPIWorkerDelegate {
    func handleVaccineCard(scanResult: ScanResultModel, fedCode: String?) {
        var model = convertScanResultModelIntoLocalData(data: scanResult, source: .healthGateway)
        model.fedCode = fedCode
        // store prefered PHN if needed here
        self.rememberedPHNSelected ? storePHNDetails() : removePHNDetailsIfNeccessary()
        // TODO: Should probably put this endLoadingIndicator inside the handleCardInCoreData call
        hideLoader()
        handleCardInCoreData(localModel: model, replacing: fetchType.originalCode)
    }
    
    func handleTestResult(result: GatewayTestResultResponse) {
        // TODO: Handle result locally here
    }
    
    func handleError(title: String, error: ResultError) {
        hideLoader()
        if error.resultMessage == "Unknown" {
            alert(title: title, message: .unknownErrorMessage)
        } else {
            alert(title: title, message: error.resultMessage ?? .healthGatewayError)
        }
        
    }
    
    func showLoader() {
        self.view.startLoadingIndicator(backgroundColor: .clear)
    }
    
    func hideLoader() {
        self.view.endLoadingIndicator()
    }
    
    func updateCardInLocalStorage(model: AppVaccinePassportModel) {
        self.updateCardInLocalStorage(model: model.transform(), completion: { [weak self] _ in
            guard let `self` = self else {return}
            let fedCode = self.fetchType.isFedPassOnly ? model.codableModel.fedCode : nil
            self.completionHandler?(model.id ?? "", fedCode)
        })
    }
    
    func storeCardInLocalStorage(model: AppVaccinePassportModel) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.appendModelToLocalStorage(model: model.transform())
            let fedCode = self.fetchType.isFedPassOnly ? model.codableModel.fedCode : nil
            self.completionHandler?(model.id ?? "", fedCode)
            
        }
    }
    
    func updateFederalPassInLocalStorge(model: AppVaccinePassportModel) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            guard let fedCode = model.codableModel.fedCode else {
                return
            }
            self.updateFedCodeForCardInLocalStorage(model: model.transform(), completion: { [weak self] _ in
                guard let `self` = self else {return}
                let fedCode = self.fetchType.isFedPassOnly ? model.codableModel.fedCode : nil
                self.completionHandler?(model.id ?? "", fedCode)
            })
        }
    }
    
    func handleCardInCoreData(localModel: LocallyStoredVaccinePassportModel, replacing code: String?) {
        let model = localModel.transform()
        if fetchType.isFedPassOnly, let codeToReplace = code {
            StorageService.shared.deleteVaccineCard(vaccineQR: codeToReplace)
        }
        model.state { [weak self] state in
            guard let `self` = self else {return}
            switch state {
            case .exists, .isOutdated:
                self.alert(title: .duplicateTitle, message: .duplicateMessage) { [weak self] in
                    guard let `self` = self else {return}
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                    }
                    self.completionHandler?(model.id ?? "", nil)
                }
            case .isNew:
                self.storeCardInLocalStorage(model: model)
            case .canUpdateExisting:
                self.alert(title: .updatedCard, message: "\(String.updateCardFor) \(model.transform().name)", buttonOneTitle: "Yes", buttonOneCompletion: { [weak self] in
                    guard let `self` = self else {return}
                    self.updateCardInLocalStorage(model: model)
                }, buttonTwoTitle: "No") { [weak self] in
                    guard let `self` = self else {return}
                    self.completionHandler?(model.id ?? "", nil)
                }
            case .UpdatedFederalPass:
                self.updateFederalPassInLocalStorge(model: model)
            }
        }
    }
    
    
}

