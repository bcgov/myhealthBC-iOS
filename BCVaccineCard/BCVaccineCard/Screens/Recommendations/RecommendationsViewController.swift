//
//  RecommendationsViewController.swift
//  HealthGatewayTest
//
//  Created by Amir Shayegh on 2022-08-23.
//

import UIKit

class RecommendationsViewController: BaseViewController {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var tableView: UITableView!
    
    private var recommendations: [ImmunizationRecommendation] {
        return StorageService.shared.fetchRecommendations().sorted(by: {$0.diseaseDueDate ?? Date() > $1.diseaseDueDate  ?? Date()})
    }
    private var expandedIndecies: [Int] = []
    
    class func constructRecommendationsViewController() -> RecommendationsViewController {
        if let vc = Storyboard.recommendations.instantiateViewController(withIdentifier: String(describing: RecommendationsViewController.self)) as? RecommendationsViewController {
            return vc
        }
        return RecommendationsViewController()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        expandedIndecies = [0]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupTextView()
        guard let tableView = tableView else {return}
        tableView.reloadData()
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
        view.layoutIfNeeded()
        textView.textColor = AppColours.textGray
        let attributedText = NSMutableAttributedString(string: "For more information on vaccines recommendation and eligibility, please visit immunizeBC or speak to your health care provider. ")
        _ = attributedText.setAsLink(textToFind: "immunizeBC", linkURL: "https://immunizebc.ca/")
        textView.attributedText = attributedText
        textView.isUserInteractionEnabled = true
        textView.delegate = self
        textView.font = UIFont.bcSansRegularWithSize(size: 13)
        textView.translatesAutoresizingMaskIntoConstraints = true
        textView.sizeToFit()
        textView.isScrollEnabled = false
        textView.isEditable = false
        view.layoutIfNeeded()
    }

}
extension RecommendationsViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        UIApplication.shared.open(URL)
        return false
    }
}

extension RecommendationsViewController: UITableViewDelegate, UITableViewDataSource {
    private func setupTableView() {
        guard let tableView = tableView else {return}
        tableView.register(UINib.init(nibName: ReccomandationTableViewCell.getName, bundle: .main), forCellReuseIdentifier: ReccomandationTableViewCell.getName)
        
        tableView.rowHeight = UITableView.automaticDimension
        // tableView.estimatedRowHeight = 100
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recommendations.count
    }
    
    func getCell(indexPath: IndexPath) -> ReccomandationTableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ReccomandationTableViewCell.getName, for: indexPath) as? ReccomandationTableViewCell else {
            return ReccomandationTableViewCell()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = getCell(indexPath: indexPath)
        if recommendations.indices.contains(indexPath.row) {
            cell.configure(object: recommendations[indexPath.row], expanded: expandedIndecies.contains(indexPath.row))
        }
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if expandedIndecies.contains(indexPath.row) {
            expandedIndecies.removeAll(where: {$0 == indexPath.row})
            tableView.beginUpdates()
            tableView.reloadRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
        } else {
            expandedIndecies.append(indexPath.row)
            tableView.beginUpdates()
            tableView.reloadRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
        }
    }
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
