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
        // TODO: If cell is form data, then open keyboard on text field, otherwise, check if cell is clickable for text cell
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
    }
    
    func textFieldTextDidChange(formField: FormTextFieldType, newText: String) {
        updateDataSource(formField: formField, text: newText)
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

// MARK: For Form Field Validation
extension GatewayFormViewController {
    // TODO: Regex form validation here - seeing as we don't have to check dates due to picker, we just need to check if field is empty or not (should throw in a check to make sure it's a valid date though, just in case someone copy and pastes. For PHN, we know it will be number due to keypad, just need to check if digit count is 10 (after trimming white space and new lines). We should throw in number regex check though just in case someone copy pastes
}


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
            // TODO: Check phn logic here, then would pop back to base card screen
        }
    }
}

