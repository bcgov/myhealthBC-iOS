//
//  QRScannerView.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2021-09-20.
//

import Foundation
import AVFoundation
import UIKit
import BCVaccineValidator

class QRScannerView: UIView {
    // MARK: Constants
    private let flashOnIcon = UIImage(named: "flashOn")
    private let flashOffIcon = UIImage(named: "flashOff")
   
    // MARK: Variables
    private var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    fileprivate var codeHighlightTags: [Int] = []
    fileprivate var invalidScannedCodes: [String] = []
    private var completionHandler: ((ScanResultModel?)->Void)?
    private weak var parentViewController: UIViewController?
    
    private var windowInterfaceOrientation: UIInterfaceOrientation? {
        if #available(iOS 13.0, *) {
            return UIApplication.shared.windows.first?.windowScene?.interfaceOrientation
        } else {
            return UIApplication.shared.statusBarOrientation
        }
    }
    
    // MARK: Initialization
    public func present(on parentViewController: UIViewController, completion: @escaping(_ result: ScanResultModel?) -> Void) {
        self.completionHandler = completion
        self.parentViewController = parentViewController
        present(on: parentViewController) { [weak self] in
            guard let `self` = self else {return}
            self.setup()
        }
        
    }
    
    private func setup() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        if status == .notDetermined {
            askForCameraPermission {[weak self] allowed in
                guard let `self` = self else { return }
                if allowed {
                    self.showCamera()
                    return
                }
                self.alertCameraAccessIsNecessary()
            }
        } else if status == .denied {
            self.alertCameraAccessIsNecessary()
        } else {
            showCamera()
        }
    }
    
    // MARK: Presentation
    private func present(on parentViewController: UIViewController, then: @escaping() -> Void) {
        self.frame = parentViewController.view.bounds
        parentViewController.view.addSubview(self)
        then()
    }
    
    // MARK: Camera Permissions
    func isCameraUsageAuthorized()-> Bool {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined, .denied:
            return false
        case .restricted,.authorized:
            return true
        @unknown default:
            return false
        }
    }
    
    func askForCameraPermission(completion: @escaping(Bool)-> Void) {
        AVCaptureDevice.requestAccess(for: .video, completionHandler: {(granted: Bool) in
            DispatchQueue.main.async {
                return completion(granted)
            }
        })
    }
    
    func showCameraPermissionsSettings() {
        self.removeFromSuperview()
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url, options: [:], completionHandler: { _ in
            })
        }
    }
    
    func alertCameraAccessIsNecessary() {
        self.parentViewController?.alert(title: Constants.Strings.Errors.CameraAccessIsNecessary.title, message: Constants.Strings.Errors.CameraAccessIsNecessary.message, completion: { [weak self] in
            guard let `self` = self else {return}
            self.showCameraPermissionsSettings()
        })
    }
    
    // MARK: Result/Return
    func found(card: ScanResultModel) {
        guard let completion = self.completionHandler else {return}
        completion(card)
    }
}
// MARK: Camera
extension QRScannerView: AVCaptureMetadataOutputObjectsDelegate {
    
    private func showCamera() {
        DispatchQueue.main.async {
            self.setupCaptureSession()
            self.addFlashlightButton()
        }
    }
    
    private func removeCameraPreview() {
        if let existingPreview = self.previewLayer {
            existingPreview.removeFromSuperlayer()
            self.previewLayer = nil
        }
        
        if let existingSession = self.captureSession {
            existingSession.stopRunning()
            captureSession = nil
        }
        
        if let existingFlashButton = self.viewWithTag(Constants.UI.TorchButton.tag) {
            existingFlashButton.removeFromSuperview()
        }
    }
    
    private func setupCaptureSession() {
        removeCameraPreview()
        
        let captureSession = AVCaptureSession()
        self.captureSession = captureSession
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        
        // Setup Video input
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        
        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            self.parentViewController?.alert(title: Constants.Strings.Errors.VideoNotSupported.title,
                       message: Constants.Strings.Errors.VideoNotSupported.message)
            return
        }
        
