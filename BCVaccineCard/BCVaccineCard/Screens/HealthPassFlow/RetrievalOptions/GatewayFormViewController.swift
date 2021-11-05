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
import QueueITLibrary
import Alamofire
import BCVaccineValidator

enum GatewayFormViewControllerFetchType: Equatable {
    case bcVaccineCardAndFederalPass
    case federalPassOnly(dob: String, dov: String)
    case vaccinationRecord
    
    var ds: [FormData] {
        switch self {
        case .bcVaccineCardAndFederalPass:
            return [
                FormData(specificCell: .phnForm, configuration: FormData.Configuration(isTextField: true), isFieldVisible: true),
                FormData(specificCell: .dobForm, configuration: FormData.Configuration(isTextField: true), isFieldVisible: true),
                FormData(specificCell: .dovForm, configuration: FormData.Configuration(isTextField: true), isFieldVisible: true),
                FormData(specificCell: .rememberCheckbox, configuration: FormData.Configuration(text: .rememberePHNandDOB, isTextField: false), isFieldVisible: true),
                FormData(specificCell: .clickablePrivacyPolicy, configuration: FormData.Configuration(text: .privacyPolicyStatementEmail, linkedStrings: [
                    LinkedStrings(text: .privacyPolicyStatementEmail, link: .privacyPolicyStatementEmailLink),
                    LinkedStrings(text: .privacyPolicyStatementPhoneNumber, link: .privacyPolicyStatementPhoneNumberLink)], isTextField: false), isFieldVisible: true)]
        case .federalPassOnly(let dob, let dov):
            return [
                FormData(specificCell: .phnForm, configuration: FormData.Configuration(isTextField: true), isFieldVisible: true),
                FormData(specificCell: .dobForm, configuration: FormData.Configuration(text: dob, isTextField: true), isFieldVisible: false),
                FormData(specificCell: .dovForm, configuration: FormData.Configuration(text: dov, isTextField: true), isFieldVisible: false),
                FormData(specificCell: .clickablePrivacyPolicy, configuration: FormData.Configuration(text: .privacyPolicyStatementEmail, linkedStrings: [
                    LinkedStrings(text: .privacyPolicyStatementEmail, link: .privacyPolicyStatementEmailLink),
                    LinkedStrings(text: .privacyPolicyStatementPhoneNumber, link: .privacyPolicyStatementPhoneNumberLink)], isTextField: false), isFieldVisible: true)]
        case .vaccinationRecord:
            return [
                FormData(specificCell: .phnForm, configuration: FormData.Configuration(isTextField: true), isFieldVisible: true),
                FormData(specificCell: .dobForm, configuration: FormData.Configuration(isTextField: true), isFieldVisible: true),
                FormData(specificCell: .dovForm, configuration: FormData.Configuration(isTextField: true), isFieldVisible: true),
                FormData(specificCell: .rememberCheckbox, configuration: FormData.Configuration(text: .rememberePHNandDOB, isTextField: false), isFieldVisible: true),
                FormData(specificCell: .clickablePrivacyPolicy, configuration: FormData.Configuration(text: .privacyPolicyStatementEmail, linkedStrings: [
                    LinkedStrings(text: .privacyPolicyStatementEmail, link: .privacyPolicyStatementEmailLink),
                    LinkedStrings(text: .privacyPolicyStatementPhoneNumber, link: .privacyPolicyStatementPhoneNumberLink)], isTextField: false), isFieldVisible: true)]
        }
    }
    
