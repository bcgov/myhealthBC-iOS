//
//  ManageDependentsViewController.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2022-10-26.
//

import UIKit

class ManageDependentsViewController: BaseDependentViewController {
    
    class func constructManageDependentsViewController(patient: Patient) -> ManageDependentsViewController {
        if let vc = Storyboard.dependents.instantiateViewController(withIdentifier: String(describing: ManageDependentsViewController.self)) as? ManageDependentsViewController {
            vc.patient = patient
            return vc
        }
        return ManageDependentsViewController()
    }
    
    private var patient: Patient? = nil
    private var dependents: [Dependent] = []
    
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        dependents = patient?.dependentsArray ?? []
        setupTableView()
        navSetup()
        tableView.setEditing(true, animated: true)
    }
}
// MARK: Tableview
extension ManageDependentsViewController: UITableViewDelegate, UITableViewDataSource {
    
    private func setupTableView() {
        tableView.register(UINib.init(nibName: DependentListItemTableViewCell.getName, bundle: .main), forCellReuseIdentifier: DependentListItemTableViewCell.getName)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 84
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dependents.count
    }
    
    private func dependentCell(indexPath: IndexPath) -> DependentListItemTableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: DependentListItemTableViewCell.getName, for: indexPath) as? DependentListItemTableViewCell else {
            return DependentListItemTableViewCell()
        }
        cell.configure(name: dependents[indexPath.row].info?.name ?? "", hideArrow: true)
        return cell
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return dependentCell(indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showToast(message: "Feature not implemented")
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard NetworkConnection.shared.hasConnection else {
            alert(title: "Device is Offline", message: "Please connect to the internet to remove dependents")
            return
        }
        
        let dependent = dependents[indexPath.row]
        delete(dependent: dependent) {[weak self] confirmed in
            guard let `self` = self else {return}
            if confirmed {
                self.dependents.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
                if self.dependents.isEmpty {
                    self.navigationController?.popViewController(animated: true)
                }
            } else {
                self.tableView.setEditing(false, animated: false)
                self.tableView.setEditing(true, animated: true)
            }
        }
    }
}

extension ManageDependentsViewController {
    private func navSetup() {
        self.navDelegate?.setNavigationBarWith(title: .manageDependends,
                                               leftNavButton: nil,
                                               rightNavButton: nil,
                                               navStyle: .small,
                                               navTitleSmallAlignment: .Center,
                                               targetVC: self,
                                               backButtonHintString: nil)
    }
}
