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
    static let viewTag = 414125
   
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
    public func present(on parentViewController: UIViewController, container: UIView, completion: @escaping(_ result: ScanResultModel?) -> Void) {
        self.completionHandler = completion
        self.parentViewController = parentViewController
        present(in: container) { [weak self] in
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
                guard let callback = self.completionHandler else {
                    self.alertCameraAccessIsNecessary()
                    return
                }
                callback(nil)
            }
        } else if status == .denied {
            self.alertCameraAccessIsNecessary()
        } else {
            showCamera()
        }
    }
    
    // MARK: Presentation
    private func present(in container: UIView, then: @escaping() -> Void) {
        self.frame = container.bounds
        self.tag = QRScannerView.viewTag
        container.addSubview(self)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.heightAnchor.constraint(equalTo: container.heightAnchor, constant: 0).isActive = true
        self.widthAnchor.constraint(equalTo: container.widthAnchor, constant: 0).isActive = true
        self.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 0).isActive = true
        self.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: 0).isActive = true
        self.centerXAnchor.constraint(equalTo: container.centerXAnchor, constant: 0).isActive = true
        self.centerYAnchor.constraint(equalTo: container.centerYAnchor, constant: 0).isActive = true
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
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    func alertCameraAccessIsNecessary() {
        self.parentViewController?.alert(title: .noCameraAccessTitle, message: .noCameraAccessMessage, completion: { [weak self] in
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
            self.parentViewController?.alert(title: .unsupportedDeviceTitle,
                                             message: .unsupportedDeviceVideoMessage)
            return
        }
        
        // Setup medatada delegate to capture QR codes
        let metadataOutput = AVCaptureMetadataOutput()
        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            self.parentViewController?.alert(title: .unsupportedDeviceTitle,
                                             message: .unsupportedDeviceQRMessage)
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
        
        addCameraCutout()
        
        // Set orientation
        guard let connection = preview.connection,
              connection.isVideoOrientationSupported,
              let orientation = windowInterfaceOrientation
        else {
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
            showQRCodeLocation(for: metadataObject, isInValid: false, tag: Constants.UI.CameraView.QRCodeHighlighter.tag)
            // Validate QR code
            validate(code: stringValue)
        } else {
            // Show message
            AppDelegate.sharedInstance?.showToast(message: .invalidQRCodeMessage, style: .Warn)
            // Show code location
            showQRCodeLocation(for: metadataObject, isInValid: false, tag: Constants.UI.CameraView.QRCodeHighlighter.tag)
        }
    }
    
    fileprivate func validate(code: String) {
        self.startLoadingIndicator()
        // Validate
        BCVaccineValidator.shared.validate(code: code.lowercased()) { [weak self] result in
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
                    case .InvalidCode, .ForgedCode, .MissingData:
                        AppDelegate.sharedInstance?.showToast(message: .invalidQRCodeMessage, style: .Warn)
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
        captureSession?.stopRunning()
    }
    
    fileprivate func showMultipleQRCodesWarning(metadataObjects: [AVMetadataObject]) {
        for (index, item) in metadataObjects.enumerated() {
            showQRCodeLocation(for: item, isInValid: true, tag: 1000 + index)
        }
        AppDelegate.sharedInstance?.showToast(message: .multipleQRCodesMessage, style: .Warn)
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
        container.layer.borderWidth =  Constants.UI.CameraView.QRCodeHighlighter.borderWidth
        container.layer.borderColor = isInValid ? Constants.UI.CameraView.QRCodeHighlighter.borderColorInvalid : Constants.UI.CameraView.QRCodeHighlighter.borderColor
        container.layer.cornerRadius =  Constants.UI.CameraView.QRCodeHighlighter.cornerRadius
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
        container.layer.borderColor = Constants.UI.CameraView.QRCodeHighlighter.borderColorInvalid
    }
    
    fileprivate func clearQRCodeLocations() {
        for tag in codeHighlightTags {
            if let box = self.viewWithTag(tag) {
                box.removeFromSuperview()
            }
        }
    }
    
    fileprivate func addCameraCutout() {
        // Constants
        let fillLayerName = Constants.UI.CameraView.CameraCutout.fillLayerName
        let bornerLayerName = Constants.UI.CameraView.CameraCutout.bornerLayerName
        
        let width: CGFloat = Constants.UI.CameraView.CameraCutout.width
        let height: CGFloat = Constants.UI.CameraView.CameraCutout.height
        let colour = Constants.UI.CameraView.CameraCutout.colour
        let opacity: Float = Constants.UI.CameraView.CameraCutout.opacity
        let cornerRadius: CGFloat = Constants.UI.CameraView.CameraCutout.cornerRadius
        
        self.removeCameraCutout()
        
        // positioning
        let horizontalDistance = (self.bounds.size.height - height) / 2
        let verticalDistance = (self.bounds.size.width - width) / 2
        
        // Outer
        let path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height), cornerRadius: 0)
        // middle cutout
        let middlePart = UIBezierPath(roundedRect: CGRect(x: verticalDistance, y: horizontalDistance, width: width, height: height), cornerRadius: cornerRadius)
        path.append(middlePart)
        path.usesEvenOddFillRule = true
        let fillLayer = CAShapeLayer()
        fillLayer.path = path.cgPath
        fillLayer.fillRule = .evenOdd
        fillLayer.fillColor = colour
        fillLayer.opacity = opacity
        
        fillLayer.name = fillLayerName
        self.layer.addSublayer(fillLayer)
        
        // Add border
        let borderLayer = CAShapeLayer()
        let borderOuterPath = UIBezierPath(roundedRect: CGRect(x: verticalDistance, y: horizontalDistance, width: width, height: height), cornerRadius: cornerRadius)
        borderLayer.path = borderOuterPath.cgPath
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.strokeColor = UIColor.white.cgColor
        borderLayer.lineWidth = 0.5
        
        borderLayer.name = bornerLayerName
        self.layer.addSublayer(borderLayer)
    }
    
    fileprivate func removeCameraCutout() {
        let fillLayerName = Constants.UI.CameraView.CameraCutout.fillLayerName
        let bornerLayerName = Constants.UI.CameraView.CameraCutout.bornerLayerName
        
        self.layer.sublayers?
            .filter { layer in return layer.name == fillLayerName }
            .forEach { layer in
                layer.removeFromSuperlayer()
                layer.removeAllAnimations()
            }
        
        self.layer.sublayers?
            .filter { layer in return layer.name == bornerLayerName }
            .forEach { layer in
                layer.removeFromSuperlayer()
                layer.removeAllAnimations()
            }
        
        self.layer.layoutIfNeeded()
    }
}

