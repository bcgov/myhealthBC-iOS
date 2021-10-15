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
    
    @IBOutlet private weak var formTitleLabel: UILabel!
    @IBOutlet private weak var separatorView: UIView! // colour it yellow
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet weak var cancelButton: AppStyleButton!
    @IBOutlet weak var submitButton: AppStyleButton!
    
    // MARK: Queue It properties
    private var engine: QueueITEngine?
    // These aren't randomly generated, need to find out where to get this from then
    // FIXME: Find out what these are
    var customerID: String?
    var eventAlias: String?
    var queueitToken: String?
    var model: GatewayVaccineCardRequest?
    
    private var healthGateway: HealthGatewayBCGateway!
    var completionHandler: (() -> Void)?
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
        navSetup()
        // TODO: Delete this after testings
        submitButton.enabled = true
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private func setup() {
        setupUI()
        setupButtons()
        setupDataSource()
        setupTableView()
//        queueItSetup()
//        runQueueIt()
    }
    
    private func setupUI() {
        separatorView.backgroundColor = AppColours.barYellow
        formTitleLabel.font = UIFont.bcSansBoldWithSize(size: 18)
        formTitleLabel.textColor = AppColours.textBlack
        formTitleLabel.text = .formTitle
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

}

// MARK: Navigation setup
extension GatewayFormViewController {
    private func navSetup() {
        self.navDelegate?.setNavigationBarWith(title: .addCard,
                                               leftNavButton: nil,
                                               rightNavButton: nil,
                                               navStyle: .small,
                                               targetVC: self)
        applyNavAccessibility()
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

// MARK: FIXME: This is just temporary so that we can test UI with local data
// TODO: Strip out alert handling for what we will use in the response object
extension GatewayFormViewController {
//    func checkForPHN(phnString: String, birthday: String) {
//        var model: AppVaccinePassportModel
//        let phn = phnString.trimWhiteSpacesAndNewLines.removeWhiteSpaceFormatting
//        let name: String
//        let image: UIImage?
//
//        var status: VaccineStatus
//        if phn == "1111111111" {
//            status = .fully
//            name = "WILLIE BEAMEN"
//            image = UIImage(named: "full")
//        } else if phn == "2222222222" {
//            status = .partially
//            name = "RON BERGUNDY"
//            image = UIImage(named: "partial")
//        } else {
//            status = .notVaxed
//            name = "BRICK TAMLAND"
//            image = nil
//        }
//        guard let img = image else {
//            alert(title: "Error", message: "Invalid PHN number, no QR code associated with this number")
//            return
//        }
//        let code = img.toPngString() ?? ""
//        model = AppVaccinePassportModel(codableModel: LocallyStoredVaccinePassportModel(code: code, birthdate: birthday, name: name, issueDate: 1632413161, status: status))
//        // This obviously needs to be refactored, but not going to bother, being that we are going to be removing it and hitting an endpoint.
//        if doesCardNeedToBeUpdated(modelToUpdate: model) {
//            alert(title: "Success", message: "Congrats! You have successfully updated your vaxine QR code. Would you like to save this card to your list of cards?", buttonOneTitle: "No", buttonOneCompletion: { [weak self] in
//                guard let `self` = self else { return }
//                self.navigationController?.popViewController(animated: true)
//                // No Nothing, just dismiss
//            }, buttonTwoTitle: "Yes") { [weak self] in
//                guard let `self` = self else { return }
//                self.navigationController?.popViewController(animated: true)
//                self.updateCardInLocalStorage(model: model.transform())
//                self.postCardAddedNotification(id: model.id ?? "")
//                self.completionHandler?()
//
//            }
//        } else {
//            guard isCardAlreadyInWallet(modelToAdd: model) == false else {
//                alert(title: "Duplicate", message: "This card is already saved in your wallet.") { [weak self] in
//                    guard let `self` = self else {return}
//                    self.navigationController?.popViewController(animated: true)
//                    self.completionHandler?()
//
//                }
//                return
//            }
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                self.navigationController?.popViewController(animated: true)
//                self.appendModelToLocalStorage(model: model.transform())
//                self.postCardAddedNotification(id: model.id ?? "")
//                self.completionHandler?()
//
//            }
//
//
////            alert(title: "Success", message: "Congrats! You have successfully fetched your vaxine QR code. Would you like to save this card to your list of cards?", buttonOneTitle: "No", buttonOneCompletion: { [weak self] in
////                guard let `self` = self else { return }
////                self.dismiss(animated: true, completion: nil)
////                // No Nothing, just dismiss
////            }, buttonTwoTitle: "Yes") { [weak self] in
////                guard let `self` = self else { return }
////                self.dismiss(animated: true) {
////                    self.appendModelToLocalStorage(model: model.transform())
////                    self.postCardAddedNotification(id: model.id ?? "")
////                    self.completionHandler?()
////                }
////            }
//        }
//    }
    
    // TODO: Call this function in the checkForPHN above, remove local logic
//    private func createVaccineCardRequest(model: GatewayVaccineCardRequest) {
//        self.healthGateway.requestVaccineCard(model) { [weak self] result in
//            guard let `self` = self else {return}
//            switch result {
//            case .success(let vaccineCard):
//                // TODO: Handle logic with duplicates etc here
//                print(vaccineCard)
//            case .failure(let error):
//                print(error)
//                // TODO: Show error here
//            }
//        }
//    }
    
    private func createInitialVaccineCardRequest(model: GatewayVaccineCardRequest) {
        let interceptor = NetworkRequestInterceptor()
        let headerParameters: HTTPHeaders = [
            "phn": model.phn,
            "dateOfBirth": model.dateOfBirth,
            "dateOfVaccine": model.dateOfVaccine
        ]
        AF.request(URL(string: "https://test.healthgateway.gov.bc.ca/api/immunizationservice/v1/api/VaccineStatus")!, method: .get, headers: headerParameters, interceptor: interceptor).response { response in
            // Check for queue it cookie here, if it's there, set the cookie and make actual request
            if let cookie = response.response?.allHeaderFields["Set-Cookie"] as? String, cookie.contains("QueueITAccepted") {
                guard let model = self.model else { return }
                self.getActualVaccineCard(model: model, token: nil)
            } else if let redirectURLStringEndcoded = response.response?.allHeaderFields["x-queueit-redirect"] as? String,
                      let decodedURLString = redirectURLStringEndcoded.removingPercentEncoding,
                      let url = URL(string: decodedURLString),
                      let items = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems {
                self.customerID = items.first(where: { $0.name == "c" })?.value
                self.eventAlias = items.first(where: { $0.name == "e" })?.value
                self.queueItSetup()
                self.runQueueIt()
            }
        }
    }
    
//    private func createTokenVaccineCardRequest(model: GatewayVaccineCardRequest, token: String) {
//        let interceptor = NetworkRequestInterceptor()
////        var url = URL(string: "https://healthgateway.gov.bc.ca/api/immunizationservice/v1/api/VaccineStatus")!
//        let queryItems = [URLQueryItem(name: "queueittoken", value: token)]
//        var urlComps = URLComponents(string: "https://healthgateway.gov.bc.ca/api/immunizationservice/v1/api/VaccineStatus")
//        urlComps?.queryItems = queryItems
//        guard let url = urlComps?.url else { return }
//        let headerParameters: HTTPHeaders = [
//            "phn": model.phn,
//            "dateOfBirth": model.dateOfBirth,
//            "dateOfVaccine": model.dateOfVaccine
//        ]
//        AF.request(url, method: .get, headers: headerParameters, interceptor: interceptor).response { response in
//            // Check for queue it cookie here, if it's there, set the cookie and make actual request
//            print("CONNOR: Response: ", response)
//            if let header = response.response?.allHeaderFields as? [String: String], let url = response.request?.url {
//                let cookies = HTTPCookie.cookies(withResponseHeaderFields: header, for: url)
//                AF.session.configuration.httpCookieStorage?.setCookies(cookies, for: url, mainDocumentURL: nil)
//                // Normal request here
//            } else if let redirectURLStringEndcoded = response.response?.allHeaderFields["x-queueit-redirect"] as? String,
//                      let decodedURLString = redirectURLStringEndcoded.removingPercentEncoding,
//                      let url = URL(string: decodedURLString),
//                      let items = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems {
//                self.customerID = items.first(where: { $0.name == "c" })?.value
//                self.eventAlias = items.first(where: { $0.name == "e" })?.value
//                self.queueItSetup()
//                self.runQueueIt()
//            }
//        }
//    }
    
//    private func getActualVaccineCard(model: GatewayVaccineCardRequest, token: String, cookies: [HTTPCookie]) {
//
//    }
    
    private func getActualVaccineCard(model: GatewayVaccineCardRequest, token: String?) {
        self.healthGateway.requestVaccineCard(model, token: token) { [weak self ] result in
            guard let `self` = self else {return}
            switch result {
            case .success(let vaccineCard):
                // TODO: Handle logic with duplicates etc here
                print(vaccineCard)
            case .failure(let error):
                print(error)
                // TODO: Show error here
            }
        }
    }
}



// MARK: For Button tap events
extension GatewayFormViewController: AppStyleButtonDelegate {
    func buttonTapped(type: AppStyleButton.ButtonType) {
        if type == .cancel {
            self.navigationController?.popViewController(animated: true)
        } else if type == .submit {
            let staticModel = GatewayVaccineCardRequest(phn: "9000201422", dateOfBirth: "1989-12-12", dateOfVaccine: "2021-05-15")
            self.model = staticModel
            createInitialVaccineCardRequest(model: staticModel)
//            guard let phnIndex = getIndexInDataSource(formField: .personalHealthNumber, dataSource: self.dataSource) else { return }
//            guard let phn = dataSource[phnIndex].cellStringData else { return }
//            guard let dobIndex = getIndexInDataSource(formField: .dateOfBirth, dataSource: self.dataSource) else { return }
//            guard let birthday = dataSource[dobIndex].cellStringData else { return }
//            guard let dovIndex = getIndexInDataSource(formField: .dateOfVaccination, dataSource: self.dataSource) else { return }
//            guard let vaxDate = dataSource[dovIndex].cellStringData else { return }
//            guard let model = formatGatewatData(phn: phn, birthday: birthday, vax: vaxDate) else { return }
//            createInitialVaccineCardRequest(model: model)
        }
    }
}

// MARK: Data Formatting
extension GatewayFormViewController {
    private func formatGatewatData(phn: String, birthday: String, vax: String) -> GatewayVaccineCardRequest? {
        let formattedPHN = phn.removeWhiteSpaceFormatting
        guard let bdayDate = Date.Formatter.monthDayYearDate.date(from: birthday) else { return nil }
        let formattedBirthday = Date.Formatter.yearMonthDay.string(from: bdayDate)
        guard let vaxDate = Date.Formatter.monthDayYearDate.date(from: vax) else { return nil }
        let formattedVaxDate = Date.Formatter.yearMonthDay.string(from: vaxDate)
        return GatewayVaccineCardRequest(phn: formattedPHN, dateOfBirth: formattedBirthday, dateOfVaccine: formattedVaxDate)
    }
}

// MARK: Accessibility
extension GatewayFormViewController {
    private func applyNavAccessibility() {
        if let nav = self.navigationController as? CustomNavigationController {
            if let rightNavButton = nav.getRightBarButtonItem() {
                rightNavButton.accessibilityTraits = .button
                rightNavButton.accessibilityLabel = "Close"
                rightNavButton.accessibilityHint = "Tapping this button will close this screen and return you to the my cards wallet screen"
            }
            if let leftNavButton = nav.getLeftBarButtonItem() {
                // TODO: Need to investigate here - not a priority right now though, as designs will likely change
            }
        }
    }
}


// MARK: QueueIt testing
extension GatewayFormViewController: QueuePassedDelegate, QueueViewWillOpenDelegate, QueueDisabledDelegate, QueueITUnavailableDelegate, QueueUserExitedDelegate, QueueViewClosedDelegate {
    
    // This callback will be triggered when the user has been through the queue.
    // Here you should store session information, so user will only be sent to queue again if the session has timed out.
    private func queueItSetup() {
        guard let customerID = self.customerID, let eventAlias = self.eventAlias else { return }
        self.engine = QueueITEngine.init(host: self, customerId: customerID, eventOrAliasId: eventAlias, layoutName: nil, language: nil)
        self.engine?.queuePassedDelegate = self // Invoked once the user is passed the queue
        self.engine?.queueViewWillOpenDelegate = self // Invoked to notify that Queue-It UIWebView or WKWebview will open
        self.engine?.queueDisabledDelegate = self // Invoked to notify that queue is disabled
        self.engine?.queueITUnavailableDelegate = self // Invoked in case QueueIT is unavailable (500 errors)
        self.engine?.queueUserExitedDelegate = self // Invoked when user chooses to leave the queue
    }
    
    private func runQueueIt() {
        do {
            try engine?.run()
        }
        catch let err {
            // TODO: Handle reasons for not being able to start queue it here
            print("CONNOR FAILED TO RUN: ", err)
            print("CONNOR ERROR CODE: ", (err as NSError).code)
        }
    }
    
    // This callback will be triggered just before the webview (hosting the queue page) will be shown.
    // Here you can change some relevant UI elements.
    func notifyYourTurn(_ queuePassedInfo: QueuePassedInfo!) {
        print("CONNOR QUEUE IT: ", queuePassedInfo)
        self.queueitToken = queuePassedInfo?.queueitToken
        guard let model = self.model, let token = self.queueitToken else { return }
//        createTokenVaccineCardRequest(model: model, token: token)
        getActualVaccineCard(model: model, token: token)
    }
    
    // This callback will be triggered when the queue used (event alias ID) is in the 'disabled' state.
    // Most likely the application should still function, but the queue's 'disabled' state can be changed at any time,
    // so session handling is important.
    func notifyQueueViewWillOpen() {
        print("CONNOR QUEUE IT: notifyQueueViewWillOpen")
    }
    
    // This callback will be triggered when the mobile application can't reach Queue-it's servers.
    // Most likely because the mobile device has no internet connection.
    // Here you decide if the application should function or not now that is has no queue-it protection.
    func notifyQueueDisabled() {
        print("CONNOR QUEUE IT: notifyQueueDisabled")
    }
    
    // This callback will be triggered after a user clicks a close link in the layout and the WebView closes.
    // The close link is "queueit://close". Whenever the user navigates to this link, the SDK intercepts the navigation
    // and closes the webview.
    func notifyQueueITUnavailable(_ errorMessage: String!) {
        print("CONNOR QUEUE IT: errorMessage: ", errorMessage)
    }
    
    func notifyUserExited() {
        print("CONNOR QUEUE IT: notifyUserExited")
    }
    
    func notifyViewClosed() {
        print("CONNOR QUEUE IT: notifyViewClosed")
    }
    
}

