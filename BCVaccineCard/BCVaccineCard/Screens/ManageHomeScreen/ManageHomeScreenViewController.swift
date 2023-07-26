//
//  ManageHomeScreenViewController.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2023-07-26.
//

import UIKit

class ManageHomeScreenViewController: BaseViewController {
    
    class func construct() -> ManageHomeScreenViewController {
        if let vc = Storyboard.home.instantiateViewController(withIdentifier: String(describing: ManageHomeScreenViewController.self)) as? ManageHomeScreenViewController {
            return vc
        }
        return ManageHomeScreenViewController()
    }
    
    @IBOutlet private weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup() {
        
    }

}
