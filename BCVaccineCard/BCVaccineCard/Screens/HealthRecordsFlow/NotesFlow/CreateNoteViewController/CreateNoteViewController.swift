//
//  CreateNoteViewController.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2023-06-07.
//

import UIKit

class CreateNoteViewController: BaseViewController {
    
    class func construct() -> CreateNoteViewController {
        if let vc = Storyboard.records.instantiateViewController(withIdentifier: String(describing: CreateNoteViewController.self)) as? CreateNoteViewController {
            return vc
        }
        return CreateNoteViewController()
    }
    
    @IBOutlet weak private var tableView: UITableView!
    
    private var note: PostNote?

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            return UIStatusBarStyle.darkContent
        } else {
            return UIStatusBarStyle.default
        }
    }
 
    private func setup() {
        navSetup()
        setupTableView()
    }
    
    private func setupTableView() {
        // TODO: Setup table view here
    }

}

// MARK: Navigation setup
extension CreateNoteViewController {
    private func navSetup() {
        self.navDelegate?.setNavigationBarWith(title: "Add Note",
                                               leftNavButton: nil,
                                               rightNavButton: NavButton(title: "Create", image: nil, action: #selector(self.createButtonTapped), accessibility: Accessibility(traits: .button, label: AccessibilityLabels.MyHealthPassesScreen.navRightIconTitle, hint: AccessibilityLabels.MyHealthPassesScreen.navRightIconHint)),
                                               navStyle: .large,
                                               navTitleSmallAlignment: .Center,
                                               targetVC: self,
                                               backButtonHintString: nil)
        
        
    }
    
    @objc private func createButtonTapped() {
        // TODO: Create logic here
    }
}
