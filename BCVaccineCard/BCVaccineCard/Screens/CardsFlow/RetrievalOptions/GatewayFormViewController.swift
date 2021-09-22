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
            GatewayFormData(type: .text(type: .plainText), cellStringData: Constants.Strings.MyCardFlow.Form.description),
            GatewayFormData(type: .form(type: .personalHealthNumber), cellStringData: nil),
            GatewayFormData(type: .form(type: .dateOfBirth), cellStringData: nil),
            GatewayFormData(type: .form(type: .dateOfVaccination), cellStringData: nil),
            GatewayFormData(type: .text(type: .underlinedWithImage), cellStringData: Constants.Strings.MyCardFlow.Form.privacyStatement)
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
        case .text(type: let type):
            if let cell = tableView.dequeueReusableCell(withIdentifier: TextTableViewCell.getName, for: indexPath) as? TextTableViewCell, let text = data.cellStringData {
                cell.configure(forType: type, text: text, withFont: UIFont.bcSansRegularWithSize(size: 16))
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
    func checkForPHN(phnString: String) {
        var model: AppVaccinePassportModel
        let phn = phnString.trimWhiteSpacesAndNewLines.removeWhiteSpaceFormatting
        let name: String
        let image: UIImage?
        let birthday: String
        
        var status: VaccineStatus
        if phn == "1111111111" {
            status = .fully
            name = "WILLIE BEAMEN"
            image = UIImage(named: "full")
            birthday = "September 15, 1980"
        } else if phn == "2222222222" {
            status = .partially
            name = "RON BERGUNDY"
            image = UIImage(named: "partial")
            birthday = "December 15, 1964"
        } else {
            status = .notVaxed
            name = "BRICK TAMLAND"
            image = nil
            birthday = "October 12, 1945"
        }
        guard let img = image else {
            alert(title: "Error", message: "Invalid PHN number, no QR code associated with this number")
            return
        }
        let code = img.toPngString() ?? ""
        model = AppVaccinePassportModel(codableModel: LocallyStoredVaccinePassportModel(code: code, birthdate: birthday, name: name, status: status))
        alert(title: "Success", message: "Congrats! You have successfully fetched your vaxine QR code. Would you like to save this card to your list of cards?", buttonOneTitle: "Yes", buttonOneCompletion: {
            self.dismiss(animated: true) {
                self.appendModelToLocalStorage(model: model.transform())
                self.completionHandler?()
            }
        }, buttonTwoTitle: "No") { [weak self] in
            guard let `self` = self else { return }
            self.dismiss(animated: true, completion: nil)
            // No Nothing, just dismiss
        }
    }
}



// MARK: For Button tap events
extension GatewayFormViewController: AppStyleButtonDelegate {
    func buttonTapped(type: AppStyleButton.ButtonType) {
        if type == .cancel {
            self.dismiss(animated: true, completion: nil)
        } else if type == .enter {
            guard let index = getIndexInDataSource(formField: .personalHealthNumber, dataSource: self.dataSource) else { return }
            guard let phn = dataSource[index].cellStringData else { return }
            checkForPHN(phnString: phn)
        }
    }
}