    var getDataSource: [FormDataSource] {
        switch self {
        case .bcVaccineCardAndFederalPass:
            return [
//                FormDataSource(type: .text(type: .plainText, font: UIFont.bcSansRegularWithSize(size: 16)), cellStringData: .formDescription, specificCell: .introText),
                FormDataSource(type: .form(type: .personalHealthNumber), cellStringData: nil, specificCell: .phnForm),
                FormDataSource(type: .form(type: .dateOfBirth), cellStringData: nil, specificCell: .dobForm),
                FormDataSource(type: .form(type: .dateOfVaccination), cellStringData: nil, specificCell: .dovForm),
                FormDataSource(type: .checkbox(text: .rememberePHNandDOB), cellStringData: nil, specificCell: .rememberCheckbox),
                FormDataSource(type: .clickableText(text: .privacyPolicyStatement, linkedStrings: [LinkedStrings(text: .privacyPolicyStatementEmail, link: .privacyPolicyStatementEmailLink), LinkedStrings(text: .privacyPolicyStatementPhoneNumber, link: .privacyPolicyStatementPhoneNumberLink)]), cellStringData: nil, specificCell: .clickablePrivacyPolicy)
            ]
        case .federalPassOnly:
            return [
//                FormDataSource(type: .text(type: .plainText, font: UIFont.bcSansRegularWithSize(size: 16)), cellStringData: .formDescription, specificCell: .introText),
                FormDataSource(type: .form(type: .personalHealthNumber), cellStringData: nil, specificCell: .phnForm),
                FormDataSource(type: .clickableText(text: .privacyPolicyStatement, linkedStrings: [LinkedStrings(text: .privacyPolicyStatementEmail, link: .privacyPolicyStatementEmailLink), LinkedStrings(text: .privacyPolicyStatementPhoneNumber, link: .privacyPolicyStatementPhoneNumberLink)]), cellStringData: nil, specificCell: .clickablePrivacyPolicy)
            ]
        case .vaccinationRecord:
            return [
//                FormDataSource(type: .text(type: .plainText, font: UIFont.bcSansRegularWithSize(size: 16)), cellStringData: .formDescription, specificCell: .introText),
                FormDataSource(type: .form(type: .personalHealthNumber), cellStringData: nil, specificCell: .phnForm),
                FormDataSource(type: .form(type: .dateOfBirth), cellStringData: nil, specificCell: .dobForm),
                FormDataSource(type: .form(type: .dateOfVaccination), cellStringData: nil, specificCell: .dovForm),
                FormDataSource(type: .checkbox(text: .rememberePHNandDOB), cellStringData: nil, specificCell: .rememberCheckbox),
                FormDataSource(type: .clickableText(text: .privacyPolicyStatement, linkedStrings: [LinkedStrings(text: .privacyPolicyStatementEmail, link: .privacyPolicyStatementEmailLink), LinkedStrings(text: .privacyPolicyStatementPhoneNumber, link: .privacyPolicyStatementPhoneNumberLink)]), cellStringData: nil, specificCell: .clickablePrivacyPolicy)
            ]
        }
    }
}

class GatewayFormViewController: BaseViewController {
    
    class func constructGatewayFormViewController(rememberDetails: RememberedGatewayDetails, fetchType: GatewayFormViewControllerFetchType) -> GatewayFormViewController {
        if let vc = Storyboard.healthPass.instantiateViewController(withIdentifier: String(describing: GatewayFormViewController.self)) as? GatewayFormViewController {
            vc.healthGateway = GatewayAccess.factory.makeHealthGatewayBCGateway()
            vc.rememberDetails = rememberDetails
            vc.fetchType = fetchType
            vc.dataSource = fetchType.getDataSource
            return vc
        }
        return GatewayFormViewController()
    }
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet weak var cancelButton: AppStyleButton!
    @IBOutlet weak var submitButton: AppStyleButton!
    