        // Setup medatada delegate to capture QR codes
        let metadataOutput = AVCaptureMetadataOutput()
        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            self.parentViewController?.alert(title: Constants.Strings.Errors.QRScanningNotSupported.title,
                       message: Constants.Strings.Errors.QRScanningNotSupported.message)
            return
        }
        
        // Setup Preview
        let preview = AVCaptureVideoPreviewLayer(session: captureSession)
        preview.frame = self.layer.bounds
        preview.videoGravity = .resizeAspectFill
        preview.isAccessibilityElement = true
        
        self.layer.addSublayer(preview)
        self.previewLayer = preview
        
        // Begin Capture Session
        captureSession.startRunning()
        
        // Set orientation
        guard let connection = preview.connection, connection.isVideoOrientationSupported, let orientation = windowInterfaceOrientation else {
            return
        }
        
        switch orientation {
        case .unknown:
            connection.videoOrientation = .portrait
        case .portrait:
            connection.videoOrientation = .portrait
        case .portraitUpsideDown:
            connection.videoOrientation = .portraitUpsideDown
        case .landscapeLeft:
            connection.videoOrientation = .landscapeLeft
        case .landscapeRight:
            connection.videoOrientation = .landscapeRight
        @unknown default:
            connection.videoOrientation = .portrait
        }
    }
    
    
    /// Medatada Delegate function - called when a QR is found
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // Remove boxes for previous qr codes
        clearQRCodeLocations()
        // if there are multiple codes in camera view
        if metadataObjects.count > 1 {
            showMultipleQRCodesWarning(metadataObjects: metadataObjects)
            return
        }
        
        // get data from single code in view
        guard let metadataObject = metadataObjects.first,
              let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
              let stringValue = readableObject.stringValue
        else {
            return
        }
        
        // if code has been invalidated already in this session, avoid blocking the camera
        if !invalidScannedCodes.contains(stringValue) {
            // Pause camera
            pauseCamera()
            // Show code location
            showQRCodeLocation(for: metadataObject, isInValid: false, tag: Constants.UI.QRCodeHighlighter.tag)
            // Validate QR code
            validate(code: stringValue)
        } else {
            // Show message
            self.parentViewController?.showBanner(message: Constants.Strings.Errors.InvalidCode.message)
            // Show code location
            showQRCodeLocation(for: metadataObject, isInValid: false, tag: Constants.UI.QRCodeHighlighter.tag)
        }
    }
    
    fileprivate func validate(code: String) {
        self.parentViewController?.hideBanner()
        self.startLoadingIndicator()
        // Validate
//        BCVaccineValidator.shared.validate(code: <#T##String#>, completion: <#T##(CodeValidationResult) -> Void#>)
        BCVaccineValidator.shared.validate(code: code) { [weak self] result in
            guard let `self` = self else {return}
            // Validation is done on background thread. This moves us back to main thread
            DispatchQueue.main.async {
                self.endLoadingIndicator()
                guard let data = result.result, result.status == .ValidCode else {
                    UINotificationFeedbackGenerator().notificationOccurred(.warning)
                    // show an error & start camera
                    switch result.status {
                    case .ValidCode:
                        break
                    case .InvalidCode:
                        self.parentViewController?.showBanner(message: Constants.Strings.Errors.InvalidCode.message)
                    case .ForgedCode:
                        self.parentViewController?.showBanner(message: Constants.Strings.Errors.InvalidCode.message)
                    case .MissingData:
                        self.parentViewController?.showBanner(message: Constants.Strings.Errors.InvalidCode.message)
                    }
                    self.startCamera()
                    self.invalidScannedCodes.append(code)
                    return
                }
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                self.found(card: data)
            }
        }
    }
    
    public func startCamera() {
        clearQRCodeLocations()
        captureSession?.startRunning()
    }
    
    public func pauseCamera() {
        setFlash(on: false)
        captureSession?.stopRunning()
    }
    
    fileprivate func showMultipleQRCodesWarning(metadataObjects: [AVMetadataObject]) {
        for (index, item) in metadataObjects.enumerated() {
            showQRCodeLocation(for: item, isInValid: true, tag: 1000 + index)
        }
        self.parentViewController?.showBanner(message: Constants.Strings.Errors.MultipleQRCodes.message)
    }
    
    fileprivate func showQRCodeLocation(for object: AVMetadataObject, isInValid: Bool, tag: Int) {
        guard let preview =  previewLayer, let metadataLocation = preview.transformedMetadataObject(for: object) else {
            return
        }
        if let existing = self.viewWithTag(tag) {
            existing.removeFromSuperview()
        }
        let container = UIView(frame: metadataLocation.bounds)
        container.tag = tag
        container.layer.borderWidth =  Constants.UI.QRCodeHighlighter.borderWidth
        container.layer.borderColor = isInValid ? Constants.UI.QRCodeHighlighter.borderColorInvalid : Constants.UI.QRCodeHighlighter.borderColor
        container.layer.cornerRadius =  Constants.UI.QRCodeHighlighter.cornerRadius
        container.backgroundColor = .clear
        
        codeHighlightTags.append(tag)
        self.addSubview(container)
        
        // If its a known invalid QR code, make show invalid colour
        guard let readableObject = object as? AVMetadataMachineReadableCodeObject,
              let stringValue = readableObject.stringValue,
              invalidScannedCodes.contains(stringValue)
        else {
            return
        }
        container.layer.borderColor = Constants.UI.QRCodeHighlighter.borderColorInvalid
    }
    
    fileprivate func clearQRCodeLocations() {
        for tag in codeHighlightTags {
            if let box = self.viewWithTag(tag) {
                box.removeFromSuperview()
            }
        }
    }
    
    func setFlash(on: Bool) {
        guard
            let device = AVCaptureDevice.default(for: AVMediaType.video),
            device.hasTorch
        else { return }
        
        do {
            try device.lockForConfiguration()
            device.torchMode = on ? .on : .off
            device.unlockForConfiguration()
        } catch {
            print("Flash could not be used")
        }
        
        guard let btn = self.viewWithTag(Constants.UI.TorchButton.tag) as? UIButton else {
            return
        }
        if on {
            btn.setImage(flashOnIcon, for: .normal)
//            btn.accessibilityLabel = AccessibilityLabels.scannerView.turnOffFlash
        } else {
            btn.setImage(flashOffIcon, for: .normal)
//            btn.accessibilityLabel = AccessibilityLabels.scannerView.turnOnFlash
        }
    }
    
    fileprivate func addFlashlightButton() {
        if let existing = self.viewWithTag(Constants.UI.TorchButton.tag) {
            existing.removeFromSuperview()
        }
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        if !device.hasTorch && !device.hasFlash { return }
        
        let btnSize: CGFloat = Constants.UI.TorchButton.buttonSize
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: btnSize, height: btnSize))
        
        button.tag = Constants.UI.TorchButton.tag
        self.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: btnSize).isActive = true
        button.widthAnchor.constraint(equalToConstant: btnSize).isActive = true
        button.topAnchor.constraint(equalTo: self.topAnchor, constant: 32).isActive = true
        button.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16).isActive = true
        button.backgroundColor = .lightGray
        button.setImage(flashOffIcon, for: .normal)
//        button.accessibilityLabel = AccessibilityLabels.scannerView.turnOnFlash
        
        button.addTarget(self, action: #selector(flashTapped), for: .touchUpInside)
        button.layer.cornerRadius = btnSize/2
        
        button.imageView?.contentMode = .scaleAspectFit
    }
    
    @objc func flashTapped(sender: UIButton?) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        guard let btn = self.viewWithTag(Constants.UI.TorchButton.tag) as? UIButton else {
            return
        }
        let isOn = btn.imageView?.image == flashOnIcon
        setFlash(on: !isOn)
    }
    
    
}

