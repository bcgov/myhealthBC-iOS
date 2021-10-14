//
//  QRRetrievalMethodViewController.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-09-16.
//

import UIKit
import BCVaccineValidator
import SwiftUI

class QRRetrievalMethodViewController: BaseViewController {
    
    class func constructQRRetrievalMethodViewController() -> QRRetrievalMethodViewController {
        if let vc = Storyboard.healthPass.instantiateViewController(withIdentifier: String(describing: QRRetrievalMethodViewController.self)) as? QRRetrievalMethodViewController {
            return vc
        }
        return QRRetrievalMethodViewController()
    }
    
    enum CellType {
        case text(text: String), image(image: UIImage), method(type: QRRetrievalMethod)
    }
    
    @IBOutlet weak private var tableView: UITableView!
    private var dataSource: [CellType] = []
    
    private var ImagePickerCallback: ((_ image: UIImage?)->(Void))? = nil
    private weak var imagePicker: UIImagePickerController? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
        navSetup()
        self.tableView.contentInsetAdjustmentBehavior = .never
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
        self.navDelegate?.setNavigationBarWith(title: .addCard,
                                               leftNavButton: nil,
                                               rightNavButton: nil,
                                               navStyle: .small,
                                               targetVC: self)
        applyNavAccessibility()
    }
}

// MARK: Data Source Setup
extension QRRetrievalMethodViewController {
    private func setupDataSource() {
        self.dataSource = [
            .text(text: .qrDescriptionText),
            .image(image: #imageLiteral(resourceName: "options-screen-image")),
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
        tableView.register(UINib.init(nibName: ImageTableViewCell.getName, bundle: .main), forCellReuseIdentifier: ImageTableViewCell.getName)
        tableView.register(UINib.init(nibName: QRSelectionTableViewCell.getName, bundle: .main), forCellReuseIdentifier: QRSelectionTableViewCell.getName)
//        tableView.rowHeight = UITableView.automaticDimension
//        tableView.estimatedRowHeight = 100
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
                cell.configure(forType: .plainText, text: text, withFont: UIFont.bcSansBoldWithSize(size: 17), labelSpacingAdjustment: 0)
                return cell
            }
        case .image(image: let image):
            if let cell = tableView.dequeueReusableCell(withIdentifier: ImageTableViewCell.getName, for: indexPath) as? ImageTableViewCell {
                cell.configure(image: image)
                return cell
            }
        case .method(type: let type):
            if let cell = tableView.dequeueReusableCell(withIdentifier: QRSelectionTableViewCell.getName, for: indexPath) as? QRSelectionTableViewCell {
                cell.configure(method: type, delegateOwner: self)
                cell.isAccessibilityElement = true
                cell.accessibilityTraits = .button
                cell.accessibilityLabel = "\(type.getTitle)"
                cell.accessibilityHint = "\(type.accessibilityHint)"
                return cell
            }
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let data = dataSource[indexPath.row]
        switch data {
        case .text: return Constants.UI.CellSpacing.QROptionsScreen.staticText
        case .image:
            let buffer: CGFloat = 20
            let occupied = Constants.UI.CellSpacing.QROptionsScreen.staticText + (3 * Constants.UI.CellSpacing.QROptionsScreen.optionButtonHeight) + buffer
            return tableView.bounds.height - occupied
        case .method: return Constants.UI.CellSpacing.QROptionsScreen.optionButtonHeight
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = dataSource[indexPath.row]
        switch item {
        case .text, .image: return
        case .method(type: let type):
            if let cell = tableView.cellForRow(at: indexPath) as? QRSelectionTableViewCell {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                // The delay is necessary for the haptic feedback to occur immediately.
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    cell.callDelegate(fromMethod: type)
                }
            }
        }
    }
}

extension QRRetrievalMethodViewController: GoToQRRetrievalMethodDelegate {
    func goToEnterGateway() {
        let vc = GatewayFormViewController.constructGatewayFormViewController()
        vc.completionHandler = { [weak self] id in
            guard let `self` = self else { return }
            self.popBackToProperViewController(id: id)
        }
        self.navigationController?.pushViewController(vc, animated: true)
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
        if doesCardNeedToBeUpdated(modelToUpdate: appModel) {
            updateCardInLocalStorage(model: model)
//            postCardAddedNotification(id: appModel.id ?? "")
        } else {
            guard isCardAlreadyInWallet(modelToAdd: appModel) == false else {
                alert(title: "Duplicate", message: "This QR code is already saved in your list of passes.") { [weak self] in
                    guard let `self` = self else {return}
                    self.navigationController?.popViewController(animated: true)
                }
                return
            }
            appendModelToLocalStorage(model: model)
//            postCardAddedNotification(id: appModel.id ?? "")
        }
        // TODO: text from constants
        self.navigationController?.showBanner(message: "Your proof of vaccination has been added", style: .Top)
        self.popBackToProperViewController(id: appModel.id ?? "")
    }
}

// MARK: Logic for handling what screen to go back to
extension QRRetrievalMethodViewController {
    func popBackToProperViewController(id: String) {
        // If we only have one card (or no cards), then go back to health pass with popBackTo
        // If we have more than one card, we should check if 2nd controller in stack is CovidVaccineCardsViewController, if so, pop back, if not, instantiate, insert at 1, then pop back
        guard let cards = Defaults.vaccinePassports, cards.count > 1 else {
            self.popBack(toControllerType: HealthPassViewController.self)
            return
        }
        // check for controller in stack
        guard let viewControllerStack = self.navigationController?.viewControllers else { return }
        var containsCovidVaxCardsVC = false
        for (index, vc) in viewControllerStack.enumerated() {
            if vc is CovidVaccineCardsViewController {
                containsCovidVaxCardsVC = true
            }
        }
        guard containsCovidVaxCardsVC == false else {
            postCardAddedNotification(id: id)
            self.navigationController?.popViewController(animated: true)
            return
        }
        guard viewControllerStack.count > 0 else { return }
        guard viewControllerStack[0] is HealthPassViewController else { return }
        let vc = CovidVaccineCardsViewController.constructCovidVaccineCardsViewController()
        self.navigationController?.viewControllers.insert(vc, at: 1)
        // Note for Amir - This is because calling post notification wont work as the view did load hasn't been called yet where we add the notification observer, and we do this here, as there is logic in that view controller that refers to outlets, so it has to load first, otherwise we'll get a crash with outlets not being set yet.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.postCardAddedNotification(id: id)
        }
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
            tabBarVC.view.startLoadingIndicator()
            tabBarVC.present(picker, animated: true, completion: {
                tabBarVC.view.endLoadingIndicator()
            })
        } else {
            view.startLoadingIndicator()
            self.present(picker, animated: true, completion: { [weak self] in
                guard let `self` = self else {return}
                self.view.endLoadingIndicator()
            })
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

// MARK: Accessibility
extension QRRetrievalMethodViewController {
    private func applyNavAccessibility() {
        if let nav = self.navigationController as? CustomNavigationController {
            if let rightNavButton = nav.getRightBarButtonItem() {
                rightNavButton.accessibilityTraits = .button
                rightNavButton.accessibilityLabel = "Close"
                rightNavButton.accessibilityHint = "Tapping this button will close this screen and return you to the my cards screen"
            }
            if let leftNavButton = nav.getLeftBarButtonItem() {
                // TODO: Need to investigate here - not a priority right now though, as designs will likely change
            }
        }
    }
}
