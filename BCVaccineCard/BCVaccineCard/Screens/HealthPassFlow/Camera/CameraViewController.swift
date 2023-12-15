//
//  CameraViewController.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2021-09-22.
//

import UIKit
import BCVaccineValidator

class CameraViewController: UIViewController {

    @IBOutlet weak var accessibilityViewForNotifyingUser: UIView! //NOTE: This is just a clear view needed due to view heirarchy to let the user know the camera has been opened, before the closeButton is selected. Using other views (navBarView, etc...) didn't work due to view heirarchy (close button was then ignored)
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var divider: UIView!
    @IBOutlet weak var navBarView: UIView!
    @IBOutlet weak var cameraContainer: UIView!
    private var completionHandler: ((ScanResultModel?)->Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        applyNavAccessibility()
        style()
        showScanner { [weak self] result in
            guard let `self` = self else {return}
            self.close(result: result)
        }
    }
    
    @IBAction func closeButtonAction(_ sender: Any) {
        close(result: nil)
    }
    
    public func setup(result: @escaping(ScanResultModel?)->Void) {
        self.completionHandler = result
    }
    
    func close(result: ScanResultModel?) {
        self.dismiss(animated: true, completion: nil)
        if let completion = self.completionHandler {
            completion(result)
        }
    }
    
    private func showScanner(result: @escaping(ScanResultModel?)->Void) {
        let scanView: QRScannerView = QRScannerView()
        scanView.present(on: self, container: self.cameraContainer, completion: result)
    }
    
    private func style() {
        navBarView.backgroundColor = Constants.UI.Theme.primaryColor
        divider.backgroundColor = Constants.UI.Theme.secondaryColor
        closeButton.tintColor = Constants.UI.Theme.primaryConstrastColor
        closeButton.setTitle("", for: .normal)
    }

}

// MARK: Accessibility
extension CameraViewController {
    private func applyNavAccessibility() {
//        if let nav = self.navigationController as? CustomNavigationController, let rightNavButton = nav.getRightBarButton() {
//            rightNavButton.accessibilityTraits = .button
//            rightNavButton.accessibilityLabel = "Add Card"
//            rightNavButton.accessibilityHint = "Tapping this button will bring you to a new screen with different options to retrieve your QR code"
//        }
        self.accessibilityViewForNotifyingUser.isAccessibilityElement = true
        self.accessibilityViewForNotifyingUser.accessibilityLabel = AccessibilityLabels.Camera.notifyUserCameraOpened
        self.closeButton.isAccessibilityElement = true
        self.closeButton.accessibilityTraits = .button
        self.closeButton.accessibilityLabel = AccessibilityLabels.Camera.closeText
        self.closeButton.accessibilityHint = AccessibilityLabels.Camera.closeHint
    }

}

// MARK: For iPad
extension CameraViewController {
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        guard Constants.deviceType == .iPad else { return }
        NotificationCenter.default.post(name: .deviceDidRotate, object: nil)
        // TODO: Make iPad adjustments here if necessary
    }
}
