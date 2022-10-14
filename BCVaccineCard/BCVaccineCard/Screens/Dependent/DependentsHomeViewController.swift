//
//  DependentsHomeViewController.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2022-10-13.
//

import UIKit


class DependentsHomeViewController: UIViewController {
    
    class func constructDependentsHomeViewController() -> DependentsHomeViewController {
        if let vc = Storyboard.dependents.instantiateViewController(withIdentifier: String(describing: DependentsHomeViewController.self)) as? DependentsHomeViewController {
            return vc
        }
        return DependentsHomeViewController()
    }

    private let emptyLogoTag = 23412
    
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
        title = .dependents
        navigationController?.navigationBar.prefersLargeTitles = true
        style()
        setupTableView()
        fetchData()
    }
    
    func fetchData() {
        dependents = []
    }

    @IBAction func addDependent(_ sender: Any) {
        let addVC = AddDependentViewController.constructAddDependentViewController()
        navigationController?.pushViewController(addVC, animated: true)
    }
    
    @IBAction func manageDependents(_ sender: Any) {
    }
    
    func style() {
        
    }
    
    func styleWithoutDependents() {
        removeEmptyLogo()
        let imgView = UIImageView(frame: .zero)
        tableView.addSubview(imgView)
        imgView.addEqualSizeContraints(to: tableView)
        imgView.image = UIImage(named: "dependent-logo")
        manageDependentsButton.isHidden = true
    }
    
    func styleWithDependents() {
        removeEmptyLogo()
        manageDependentsButton.isHidden = false
    }
    
    private func removeEmptyLogo() {
        guard let imgView = tableView.viewWithTag(emptyLogoTag) else {
            return
        }
        imgView.removeFromSuperview()
    }
    
    func styleButton(filled: Bool) {
        
    }
}

extension DependentsHomeViewController {
    func setupTableView() {
        
    }
}
