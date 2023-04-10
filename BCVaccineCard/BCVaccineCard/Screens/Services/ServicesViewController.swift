//
//  ServicesViewController.swift
//  HealthGatewayTest
//
//  Created by Amir Shayegh on 2023-04-05.
//

import UIKit

class ServicesViewController: BaseViewController {
    
    class func construct(viewModel: ViewModel) -> ServicesViewController {
        if let vc = Storyboard.services.instantiateViewController(withIdentifier: String(describing: ServicesViewController.self)) as? ServicesViewController {
            vc.viewModel = viewModel 
            return vc
        }
        return ServicesViewController()
    }

    @IBOutlet weak var descriptiveLabel: UILabel!
    @IBOutlet weak var contentContainer: UIView!
    
    var viewModel: ViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        if let vm = viewModel {
            vm.listenToChanges { [weak self] in
                self?.setup()
            }
        }
    }
    
    // MARK: Setup
    func setup() {
        navSetup()
        guard let state = viewModel?.currentState else {
            showUnAuthenticated()
            return
        }
        
        switch state {
        case .Authenticated:
            showList()
        case .AuthenticationExpired:
            showAuthExpired()
        case .UnAuthenticated:
            showUnAuthenticated()
        }
    }
    
    private func navSetup() {
        self.navDelegate?.setNavigationBarWith(title: "Services",
                                               leftNavButton: nil,
                                               rightNavButton: NavButton(image: UIImage(named: "nav-settings"), action: #selector(self.settingsButton), accessibility: Accessibility(traits: .button, label: AccessibilityLabels.MyHealthPassesScreen.navRightIconTitle, hint: AccessibilityLabels.MyHealthPassesScreen.navRightIconHint)),
                                               navStyle: .large,
                                               navTitleSmallAlignment: .Center,
                                               targetVC: self,
                                               backButtonHintString: nil)
    }
    
    func showList() {
        guard let patient = StorageService.shared.fetchAuthenticatedPatient() else {
            return
        }
        let list: ServicesList = ServicesList.fromNib()
        list.setup(in: contentContainer, for: patient, organDonorDelegate: self)
    }
    
    func showUnAuthenticated() {
        let authView: UnAuthenticatedView = UnAuthenticatedView.fromNib()
        authView.setup(in: contentContainer, type: .Services, delegate: self)
    }
    
    func showAuthExpired() {
        let expView: AuthExpiredView = AuthExpiredView.fromNib()
        expView.setup(in: contentContainer, type: .Services, delegate: self)
    }

}

extension ServicesViewController: OrganDonorDelegate, AuthViewDelegate {
    func authenticate(initialView: AuthenticationViewController.InitialView) {
        showLogin(initialView: initialView)
    }
    
    func download(patient: Patient) {
        
    }
    
    func registerOrUpdate(patient: Patient) {
        
    }
    
    
}
