//
//  BDLoadFatalError.swift
//  HealthGatewayTest
//
//  Created by Amir Shayegh on 2023-02-02.
//

import UIKit

class DBLoadFatalError: UIView {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    
    func showError() {
//        titleLabel.text = "Storage Error"
//        bodyLabel.text = "We couldn't initialize storage for this application.\n\nPlease try closing and launching this application again.\n\nif this error persists, please delete the app and download again from the App Store."
    }
}
