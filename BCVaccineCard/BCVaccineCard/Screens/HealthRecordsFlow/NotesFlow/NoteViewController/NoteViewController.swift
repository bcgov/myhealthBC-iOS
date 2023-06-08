//
//  NoteViewController.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2023-06-07.
//

import UIKit

enum NoteVCCellState {
    case AddNote
    case ViewNote
    case EditNote
    
    var getNavTitle: String {
        switch self {
        case .AddNote:
            return "Add Note"
        case .ViewNote:
            return ""
        case .EditNote:
            return "Edit Note"
        }
    }
}

class NoteViewController: BaseViewController {
    
    enum TableViewStructure {
        case TitleCell
        case TimelineCell
        case TextCell
    }
    
    class func construct(for state: NoteVCCellState, with note: PostNote?) -> NoteViewController {
        if let vc = Storyboard.records.instantiateViewController(withIdentifier: String(describing: NoteViewController.self)) as? NoteViewController {
            vc.state = state
            vc.note = note
            return vc
        }
        return NoteViewController()
    }
    
    @IBOutlet weak private var tableView: UITableView!
    
    private var note: PostNote?
    private var state: NoteVCCellState!
    private var dataSource: [TableViewStructure] = []

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
        setupDataSource()
        tableView.register(UINib.init(nibName: EnterTextTableViewCell.getName, bundle: .main), forCellReuseIdentifier: EnterTextTableViewCell.getName)
        tableView.register(UINib.init(nibName: AddToTimelineTableViewCell.getName, bundle: .main), forCellReuseIdentifier: AddToTimelineTableViewCell.getName)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func setupDataSource() {
        dataSource = [
            .TitleCell,
            .TimelineCell,
            .TextCell
        ]
    }

}

// MARK: Navigation setup
extension NoteViewController {
    private func navSetup() {
        // TODO: Adjust for different screen states for right nav buttons
        var rightNavButtons: [NavButton] = []
        guard let state = state else { return }
        switch state {
        case .AddNote:
            let navButton = NavButton(title: "Create", image: nil, action: #selector(self.createButtonTapped), accessibility: Accessibility(traits: .button, label: AccessibilityLabels.MyHealthPassesScreen.navRightIconTitle, hint: AccessibilityLabels.MyHealthPassesScreen.navRightIconHint))
            rightNavButtons = [navButton]
        case .ViewNote:
            // TODO: Fix UIImmages
            let editNavButton = NavButton(image: UIImage(named: "edit-icon"), action: #selector(self.editButtonTapped), accessibility: Accessibility(traits: .button, label: AccessibilityLabels.MyHealthPassesScreen.navRightIconTitle, hint: AccessibilityLabels.MyHealthPassesScreen.navRightIconHint))
            let deleteNavButton = NavButton(image: UIImage(named: "edit-icon"), action: #selector(self.deleteButtonTapped), accessibility: Accessibility(traits: .button, label: AccessibilityLabels.MyHealthPassesScreen.navRightIconTitle, hint: AccessibilityLabels.MyHealthPassesScreen.navRightIconHint))
        case .EditNote:
            let navButton = NavButton(title: "Save", image: nil, action: #selector(self.saveButtonTapped), accessibility: Accessibility(traits: .button, label: AccessibilityLabels.MyHealthPassesScreen.navRightIconTitle, hint: AccessibilityLabels.MyHealthPassesScreen.navRightIconHint))
            rightNavButtons = [navButton]
        }
        self.navDelegate?.setNavigationBarWith(title: state.getNavTitle,
                                               leftNavButton: nil,
                                               rightNavButtons: rightNavButtons,
                                               navStyle: .large,
                                               navTitleSmallAlignment: .Center,
                                               targetVC: self,
                                               backButtonHintString: nil)
        
        
    }
    
    @objc private func createButtonTapped() {
        // TODO: Create logic here
    }
    
    @objc private func saveButtonTapped() {
        // TODO: Update logic here
    }
    
    @objc private func editButtonTapped() {
        // TODO: Edit logic here
    }
    
    @objc private func deleteButtonTapped() {
        // TODO: Delete logic here
    }
}

// MARK: Table View setup
extension NoteViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = dataSource[indexPath.row]
        return createTableViewCell(for: cell, tableView: tableView, indexPath: indexPath)
    }
    
    // TODO: May need to call other delegates here, tbd...
    
    private func createTableViewCell(for cell: TableViewStructure, tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        switch cell {
        case .TitleCell:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: EnterTextTableViewCell.getName) as? EnterTextTableViewCell else { return UITableViewCell() }
            cell.configure(type: .Title, note: self.note)
            return cell
        case .TimelineCell:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: AddToTimelineTableViewCell.getName) as? AddToTimelineTableViewCell else { return UITableViewCell() }
            cell.configure(for: self.note, state: self.state, delegateOwner: self)
            return cell
        case .TextCell:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: EnterTextTableViewCell.getName) as? EnterTextTableViewCell else { return UITableViewCell() }
            cell.configure(type: .Text, note: self.note)
            return cell
        }
    }
    
}

// MARK: Delegates
extension NoteViewController: AddToTimelineTableViewCellDelegate {
    func selectFolderButtonTapped() {
        alert(title: "Coming soon", message: "Feature coming soon")
    }
    
    func datePickerChanged(date: String) {
        self.note?.journalDate = date
    }
    
    func addToTimelineInfoButtonTapped() {
        alert(title: "Info", message: "Info button tapped")
    }
    
    func addToTimelineSwitchValueChanged(isOn: Bool) {
        self.note?.addedToTimeline = isOn
    }
    
    
}
