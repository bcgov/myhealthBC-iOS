//
//  QRRetrievalMethodViewController.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-09-16.
//

import UIKit
import BCVaccineValidator

class QRRetrievalMethodViewController: BaseViewController {
    
    class func constructQRRetrievalMethodViewController() -> QRRetrievalMethodViewController {
        if let vc = Storyboard.main.instantiateViewController(withIdentifier: String(describing: QRRetrievalMethodViewController.self)) as? QRRetrievalMethodViewController {
            return vc
        }
        return QRRetrievalMethodViewController()
    }
    
    enum CellType {
        case text(text: String), method(type: QRRetrievalMethod)
    }
    
    @IBOutlet weak private var tableView: UITableView!
    private var dataSource: [CellType] = []
    
    private var ImagePickerCallback: ((_ image: UIImage?)->(Void))? = nil
    private weak var imagePicker: UIImagePickerController? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup() {
        navSetup()
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
                self.storeValidatedQRCode(data: data)
            }
        }
    }
}

// MARK: Navigation setup
extension QRRetrievalMethodViewController {
    private func navSetup() {
        self.navDelegate?.setNavigationBarWith(title: Constants.Strings.MyCardFlow.navHeader, andImage: UIImage(named: "close-icon"), action: #selector(self.closeButtonAction))
    }
    
    @objc private func closeButtonAction() {
        dismissMethodSelectionScreen()
    }
    
    private func dismissMethodSelectionScreen() {
        self.navigationController?.popViewController(animated: true)
    }
}

// MARK: Data Source Setup
extension QRRetrievalMethodViewController {
    private func setupDataSource() {
        self.dataSource = [
            .text(text: Constants.Strings.MyCardFlow.QRMethodSelection.description),
            .method(type: .scanWithCamera),
            .method(type: .uploadImage),
            .method(type: .enterGatewayInfo)
        ]
    }
}

// MARK: Table View Logic
extension QRRetrievalMethodViewController: UITableViewDelegate, UITableViewDataSource {
    private func setupTableView() {
        tableView.register(UINib.init(nibName: TextTableViewCell.getName, bundle: .main), forCellReuseIdentifier: TextTableViewCell.getName)
        tableView.register(UINib.init(nibName: QRSelectionTableViewCell.getName, bundle: .main), forCellReuseIdentifier: QRSelectionTableViewCell.getName)
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
        switch data {
        case .text(text: let text):
            if let cell = tableView.dequeueReusableCell(withIdentifier: TextTableViewCell.getName, for: indexPath) as? TextTableViewCell {
                cell.configure(forType: .plainText, text: text, withFont: UIFont.bcSansRegularWithSize(size: 16))
                return cell
            }
        case .method(type: let type):
            if let cell = tableView.dequeueReusableCell(withIdentifier: QRSelectionTableViewCell.getName, for: indexPath) as? QRSelectionTableViewCell {
                cell.configure(method: type, delegateOwner: self)
                return cell
            }
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = dataSource[indexPath.row]
        switch item {
        case .text: return
        case .method(type: let type):
            if let cell = tableView.cellForRow(at: indexPath) as? QRSelectionTableViewCell {
                cell.callDelegate(fromMethod: type)
            }
        }
    }
}

extension QRRetrievalMethodViewController: GoToQRRetrievalMethodDelegate {
    func goToEnterGateway() {
        let vc = GatewayFormViewController.constructGatewayFormViewController()
        vc.completionHandler = { [weak self] in
            guard let `self` = self else { return }
            self.navigationController?.popViewController(animated: true)
        }
        self.present(vc, animated: true, completion: nil)
    }
    
    func goToCameraScan() {
        performSegue(withIdentifier: "showCamera", sender: self)
    }
    
    func goToUploadImage() {
        showImagePicker { [weak self] image in
            guard let `self` = self, let image = image else {return}
            guard let codes = image.findQRCodes(), !codes.isEmpty else {
                self.alert(title: "No QR found", message: "") // TODO: Better text / from constants
                return
            }
            guard codes.count == 1, let code = codes.first else {
                self.alert(title: "Multiple QR codes", message: "image must have only 1 code") // TODO: Better text / from constants
                return
            }
            
            BCVaccineValidator.shared.validate(code: code) { [weak self] result in
                guard let `self` = self else { return }
                guard let data = result.result else {
                    self.alert(title: "Invalid QR Code", message: "") // TODO: Better text / from constants
                    return
                }
                DispatchQueue.main.async { [weak self] in
                    guard let `self` = self else {return}
                    self.storeValidatedQRCode(data: data)
                }
               
            }
        }
    }
    
    private func storeValidatedQRCode(data: ScanResultModel) {
        let model = convertScanResultModelIntoLocalData(data: data)
        let appModel = model.transform()
        guard isCardAlreadyInWallet(modelToAdd: appModel) == false else {
            alert(title: "Duplicate", message: "This QR code is already saved in your wallet.") { [weak self] in
                guard let `self` = self else {return}
                self.navigationController?.popViewController(animated: true)
            }
            return
        }
        appendModelToLocalStorage(model: model)
        // TODO: text from constants
        self.navigationController?.showBanner(message: "Your proof of vaccination has been added", style: .Top)
        self.navigationController?.popViewController(animated: true)
    }
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
            tabBarVC.present(picker, animated: true, completion: nil)
        } else {
            self.present(picker, animated: true, completion: nil)
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
