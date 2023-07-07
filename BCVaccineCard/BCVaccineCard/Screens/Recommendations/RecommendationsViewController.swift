//
//  RecommendationsViewController.swift
//  HealthGatewayTest
//
//  Created by Amir Shayegh on 2022-08-23.
//

import UIKit

class RecommendationsViewController: BaseViewController {

    @IBOutlet weak var textViewHeight: NSLayoutConstraint!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var tableView: UITableView!
    
    private var patients: [Patient] {
        var results: [Patient] = []
        guard let primary = StorageService.shared.fetchAuthenticatedPatient() else {
            return []
        }
        results.append(primary)
        results.append(contentsOf: primary.dependentsArray.compactMap{$0.info})
        
        return results
    }
    private var expandedPatients: [Patient] = []
    
    class func construct() -> RecommendationsViewController {
        if let vc = Storyboard.recommendations.instantiateViewController(withIdentifier: String(describing: RecommendationsViewController.self)) as? RecommendationsViewController {
            return vc
        }
        return RecommendationsViewController()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        expandedPatients = []
//        guard let tableView = tableView else {return}
//        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.prefersLargeTitles = false
        tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        setupTextView()
//        guard let tableView = tableView else {return}
//        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    func setup() {
        navSetup()
        setupTableView()
        setupTextView()
    }
    
    private func setupTextView() {
        guard let textView = self.textView else {return}
        textView.textColor = AppColours.textGray
        let attributedText = NSMutableAttributedString(string: "Recommended immunization are suggestion for your health journey. This page will containt all of future immunization for you and your dependents. To add dependents to application, click on Dependent in the menu bar at the bottom.\n\nFor more information on vaccines recommendation and eligibility, please visit immunizeBC or speak to your health care provider. ")
        _ = attributedText.setAsLink(textToFind: "immunizeBC", linkURL: "https://immunizebc.ca/")
        textView.attributedText = attributedText
        textView.isUserInteractionEnabled = true
        textView.delegate = self
        textView.font = UIFont.bcSansRegularWithSize(size: 13)
//        textView.translatesAutoresizingMaskIntoConstraints = true
//        textView.sizeToFit()
        textView.isScrollEnabled = false
        textView.isEditable = false
        let sizeThatFitsTextView = textView.sizeThatFits(CGSize(width: textView.frame.size.width, height: CGFloat(MAXFLOAT)))
        let heightOfText = sizeThatFitsTextView.height
        textViewHeight.constant = heightOfText
        self.view.layoutIfNeeded()
    }

}
extension RecommendationsViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
//        UIApplication.shared.open(URL)
        AppDelegate.sharedInstance?.showExternalURL(url: URL.absoluteString)
        return false
    }
}

extension RecommendationsViewController: UITableViewDelegate, UITableViewDataSource, PatientRecomandationsHeaderViewDelegate {
   
    private func setupTableView() {
        guard let tableView = tableView else {return}
        tableView.register(UINib.init(nibName: PatientRecommendationsTableViewCell.getName, bundle: .main), forCellReuseIdentifier: PatientRecommendationsTableViewCell.getName)
        
        tableView.rowHeight = UITableView.automaticDimension
        // tableView.estimatedRowHeight = 100
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsVerticalScrollIndicator = false
        tableView.backgroundColor = .clear
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return patients.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let patient = patients[section]
        if expandedPatients.contains(where: {$0 == patient}) {
            return 1
        } else {
            return 0
        }
    }
    
    func getCell(indexPath: IndexPath) -> PatientRecommendationsTableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PatientRecommendationsTableViewCell.getName, for: indexPath) as? PatientRecommendationsTableViewCell else {
            return PatientRecommendationsTableViewCell()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = getCell(indexPath: indexPath)
        cell.configure(patient: patients[indexPath.row])
//        if recommendations.indices.contains(indexPath.row) {
//            cell.configure(object: recommendations[indexPath.row], expanded: expandedIndecies.contains(indexPath.row))
//        }
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let patient = patients[section]
        let isExpanded = expandedPatients.contains(where: {$0 == patient})
        let view: PatientRecomandationsHeaderView = PatientRecomandationsHeaderView.fromNib()
        view.configure(patient: patient, expanded: isExpanded, delegate: self)
        return view
    }
    
    func toggle(patient: Patient) {
        let isExpanded = expandedPatients.contains(where: {$0 == patient})
        if isExpanded {
            expandedPatients.removeAll(where: {$0 == patient})
        } else {
            expandedPatients.append(patient)
        }
        tableView.reloadData()
    }
    
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if expandedIndecies.contains(indexPath.row) {
//            expandedIndecies.removeAll(where: {$0 == indexPath.row})
//            tableView.beginUpdates()
//            tableView.reloadRows(at: [indexPath], with: .automatic)
//            tableView.endUpdates()
//        } else {
//            expandedIndecies.append(indexPath.row)
//            tableView.beginUpdates()
//            tableView.reloadRows(at: [indexPath], with: .automatic)
//            tableView.endUpdates()
//        }
//    }
}
// MARK: Navigation setup
extension RecommendationsViewController {
    private func navSetup() {
        self.navDelegate?.setNavigationBarWith(title: "Recommended immunizations",
                                               leftNavButton: nil,
                                               rightNavButton: NavButton(image: UIImage(named: "nav-settings"), action: #selector(self.settingsButton), accessibility: Accessibility(traits: .button, label: AccessibilityLabels.MyHealthPassesScreen.navRightIconTitle, hint: AccessibilityLabels.MyHealthPassesScreen.navRightIconHint)),
                                               navStyle: .small,
                                               navTitleSmallAlignment: .Center,
                                               targetVC: self,
                                               backButtonHintString: nil)
    }
}
