//
//  ViewController.swift
//  ClientVaxPass-POC
//
//  Created by Connor Ogilvie on 2021-09-09.
//

import UIKit

class GatewayFormViewController: UIViewController {
    
    class func constructGatewayFormViewController() -> GatewayFormViewController {
        if let vc = Storyboard.main.instantiateViewController(withIdentifier: "GatewayFormViewController") as? GatewayFormViewController {
            return vc
        }
        return GatewayFormViewController()
    }
    
    @IBOutlet private weak var formTitleLabel: UILabel!
    @IBOutlet private weak var separatorView: UIView! // colour it yellow
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet weak var cancelButton: AppStyleButton!
    @IBOutlet weak var enterButton: AppStyleButton!
    
    private var dataSource: [GatewayFormData] = []
//    private var validationCheck

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
//    override var preferredStatusBarStyle: UIStatusBarStyle {
//        return .lightContent
//    }
    
    private func setup() {
        setupUI()
        setupButtons()
        setupDataSource()
        setupTableView()
    }
    
    private func setupUI() {
        // TODO: Font setup here, and separator color
        formTitleLabel.text = Constants.Strings.MyCardFlow.Form.title
    }
    
    private func setupButtons() {
        cancelButton.configure(withStyle: .white, buttonType: .cancel, delegateOwner: self, enabled: true)
        enterButton.configure(withStyle: .blue, buttonType: .enter, delegateOwner: self, enabled: false)
    }
    
    private func setupDataSource() {
        dataSource = [
            GatewayFormData(type: .text(type: .plainText), cellStringData: Constants.Strings.MyCardFlow.Form.description),
            GatewayFormData(type: .form(type: .personalHealthNumber), cellStringData: nil, isFormDataValid: false),
            GatewayFormData(type: .form(type: .dateOfBirth), cellStringData: nil, isFormDataValid: false),
            GatewayFormData(type: .form(type: .dateOfVaccination), cellStringData: nil, isFormDataValid: false),
            GatewayFormData(type: .text(type: .underlinedWithImage), cellStringData: Constants.Strings.MyCardFlow.Form.privacyStatement)
        ]
    }

}

// MARK: Table View Logic
extension GatewayFormViewController: UITableViewDelegate, UITableViewDataSource {
    private func setupTableView() {
        tableView.register(UINib.init(nibName: "TextTableViewCell", bundle: .main), forCellReuseIdentifier: "TextTableViewCell")
        tableView.register(UINib.init(nibName: "FormTableViewCell", bundle: .main), forCellReuseIdentifier: "FormTableViewCell")
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
            if let cell = tableView.dequeueReusableCell(withIdentifier: "TextTableViewCell", for: indexPath) as? TextTableViewCell, let text = data.cellStringData {
                cell.configure(forType: type, text: text)
                return cell
            }
            return UITableViewCell()
        case .form(type: let type):
            if let cell = tableView.dequeueReusableCell(withIdentifier: "FormTableViewCell", for: indexPath) as? FormTableViewCell {
                cell.configure(formType: type, delegateOwner: self, indexPath: indexPath)
                return cell
            }
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // TODO: If cell is form data, then open keyboard on text field, otherwise, check if cell is clickable for text cell
        if let cell = tableView.cellForRow(at: indexPath) as? FormTableViewCell {
            cell.openKeyboardAction()
        }
    }
}

// MARK: Update data source
extension GatewayFormViewController {
    func updateDataSource(text: String?, indexPath: IndexPath, isDataValid: Bool) {
        self.dataSource[indexPath.row].cellStringData = text
        self.dataSource[indexPath.row].isFormDataValid = isDataValid
        
    }
}

extension GatewayFormViewController: FormTableViewCellDelegate {
    func doneEditing(formField: FormTableViewCellField, indexPath: IndexPath, text: String?, isDataValid: Bool) {
        // TODO: This is where we would show/resign proper responders
        updateDataSource(text: text, indexPath: indexPath, isDataValid: isDataValid)
    }
    
    func textChanged(formField: FormTableViewCellField, text: String, indexPath: IndexPath) {
        // NOT IMPLEMENTING THIS YET - Baby steps
    }
    
    
//    func textFieldValidation() -> Bool {
//        let validated = newString.count > 0
//        switch textField {
//        case phnTextField:
//            return (dobTextField.text?.count ?? 0 > 0) && (dateOfVaxTextField.text?.count ?? 0 > 0) && validated
//        case dobTextField:
//            return (phnTextField.text?.count ?? 0 > 0) && (dateOfVaxTextField.text?.count ?? 0 > 0) && validated
//        case dateOfVaxTextField:
//            return (phnTextField.text?.count ?? 0 > 0) && (dobTextField.text?.count ?? 0 > 0) && validated
//        default: return false
//        }
//    }
}

// MARK: For UITextFieldDelegate
//extension GatewayFormViewController: UITextFieldDelegate {
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        let currentString: NSString = textField.text! as NSString
//        let newString: String = currentString.replacingCharacters(in: range, with: string) as String
//        let validated = textFieldValidation(textField: textField, newString: newString)
//        enterButton.enabled = validated
//        return true
//    }
//
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        switch textField {
//        case phnTextField: dobTextField.becomeFirstResponder()
//        case dobTextField: dateOfVaxTextField.becomeFirstResponder()
//        default: textField.resignFirstResponder()
//        }
//        return true
//    }
//
//    func textFieldValidation(textField: UITextField, newString: String) -> Bool {
//        let validated = newString.count > 0
//        switch textField {
//        case phnTextField:
//            return (dobTextField.text?.count ?? 0 > 0) && (dateOfVaxTextField.text?.count ?? 0 > 0) && validated
//        case dobTextField:
//            return (phnTextField.text?.count ?? 0 > 0) && (dateOfVaxTextField.text?.count ?? 0 > 0) && validated
//        case dateOfVaxTextField:
//            return (phnTextField.text?.count ?? 0 > 0) && (dobTextField.text?.count ?? 0 > 0) && validated
//        default: return false
//        }
//    }
//}

//// MARK: QR Vaccine Validation check
//extension GatewayFormViewController {
//    func checkForPHN(phnString: String) {
//        var vaccinePassportModel: VaccinePassportModel
//        let phn = phnString.trimWhiteSpacesAndNewLines
//        let name: String
//        let imageName: String
//
//        var status: VaccineStatus
//        if phn == "1111111111" {
//            status = .fully
//            name = "WILLIE BEAMEN"
//            imageName = "full"
//        } else if phn == "2222222222" {
//            status = .partially
//            name = "RON BERGUNDY"
//            imageName = "partial"
//        } else {
//            status = .notVaxed
//            name = "BRICK TAMLAND"
//            imageName = ""
//        }
//        vaccinePassportModel = VaccinePassportModel(imageName: imageName, phn: phn, name: name, status: status)
//        let vc = VaccinePassportVC.constructVaccinePassportVC(withModel: vaccinePassportModel, delegateOwner: self)
//        self.present(vc, animated: true, completion: nil)
//    }
//}

// MARK: For Button tap events
extension GatewayFormViewController: AppStyleButtonDelegate {
    func buttonTapped(type: AppStyleButton.ButtonType) {
        if type == .cancel {
            self.dismiss(animated: true, completion: nil)
        } else if type == .enter {
//            checkForPHN(phnString: self.phnTextField.text ?? "")
            // TODO: Check phn logic here
        }
    }
}

