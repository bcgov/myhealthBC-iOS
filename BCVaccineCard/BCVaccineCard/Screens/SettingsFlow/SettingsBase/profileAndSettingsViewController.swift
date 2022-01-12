//
//  profileAndSettingsViewController.swift
//  BCVaccineCard
//
//  Created by Amir on 2022-01-11.
//

import UIKit

class profileAndSettingsViewController: UIViewController {
    
    enum TableRow: Int, CaseIterable {
        case profile
        case securityAndData
        case privacyStatement
    }

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
}

extension profileAndSettingsViewController: UITableViewDelegate, UITableViewDataSource {
    
}
