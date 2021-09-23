//
//  CameraViewController.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2021-09-22.
//

import UIKit
import BCVaccineValidator

class CameraViewController: UIViewController {

    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var divider: UIView!
    @IBOutlet weak var navBarView: UIView!
    @IBOutlet weak var cameraContainer: UIView!
    private var completionHandler: ((ScanResultModel?)->Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        closeButton.tintColor = Constants.UI.Theme.primaryConstractColor
        closeButton.setTitle("", for: .normal)
    }

}
