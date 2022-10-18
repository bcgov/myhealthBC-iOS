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
    @IBOutlet weak var loginWIthBCSCButton: UIButton!
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
        setState()
    }
    
    private func fetchData() {
        service.fetchDependents { completed in
            // If completed, then reload data/update screen UI - if not completed, show an error
        }
        // TODO: Allocate this appropriately once storage has been updated
        dependents = []
        setState()
    }

    @IBAction func addDependent(_ sender: Any) {
        let addVC = AddDependentViewController.constructAddDependentViewController()
        self.navigationController?.pushViewController(addVC, animated: true)
    }
    
    @IBAction func manageDependents(_ sender: Any) {
    }
    

    @IBAction func LoginWithBCSC(_ sender: Any) {
        let vc = AuthenticationViewController.constructAuthenticationViewController(
            createTabBarAndGoToHomeScreen: false,
            isModal: true,
            initialView: .Auth,
            sourceVC: .Dependents,
            presentingViewControllerReference: self
        ) { [weak self] status in
            self?.fetchData()
        }
        present(vc, animated: true)
    }
    
    func style() {
        style(button: addDependentButton, filled: true)
        style(button: loginWIthBCSCButton, filled: true)
        style(button: manageDependentsButton, filled: false)
        navSetup()
    }
    
    func setState() {
        if !AuthManager().isAuthenticated {
            styleUnauthenticated()
        } else {
            if dependents.isEmpty {
                styleWithoutDependents()
            } else {
                styleWithDependents()
            }
        }
    }
    
    func styleWithoutDependents() {
        let imageView = createLogoImgView()
        imageView.image = UIImage(named: "dependent-logo")
        manageDependentsButton.isHidden = true
        loginWIthBCSCButton.isHidden = true
        addDependentButton.isHidden = false
    }
    
    func styleUnauthenticated() {
        let imageView = createLogoImgView()
        imageView.image = UIImage(named: "dependent-logged-out")
        addDependentButton.isHidden = true
        manageDependentsButton.isHidden = true
        loginWIthBCSCButton.isHidden = false
    }
    
    private func styleWithDependents() {
        removeEmptyLogo()
        addDependentButton.isHidden = false
        manageDependentsButton.isHidden = false
        loginWIthBCSCButton.isHidden = true
    }
    
    private func createLogoImgView() -> UIImageView {
        removeEmptyLogo()
        let imgView = UIImageView(frame: tableView.bounds)
        imgView.tag = emptyLogoTag
        view.addSubview(imgView)
        imgView.addEqualSizeContraints(to: tableView, paddingVertical: 32, paddingHorizontal: 32)
        imgView.contentMode = .scaleAspectFit
        return imgView
    }
    
    private func removeEmptyLogo() {
        guard let imgView = view.viewWithTag(emptyLogoTag) else {
            return
        }
        imgView.removeFromSuperview()
    }
    func style(button: UIButton, filled: Bool) {
        button.layer.cornerRadius = 4
        button.titleLabel?.font = UIFont.bcSansBoldWithSize(size: 18)
        if filled {
            button.backgroundColor = AppColours.appBlue
            button.setTitleColor(.white, for: .normal)
            button.tintColor = .white
            
        } else {
            button.setTitleColor(AppColours.appBlue, for: .normal)
            button.backgroundColor = .white
            button.layer.borderWidth = 2
            button.layer.borderColor = AppColours.appBlue.cgColor
        }
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
    private func navSetup() {
        self.navDelegate?.setNavigationBarWith(title: .dependents,
                                               leftNavButton: nil,
                                               rightNavButton: NavButton(image: UIImage(named: "nav-settings"), action: #selector(self.settingsButton), accessibility: Accessibility(traits: .button, label: AccessibilityLabels.MyHealthPassesScreen.navRightIconTitle, hint: AccessibilityLabels.MyHealthPassesScreen.navRightIconHint)),
                                               navStyle: .large,
                                               navTitleSmallAlignment: .Center,
                                               targetVC: self,
                                               backButtonHintString: nil)
    }
}


extension DependentsHomeViewController: UITableViewDelegate, UITableViewDataSource {
    
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
        dependents.count
    }
    
    private func dependentCell(indexPath: IndexPath) -> DependentListItemTableViewCell? {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: DependentListItemTableViewCell.getName, for: indexPath) as? DependentListItemTableViewCell else {
                return nil
            }
        return cell
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = dependentCell(indexPath: indexPath) else {return UITableViewCell()}
        cell.configure(name: dependents[indexPath.row].name ?? "")
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Show Dependent Details")
    }
}
