//
//  ServicesViewController.swift
//  HealthGatewayTest
//
//  Created by Amir Shayegh on 2023-04-05.
//
// FIXME: NEED TO LOCALIZE 
import UIKit

class ServicesViewController: BaseViewController {
    
    class func construct(viewModel: ViewModel) -> ServicesViewController {
        if let vc = Storyboard.services.instantiateViewController(withIdentifier: String(describing: ServicesViewController.self)) as? ServicesViewController {
            vc.viewModel = viewModel 
            return vc
        }
        return ServicesViewController()
    }

    @IBOutlet weak var containerToDescriptiveLabel: NSLayoutConstraint!
    @IBOutlet weak var containerToTopParent: NSLayoutConstraint!
    @IBOutlet weak var descriptiveLabel: UILabel!
    @IBOutlet weak var contentContainer: UIView!
    
    var viewModel: ViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let vm = viewModel {
            vm.listenToChanges { [weak self] in
                self?.setup()
            }
        }
    }
    
    // MARK: Setup
    func setup() {
        navSetup()
        self.contentContainer.isHidden = false
        self.descriptiveLabel.isHidden = false
        guard let state = viewModel?.currentState else {
            showUnAuthenticated()
            return
        }
        switch state {
        case .Authenticated:
            guard Defaults.enabledTypes?.contains(service: .OrganDonorRegistration) == true && StorageService.shared.fetchAuthenticatedPatient()?.organDonorStatus != nil else {
                showUnavailable()
                return
            }
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
        if let containerToDescriptiveLabel = containerToDescriptiveLabel {
            containerToDescriptiveLabel.isActive = true
        }
        if let containerToTopParent = containerToTopParent {
            containerToTopParent.isActive = false
        }
        view.layoutIfNeeded()
    }
    
    func showUnAuthenticated() {
        let authView: UnAuthenticatedView = UnAuthenticatedView.fromNib()
        authView.setup(in: contentContainer, type: .Services, delegate: self)
        if let containerToDescriptiveLabel = containerToDescriptiveLabel {
            containerToDescriptiveLabel.isActive = true
        }
        if let containerToTopParent = containerToTopParent {
            containerToTopParent.isActive = false
        }
        view.layoutIfNeeded()
    }
    
    func showAuthExpired() {
        let expView: AuthExpiredView = AuthExpiredView.fromNib()
        expView.setup(in: contentContainer, type: .Services, delegate: self)
        if let containerToTopParent = containerToTopParent {
            containerToTopParent.isActive = true
            containerToTopParent.constant = 16
        }
        if let containerToDescriptiveLabel = containerToDescriptiveLabel {
            containerToDescriptiveLabel.isActive = false
        }
        
        view.layoutIfNeeded()
    }
    
    private func showUnavailable() {
        contentContainer.isHidden = true
        descriptiveLabel.isHidden = true
        let image = UIImage(named: "services_empty_state")
        let imageView = UIImageView(image: image)
        self.view.addSubview(imageView)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 251/295).isActive = true
        imageView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 24).isActive = true
        imageView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -24).isActive = true
        imageView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: 0).isActive = true
        
    }

}

extension ServicesViewController: OrganDonorDelegate, AuthViewDelegate, UIDocumentInteractionControllerDelegate {
    
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        guard let navController = self.navigationController else { return self }
        return navController
    }
    
    func authenticate(initialView: AuthenticationViewController.InitialView) {
        showLogin(initialView: initialView)
    }
    
    func download(patient: Patient) {
        guard NetworkConnection.shared.hasConnection else {
            showToast(message: "No internet connection")
            return
        }
        guard let service = viewModel?.pdfService, let status = patient.organDonorStatus else {
            return
        }
        
        service.fetchPDF(donorStatus: status, patient: patient) { [weak self] result in
            guard let `self` = self else {return}
            guard let pdfData = result else {
                self.showToast(message: .maintenanceMessage, style: .Warn)
                return
            }
            self.showPDFDocument(pdf: pdfData, navTitle: "Organ Donor Status", documentVCDelegate: self, navDelegate: self.navDelegate)
        }
        
    }
    
    func reload(patient: Patient) {
        guard NetworkConnection.shared.hasConnection else {
            showToast(message: "No internet connection")
            return
        }
        guard let service = viewModel?.patientService else {
            return
        }
        service.fetchAndStoreOrganDonorStatus(for: patient) {[weak self] result in
            let successful = result != nil
            let message: String = successful ? "Status retrieved" : .fetchRecordError
            self?.showToast(message: message, style: successful ? .Default : .Warn)
            self?.setup()
        }
    }
    
    func registerOrUpdate(patient: Patient) {
        guard NetworkConnection.shared.hasConnection else {
            showToast(message: "No internet connection")
            return
        }
        openURLInSafariVC(withURL: "http://www.transplant.bc.ca/Pages/Register-your-Decision.aspx")
    }
}
