//
//  ServicesViewController.swift
//  HealthGatewayTest
//
//  Created by Amir Shayegh on 2023-04-05.
//

import UIKit

class ServicesViewController: UIViewController {
    
    class func construct() -> ServicesViewController {
        if let vc = Storyboard.services.instantiateViewController(withIdentifier: String(describing: ServicesViewController.self)) as? ServicesViewController {
            return vc
        }
        return ServicesViewController()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

}
