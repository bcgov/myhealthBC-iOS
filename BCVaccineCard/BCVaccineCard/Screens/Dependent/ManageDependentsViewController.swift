//
//  ManageDependentsViewController.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2022-10-26.
//

import UIKit

class ManageDependentsViewController: BaseViewController {
    
    class func constructManageDependentsViewController(patient: Patient) -> ManageDependentsViewController {
        if let vc = Storyboard.dependents.instantiateViewController(withIdentifier: String(describing: ManageDependentsViewController.self)) as? ManageDependentsViewController {
            vc.patient = patient
            return vc
        }
        return ManageDependentsViewController()
    }
    
    private var patient: Patient? = nil
    private var dependents: [Dependent] = []
    private var dependentsToRemove: [Dependent] = []
    private let networkService = DependentService(network: AFNetwork(), authManager: AuthManager())
    
    @IBOutlet weak var saveChangesButton: UIButton!
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        dependents = patient?.dependentsArray ?? []
        setupTableView()
        navSetup()
        tableView.setEditing(true, animated: true)
        style(button: saveChangesButton, style: .Fill, title: .saveChanges, image: nil)
    }

    @IBAction func saveChanges(_ sender: Any) {
        
        guard let patient = patient, !dependentsToRemove.isEmpty else {
            navigationController?.popViewController(animated: true)
            return
        }
        
        guard NetworkConnection.shared.hasConnection else {
            alert(title: "Defice is Offline", message: "Please connect to the internet to remove dependents")
            return
        }
        
        alertConfirmation(title: .deleteDependentTitle, message: .deleteDependentMessage, confirmTitle: .delete, confirmStyle: .destructive) { [weak self] in
            guard let `self` = self else {return}
            self.networkService.delete(dependents: self.dependentsToRemove, for: patient, completion: {[weak self] success in
                self?.navigationController?.popViewController(animated: true)
            })
        } onCancel: { [weak self] in
            self?.tableView.setEditing(false, animated: false)
            self?.tableView.setEditing(true, animated: true)
        }
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
        cell.configure(name: dependents[indexPath.row].info?.name ?? "")
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
            alert(title: "Defice is Offline", message: "Please connect to the internet to remove dependents")
            return
        }
        let dependent = dependents[indexPath.row]
        dependentsToRemove.append(dependent)
        dependents.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
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
