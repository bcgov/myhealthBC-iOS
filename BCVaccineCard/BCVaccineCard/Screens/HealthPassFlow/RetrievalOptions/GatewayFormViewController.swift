//
//  ViewController.swift
//  ClientVaxPass-POC
//
//  Created by Connor Ogilvie on 2021-09-09.
//

import UIKit
import QueueITLibrary
import Alamofire

class GatewayFormViewController: BaseViewController {
    
    class func constructGatewayFormViewController() -> GatewayFormViewController {
        if let vc = Storyboard.healthPass.instantiateViewController(withIdentifier: String(describing: GatewayFormViewController.self)) as? GatewayFormViewController {
            vc.healthGateway = GatewayAccess.factory.makeHealthGatewayBCGateway()
            return vc
        }
        return GatewayFormViewController()
    }
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet weak var cancelButton: AppStyleButton!
    @IBOutlet weak var submitButton: AppStyleButton!
    
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
        setupDataSource()
        setupTableView()
        setupQueueItWorker()
    }
    
    private func setupButtons() {
        cancelButton.configure(withStyle: .white, buttonType: .cancel, delegateOwner: self, enabled: true)
        submitButton.configure(withStyle: .blue, buttonType: .submit, delegateOwner: self, enabled: false)
    }
    
    private func setupDataSource() {
        dataSource = [
            FormDataSource(type: .text(type: .plainText, font: UIFont.bcSansRegularWithSize(size: 16)), cellStringData: .formDescription),
            FormDataSource(type: .form(type: .personalHealthNumber), cellStringData: nil),
            FormDataSource(type: .form(type: .dateOfBirth), cellStringData: nil),
            FormDataSource(type: .form(type: .dateOfVaccination), cellStringData: nil),
            FormDataSource(type: .text(type: .underlinedWithImage, font: UIFont.bcSansBoldWithSize(size: 14)), cellStringData: .privacyStatement)
        ]
    }
    
    private func setupQueueItWorker() {
        self.worker = QueueItWorker(delegateOwner: self, healthGateway: self.healthGateway, delegate: self, endpoint: self.endpoint)
    }

}

// MARK: Navigation setup
extension GatewayFormViewController {
    private func navSetup() {
        self.navDelegate?.setNavigationBarWith(title: .addABCVaccineCard,
                                               leftNavButton: nil,
                                               rightNavButton: NavButton(image: UIImage(named: "help-icon"), action: #selector(self.helpIconButton)),
                                               navStyle: .small,
                                               targetVC: self)
        applyNavAccessibility()
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
                return cell
            }
            return UITableViewCell()
        case .form(type: let type):
            if let cell = tableView.dequeueReusableCell(withIdentifier: FormTableViewCell.getName, for: indexPath) as? FormTableViewCell {
                cell.configure(formType: type, delegateOwner: self)
                return cell
            }
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? FormTableViewCell {
            cell.formTextFieldView.openKeyboardAction()
        } else if let cell = tableView.cellForRow(at: indexPath) as? TextTableViewCell, cell.type == .underlinedWithImage {
            alert(title: .privacyStatement, message: .gatewayPrivacyStatementDescription)
        }
    }
}

// MARK: Update data source
extension GatewayFormViewController {
    func updateDataSource(formField: FormTextFieldType, text: String?) {
        guard let index = getIndexInDataSource(formField: formField, dataSource: self.dataSource) else { return }
        self.dataSource[index].cellStringData = text
        
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
        goToNextTextField(formField: formField)
    }
    
    func didFinishEditing(formField: FormTextFieldType, text: String?) {
        updateDataSource(formField: formField, text: text)
        submitButtonEnabled = shouldButtonBeEnabled()
    }
    
    func textFieldTextDidChange(formField: FormTextFieldType, newText: String) {
        updateDataSource(formField: formField, text: newText)
        submitButtonEnabled = shouldButtonBeEnabled()
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

// MARK: Accessibility
extension GatewayFormViewController {
    private func applyNavAccessibility() {
        if let nav = self.navigationController as? CustomNavigationController {
            if let rightNavButton = nav.getRightBarButtonItem() {
                rightNavButton.accessibilityTraits = .button
                rightNavButton.accessibilityLabel = "Close"
                rightNavButton.accessibilityHint = "Tapping this button will close this screen and return you to your passes screen"
            }
            if let leftNavButton = nav.getLeftBarButtonItem() {
                // TODO: Need to investigate here - not a priority right now though, as designs will likely change
            }
        }
    }
}

// MARK: QueueItWorkerDefaultsDelegate
extension GatewayFormViewController: QueueItWorkerDefaultsDelegate {
    func handleVaccineCard(localModel: LocallyStoredVaccinePassportModel) {
        handleCardInDefaults(localModel: localModel)
    }
    
    func handleError(title: String, error: ResultError) {
        if error.resultMessage == "Unknown" {
            alert(title: title, message: "Unknown error has occured. Please try again.")
        } else {
            alert(title: title, message: error.resultMessage ?? "Health Gateway error")
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
        if doesCardNeedToBeUpdated(modelToUpdate: model) {
            self.navigationController?.popViewController(animated: true)
            self.updateCardInLocalStorage(model: model.transform())
            self.completionHandler?(model.id ?? "")
        } else {
            guard isCardAlreadyInWallet(modelToAdd: model) == false else {
                alert(title: "Duplicate", message: "This vaccine pass is already saved in your list of passes.") { [weak self] in
                    guard let `self` = self else {return}
                    self.navigationController?.popViewController(animated: true)
                    self.completionHandler?(model.id ?? "")
                }
                return
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.navigationController?.popViewController(animated: true)
                self.appendModelToLocalStorage(model: model.transform())
                self.completionHandler?(model.id ?? "")
                
            }
        }
    }
}