    private var rememberDetails: RememberedGatewayDetails!
    private var fetchType: GatewayFormViewControllerFetchType!
    private var whiteSpaceFormattedPHN: String?
    private var rememberedPHNSelected: Bool = false {
        didSet {
            guard let indexPath = getIndexPathForSpecificCell(.rememberCheckbox, inDS: self.dataSource) else { return }
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
    private var dropDownView: DropDownView?
    private var model: GatewayVaccineCardRequest?
    private var worker: QueueItWorker?
    private var healthGateway: HealthGatewayBCGateway!
    private var endpoint = UrlAccessor().getVaccineCard
    
    var completionHandler: ((String) -> Void)?
    private var dataSource: [FormDataSource] = []
    private var submitButtonEnabled: Bool = false {
        didSet {
            submitButton.enabled = submitButtonEnabled
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
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
//        return .lightContent
        if #available(iOS 13.0, *) {
            return UIStatusBarStyle.darkContent
        } else {
            return UIStatusBarStyle.default
        }
    }
    
    private func setup() {
        setupButtons()
//        setupDataSource()
        setupTableView()
        setupQueueItWorker()
    }
    
    private func setupButtons() {
        cancelButton.configure(withStyle: .white, buttonType: .cancel, delegateOwner: self, enabled: true)
        submitButton.configure(withStyle: .blue, buttonType: .submit, delegateOwner: self, enabled: false)
    }
    
//    private func setupDataSource() {
//        dataSource = [
//            FormDataSource(type: .text(type: .plainText, font: UIFont.bcSansRegularWithSize(size: 16)), cellStringData: .formDescription, specificCell: .introText),
//            FormDataSource(type: .form(type: .personalHealthNumber), cellStringData: nil, specificCell: .phnForm),
//            FormDataSource(type: .form(type: .dateOfBirth), cellStringData: nil, specificCell: .dobForm),
//            FormDataSource(type: .form(type: .dateOfVaccination), cellStringData: nil, specificCell: .dovForm),
//            FormDataSource(type: .checkbox(text: .rememberePHNandDOB), cellStringData: nil, specificCell: .rememberCheckbox),
//            FormDataSource(type: .clickableText(text: .privacyPolicyStatement, linkedStrings: [LinkedStrings(text: .privacyPolicyStatementEmail, link: .privacyPolicyStatementEmailLink), LinkedStrings(text: .privacyPolicyStatementPhoneNumber, link: .privacyPolicyStatementPhoneNumberLink)]), cellStringData: nil, specificCell: .clickablePrivacyPolicy)
//        ]
//    }
    
    private func setupQueueItWorker() {
        self.worker = QueueItWorker(delegateOwner: self, healthGateway: self.healthGateway, delegate: self, endpoint: self.endpoint)
    }

}

// MARK: Navigation setup
extension GatewayFormViewController {
    private func navSetup() {
        self.navDelegate?.setNavigationBarWith(title: .addABCVaccineCard,
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
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = dataSource[indexPath.row]
        switch data.type {
        case .text(type: let type, font: let font):
            if let cell = tableView.dequeueReusableCell(withIdentifier: TextTableViewCell.getName, for: indexPath) as? TextTableViewCell, let text = data.cellStringData {
                cell.configure(forType: type, text: text, withFont: font)
                cell.accessibilityTraits = .button
                return cell
            }
            return UITableViewCell()
        case .form(type: let type):
            if let cell = tableView.dequeueReusableCell(withIdentifier: FormTableViewCell.getName, for: indexPath) as? FormTableViewCell {
                cell.configure(formType: type, delegateOwner: self, rememberedDetails: self.rememberDetails, text: data.cellStringData)
                return cell
            }
            return UITableViewCell()
        case .checkbox(text: let text):
            if let cell = tableView.dequeueReusableCell(withIdentifier: CheckboxTableViewCell.getName, for: indexPath) as? CheckboxTableViewCell {
                cell.configure(selected: self.rememberedPHNSelected, text: text, delegateOwner: self)
                return cell
            }
            return UITableViewCell()
        case .clickableText(text: let text, linkedStrings: let linkedStrings):
            if let cell = tableView.dequeueReusableCell(withIdentifier: InteractiveLabelTableViewCell.getName, for: indexPath) as? InteractiveLabelTableViewCell {
                cell.configure(string: text, linkedStrings: linkedStrings, textColor: AppColours.textBlack, font: UIFont.bcSansRegularWithSize(size: 13))
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
    // NOTE: Having issues with keychain right now, so will be using user defaults in the meantime
    private func storePHNDetails() {
        guard let model = self.model else { return }
        if self.model?.phn == self.whiteSpaceFormattedPHN?.removeWhiteSpaceFormatting, self.whiteSpaceFormattedPHN != nil {
            let rememberProperties = GatewayStorageProperties(phn: self.whiteSpaceFormattedPHN!, dob: model.dateOfBirth)
            guard rememberProperties.phn != self.rememberDetails.storageArray?.first?.phn else { return }
            // NOTE: This is where we can append data to existing storage for abilitly to store multiple pieces of data
            let rememberKeychainStorage = RememberedGatewayDetails(storageArray: [rememberProperties])
    //        let data = Data(from: rememberKeychainStorage)
    //        let status = KeyChain.save(key: Constants.KeychainPHNKey.key, data: data)
            Defaults.rememberGatewayDetails = rememberKeychainStorage
            // TODO: Error handling here for keychain
            print("CONNOR: SAVE STATUS")
        }
    }
    
    private func removePHNDetailsIfNeccessary() {
        // TODO: Come up with a better method here
        let rememberKeychainStorage = RememberedGatewayDetails(storageArray: nil)
//        let data = Data(from: rememberKeychainStorage)
//        let status = KeyChain.save(key: Constants.KeychainPHNKey.key, data: data)
        // Note: If remember details is unchecked, and the phn used is not the same as the remembered phn, then we do nothing
        if self.model?.phn.removeWhiteSpaceFormatting == self.rememberDetails.storageArray?.first?.phn.removeWhiteSpaceFormatting {
            Defaults.rememberGatewayDetails = rememberKeychainStorage
        }
        // TODO: Error handling here for keychain
        print("CONNOR: 'DELETE' STATUS")
    }
    
}

// MARK: Helper function to return index path of a given cell type
extension GatewayFormViewController {
    private func getIndexPathForSpecificCell(_ specificCell: FormDataSource.SpecificCell, inDS ds: [FormDataSource]) -> IndexPath? {
        var indexPath: IndexPath?
        if let index = ds.firstIndex(where: { $0.specificCell == specificCell }) {
            indexPath = IndexPath(row: index, section: 0)
        }
        return indexPath
    }
}

// MARK: Drop down delegate
extension GatewayFormViewController: DropDownViewDelegate {
    func didChooseStoragePHN(details: GatewayStorageProperties) {
        if details.phn == self.rememberDetails.storageArray?.first?.phn {
            self.rememberedPHNSelected = true
            var indexPaths: [IndexPath] = []
            guard let firstIP = getIndexPathForSpecificCell(.phnForm, inDS: self.dataSource) else { return }
            indexPaths.append(firstIP)
            dataSource[firstIP.row].cellStringData = details.phn
            if fetchType == .bcVaccineCardAndFederalPass {
                guard let secondIP = getIndexPathForSpecificCell(.dobForm, inDS: self.dataSource) else {
                    return
                }
                indexPaths.append(secondIP)
                dataSource[secondIP.row].cellStringData = details.dob
            }
            self.tableView.reloadRows(at: indexPaths, with: .automatic)
        }
        if let dropDownView = dropDownView {
            self.dismissDropDownView(dropDownView: dropDownView)
        }
    }

}

// MARK: Update data source
extension GatewayFormViewController {
    func updateDataSource(formField: FormTextFieldType, text: String?) {
        guard let index = getIndexInDataSource(formField: formField, dataSource: self.dataSource) else { return }
        self.dataSource[index].cellStringData = text
        if formField == .personalHealthNumber {
            // Basically - if the user updates the text and it is not equal to the stored PHN, then remove the data
            if text != self.rememberDetails.storageArray?.first?.phn {
                self.rememberedPHNSelected = false
            } else if text == self.rememberDetails.storageArray?.first?.phn {
                self.rememberedPHNSelected = true
            }
        }
        
    }
    
    private func getIndexInDataSource(formField: FormTextFieldType, dataSource: [FormDataSource]) -> Int? {
        return dataSource.firstIndex { $0.type == .form(type: formField) }
    }
}

// MARK: Custom Text Field Delegates
extension GatewayFormViewController: FormTextFieldViewDelegate {
    func resignFirstResponderUI(formField: FormTextFieldType) {
        self.view.endEditing(true)
    }
    
    func goToNextFormTextField(formField: FormTextFieldType) {
        if fetchType == .bcVaccineCardAndFederalPass {
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
        guard let index = self.getIndexInDataSource(formField: formField, dataSource: self.dataSource), index < (dataSource.count - 1) else { return }
        let newIndex = index + 1
        let newIndexPath = IndexPath(row: newIndex, section: 0)
        if dataSource[newIndex].isTextField(), let cell = self.tableView.cellForRow(at: newIndexPath) as? FormTableViewCell {
            // Go to this cell
            cell.formTextFieldView.openKeyboardAction()
        } else if let firstIndex = getIndexInDataSource(formField: .personalHealthNumber, dataSource: dataSource) {
            // find first index of text field in data source (Note: This is hardcorded as PHN - if the order changes, then this will have to change too
            let firstIndexPath = IndexPath(row: firstIndex, section: 0)
            if let firstCell = self.tableView.cellForRow(at: firstIndexPath) as? FormTableViewCell {
                firstCell.formTextFieldView.openKeyboardAction()
            }
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
            let row = self.getIndexInDataSource(formField: .personalHealthNumber, dataSource: self.dataSource) ?? 0
            guard let relativeView = tableView.cellForRow(at: IndexPath(row: row, section: 0)) else { return }
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

// MARK: For enabling enter button
extension GatewayFormViewController {
    func shouldButtonBeEnabled() -> Bool {
        let formData = dataSource.compactMap { $0.transform() }
        let countArray: [Bool] = formData.map { textFieldData in
            guard let text = textFieldData.text else {
                return false
            }
            let error = textFieldData.type.setErrorValidationMessage(text: text)
            return error == nil
        }
        return countArray.filter { $0 == true }.count == 3
    }
}

// MARK: For Button tap events
extension GatewayFormViewController: AppStyleButtonDelegate {
    func buttonTapped(type: AppStyleButton.ButtonType) {
        if type == .cancel {
            self.navigationController?.popViewController(animated: true)
        } else if type == .submit {
            guard let phnIndex = getIndexInDataSource(formField: .personalHealthNumber, dataSource: self.dataSource) else { return }
            guard let phn = dataSource[phnIndex].cellStringData else { return }
            guard let dobIndex = getIndexInDataSource(formField: .dateOfBirth, dataSource: self.dataSource) else { return }
            guard let birthday = dataSource[dobIndex].cellStringData else { return }
            guard let dovIndex = getIndexInDataSource(formField: .dateOfVaccination, dataSource: self.dataSource) else { return }
            guard let vaxDate = dataSource[dovIndex].cellStringData else { return }
            guard let model = formatGatewayData(phn: phn, birthday: birthday, vax: vaxDate) else { return }
            self.whiteSpaceFormattedPHN = phn
            self.model = model
            worker?.createInitialVaccineCardRequest(model: model)
        }
    }
}

// MARK: Data Formatting
extension GatewayFormViewController {
    private func formatGatewayData(phn: String, birthday: String, vax: String) -> GatewayVaccineCardRequest? {
        let formattedPHN = phn.removeWhiteSpaceFormatting
        return GatewayVaccineCardRequest(phn: formattedPHN, dateOfBirth: birthday, dateOfVaccine: vax)
    }
}

// MARK: QueueItWorkerDefaultsDelegate
extension GatewayFormViewController: QueueItWorkerDefaultsDelegate {
    func handleVaccineCard(scanResult: ScanResultModel) {
        let model = convertScanResultModelIntoLocalData(data: scanResult, source: .healthGateway)
        // store prefered PHN if needed here
        self.rememberedPHNSelected ? storePHNDetails() : removePHNDetailsIfNeccessary()
        handleCardInDefaults(localModel: model)        
    }
    
    func handleError(title: String, error: ResultError) {
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
    
    func handleCardInDefaults(localModel: LocallyStoredVaccinePassportModel) {
        let model = localModel.transform()
        doesCardNeedToBeUpdated(modelToUpdate: model) {[weak self] needsUpdate in
            guard let `self` = self else {return}
            if needsUpdate {
                self.navigationController?.popViewController(animated: true)
                self.updateCardInLocalStorage(model: model.transform())
                self.completionHandler?(model.id ?? "")
            } else {
                self.isCardAlreadyInWallet(modelToAdd: model) {[weak self] isAlreadyInWallet in
                    guard let `self` = self else {return}
                    if isAlreadyInWallet {
                        self.alert(title: .duplicateTitle, message: .duplicateMessage) { [weak self] in
                            guard let `self` = self else {return}
                            self.navigationController?.popViewController(animated: true)
                            self.completionHandler?(model.id ?? "")
                        }
                        return
                    } else {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            self.navigationController?.popViewController(animated: true)
                            self.appendModelToLocalStorage(model: model.transform())
                            self.completionHandler?(model.id ?? "")
                            
                        }
                    }
                }
            }
        }
    }
}

