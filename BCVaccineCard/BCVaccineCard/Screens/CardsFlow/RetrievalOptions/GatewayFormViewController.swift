//
//  ViewController.swift
//  ClientVaxPass-POC
//
//  Created by Connor Ogilvie on 2021-09-09.
//

import UIKit

class GatewayFormViewController: UIViewController {
    
    class func constructGatewayFormViewController() -> GatewayFormViewController {
        if let vc = Storyboard.main.instantiateViewController(withIdentifier: String(describing: GatewayFormViewController.self)) as? GatewayFormViewController {
            return vc
        }
        return GatewayFormViewController()
    }
    
    @IBOutlet private weak var formTitleLabel: UILabel!
    @IBOutlet private weak var separatorView: UIView! // colour it yellow
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet weak var cancelButton: AppStyleButton!
    @IBOutlet weak var enterButton: AppStyleButton!
    
    var completionHandler: (() -> Void)?
    private var dataSource: [GatewayFormData] = []
    private var enterButtonEnabled: Bool = false {
        didSet {
            enterButton.enabled = enterButtonEnabled
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup() {
        setupUI()
        setupButtons()
        setupDataSource()
        setupTableView()
    }
    
    private func setupUI() {
        separatorView.backgroundColor = AppColours.barYellow
        formTitleLabel.font = UIFont.bcSansBoldWithSize(size: 18)
        formTitleLabel.textColor = AppColours.textBlack
        formTitleLabel.text = Constants.Strings.MyCardFlow.Form.title
    }
    
    private func setupButtons() {
        cancelButton.configure(withStyle: .white, buttonType: .cancel, delegateOwner: self, enabled: true)
        enterButton.configure(withStyle: .blue, buttonType: .enter, delegateOwner: self, enabled: false)
    }
    
    private func setupDataSource() {
        dataSource = [
            GatewayFormData(type: .text(type: .plainText, font: UIFont.bcSansRegularWithSize(size: 16)), cellStringData: Constants.Strings.MyCardFlow.Form.description),
            GatewayFormData(type: .form(type: .personalHealthNumber), cellStringData: nil),
            GatewayFormData(type: .form(type: .dateOfBirth), cellStringData: nil),
            GatewayFormData(type: .form(type: .dateOfVaccination), cellStringData: nil),
            GatewayFormData(type: .text(type: .underlinedWithImage, font: UIFont.bcSansBoldWithSize(size: 14)), cellStringData: Constants.Strings.MyCardFlow.Form.privacyStatement)
        ]
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
            self.openPrivacyPolicy()
        }
    }
}

// MARK: Update data source
extension GatewayFormViewController {
    func updateDataSource(formField: FormTextFieldType, text: String?) {
        guard let index = getIndexInDataSource(formField: formField, dataSource: self.dataSource) else { return }
        self.dataSource[index].cellStringData = text
        
    }
    
    private func getIndexInDataSource(formField: FormTextFieldType, dataSource: [GatewayFormData]) -> Int? {
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
        enterButtonEnabled = shouldButtonBeEnabled()
    }
    
    func textFieldTextDidChange(formField: FormTextFieldType, newText: String) {
        updateDataSource(formField: formField, text: newText)
        enterButtonEnabled = shouldButtonBeEnabled()
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

// MARK: FIXME: This is just temporary so that we can test UI with local data
extension GatewayFormViewController {
    func checkForPHN(phnString: String, birthday: String) {
        var model: AppVaccinePassportModel
        let phn = phnString.trimWhiteSpacesAndNewLines.removeWhiteSpaceFormatting
        let name: String
        let image: UIImage?
        
        var status: VaccineStatus
        if phn == "1111111111" {
            status = .fully
            name = "WILLIE BEAMEN"
            image = UIImage(named: "full")
        } else if phn == "2222222222" {
            status = .partially
            name = "RON BERGUNDY"
            image = UIImage(named: "partial")
        } else {
            status = .notVaxed
            name = "BRICK TAMLAND"
            image = nil
        }
        guard let img = image else {
            alert(title: "Error", message: "Invalid PHN number, no QR code associated with this number")
            return
        }
        let code = img.toPngString() ?? ""
        model = AppVaccinePassportModel(codableModel: LocallyStoredVaccinePassportModel(code: code, birthdate: birthday, name: name, issueDate: 1632413161, status: status))
        // This obviously needs to be refactored, but not going to bother, being that we are going to be removing it and hitting an endpoint.
        if doesCardNeedToBeUpdated(modelToUpdate: model) {
            alert(title: "Success", message: "Congrats! You have successfully updated your vaxine QR code. Would you like to save this card to your list of cards?", buttonOneTitle: "No", buttonOneCompletion: { [weak self] in
                guard let `self` = self else { return }
                self.dismiss(animated: true, completion: nil)
                // No Nothing, just dismiss
            }, buttonTwoTitle: "Yes") { [weak self] in
                guard let `self` = self else { return }
                self.dismiss(animated: true) {
                    self.updateCardInLocalStorage(model: model.transform())
                    self.postCardAddedNotification(id: model.id ?? "")
                    self.completionHandler?()
                }
            }
        } else {
            guard isCardAlreadyInWallet(modelToAdd: model) == false else {
                alert(title: "Duplicate", message: "This card is already saved in your wallet.") { [weak self] in
                    guard let `self` = self else {return}
                    self.dismiss(animated: true) {
                        self.completionHandler?()
                    }
                }
                return
            }
            alert(title: "Success", message: "Congrats! You have successfully fetched your vaxine QR code. Would you like to save this card to your list of cards?", buttonOneTitle: "No", buttonOneCompletion: { [weak self] in
                guard let `self` = self else { return }
                self.dismiss(animated: true, completion: nil)
                // No Nothing, just dismiss
            }, buttonTwoTitle: "Yes") { [weak self] in
                guard let `self` = self else { return }
                self.dismiss(animated: true) {
                    self.appendModelToLocalStorage(model: model.transform())
                    self.postCardAddedNotification(id: model.id ?? "")
                    self.completionHandler?()
                }
            }
        }
    }
}



// MARK: For Button tap events
extension GatewayFormViewController: AppStyleButtonDelegate {
    func buttonTapped(type: AppStyleButton.ButtonType) {
        if type == .cancel {
            self.dismiss(animated: true, completion: nil)
        } else if type == .enter {
            guard let phnIndex = getIndexInDataSource(formField: .personalHealthNumber, dataSource: self.dataSource) else { return }
            guard let phn = dataSource[phnIndex].cellStringData else { return }
            guard let dobIndex = getIndexInDataSource(formField: .dateOfBirth, dataSource: self.dataSource) else { return }
            guard let birthday = dataSource[dobIndex].cellStringData else { return }
            checkForPHN(phnString: phn, birthday: birthday)
        }
    }
}

