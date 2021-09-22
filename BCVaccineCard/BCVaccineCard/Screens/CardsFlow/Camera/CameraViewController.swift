//
//  CameraViewController.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2021-09-22.
//

import UIKit
import BCVaccineValidator

class CameraViewController: UIViewController {

    private var completionHandler: ((ScanResultModel?)->Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showScanner { [weak self] result in
            guard let `self` = self, let completion = self.completionHandler else {return}
            self.dismiss(animated: true, completion: nil)
            completion(result)
        }
    }
    
    public func setup(result: @escaping(ScanResultModel?)->Void) {
        self.completionHandler = result
    }
    
    private func showScanner(result: @escaping(ScanResultModel?)->Void) {
        let scanView: QRScannerView = QRScannerView()
        scanView.present(on: self, completion: result)
    }

}
