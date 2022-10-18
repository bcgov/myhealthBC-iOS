//
//  DependentsHomeViewController.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2022-10-13.
//

import UIKit


class DependentsHomeViewController: BaseViewController {
    
    class func constructDependentsHomeViewController() -> DependentsHomeViewController {
        if let vc = Storyboard.dependents.instantiateViewController(withIdentifier: String(describing: DependentsHomeViewController.self)) as? DependentsHomeViewController {
            return vc
        }
        return DependentsHomeViewController()
    }

    private let emptyLogoTag = 23412
    private let service = DependentService(network: AFNetwork(), authManager: AuthManager())
    
    @IBOutlet weak var desciptionLabel: UILabel!
    @IBOutlet weak var addDependentButton: UIButton!
    @IBOutlet weak var manageDependentsButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
   
    
    var dependents: [Patient] = [] {
        didSet {
            if dependents.isEmpty {
                styleWithoutDependents()
            } else {
                styleWithDependents()
                tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navSetup()
        style()
        setupTableView()
        fetchData()
    }
    
    private func fetchData() {
        service.fetchDependents { completed in
            // If completed, then reload data/update screen UI - if not completed, show an error
        }
        // TODO: Allocate this appropriately once storage has been updated
        dependents = []
    }

    @IBAction func addDependent(_ sender: Any) {
        let addVC = AddDependentViewController.constructAddDependentViewController()
        self.navigationController?.pushViewController(addVC, animated: true)
    }
    
    @IBAction func manageDependents(_ sender: Any) {
    }
    
    private func style() {
        
    }
    
    private func styleWithoutDependents() {
        removeEmptyLogo()
        let imgView = UIImageView(frame: .zero)
        tableView.addSubview(imgView)
        imgView.addEqualSizeContraints(to: tableView)
        imgView.image = UIImage(named: "dependent-logo")
        manageDependentsButton.isHidden = true
    }
    
    private func styleWithDependents() {
        removeEmptyLogo()
        manageDependentsButton.isHidden = false
    }
    
    private func removeEmptyLogo() {
        guard let imgView = tableView.viewWithTag(emptyLogoTag) else {
            return
        }
        imgView.removeFromSuperview()
    }
    
    private func styleButton(filled: Bool) {
        
    }
}

// MARK: Navigation setup
extension DependentsHomeViewController {
    private func navSetup() {
        self.navDelegate?.setNavigationBarWith(title: .dependents,
                                               leftNavButton: nil,
                                               rightNavButton: nil,
                                               navStyle: .large,
                                               navTitleSmallAlignment: .Center,
                                               targetVC: self,
                                               backButtonHintString: .dependents)
    }
}

extension DependentsHomeViewController {
    func setupTableView() {
        
    }
}
