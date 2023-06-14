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
        case PlainTextCell
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
    
    private var service: NotesService?

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
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
        initializeNewNoteIfNecessary()
        initializeNetworkService()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func initializeNetworkService() {
        service = NotesService(network: AFNetwork(), authManager: AuthManager(), configService: MobileConfigService(network: AFNetwork()))
    }
    
    private func screenStateChanged(state: NoteVCCellState) {
        self.state = state
        navSetup()
        setupDataSource(for: state)
        tableView.reloadData()
    }
    
    private func initializeNewNoteIfNecessary() {
        if note == nil {
            let defaultDate = Date().yearMonthDayString
            note = PostNote(title: "", text: "", journalDate: defaultDate, addedToTimeline: false)
        }
    }
    
    private func setupTableView() {
        setupDataSource(for: self.state)
        tableView.register(UINib.init(nibName: EnterTextTableViewCell.getName, bundle: .main), forCellReuseIdentifier: EnterTextTableViewCell.getName)
        tableView.register(UINib.init(nibName: AddToTimelineTableViewCell.getName, bundle: .main), forCellReuseIdentifier: AddToTimelineTableViewCell.getName)
        tableView.register(UINib.init(nibName: TextTableViewCell.getName, bundle: .main), forCellReuseIdentifier: TextTableViewCell.getName)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 180
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func setupDataSource(for state: NoteVCCellState) {
        if state == .ViewNote {
            dataSource = [
                .TitleCell,
                .TimelineCell,
                .PlainTextCell,
                .TextCell
            ]
        } else {
            dataSource = [
                .TitleCell,
                .TimelineCell,
                .TextCell
            ]
        }
    }

}

// MARK: Keyboard
extension NoteViewController {
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardHeight = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height {
            print("Notification: Keyboard will show")
            tableView.setBottomInset(to: keyboardHeight)
        }
    }

    @objc func keyboardWillHide(notification: Notification) {
        print("Notification: Keyboard will hide")
        tableView.setBottomInset(to: 0.0)
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
            let editNavButton = NavButton(image: UIImage(named: "edit-note"), action: #selector(self.editButtonTapped), accessibility: Accessibility(traits: .button, label: AccessibilityLabels.MyHealthPassesScreen.navRightIconTitle, hint: AccessibilityLabels.MyHealthPassesScreen.navRightIconHint))
            let deleteNavButton = NavButton(image: UIImage(named: "delete-note"), action: #selector(self.deleteButtonTapped), accessibility: Accessibility(traits: .button, label: AccessibilityLabels.MyHealthPassesScreen.navRightIconTitle, hint: AccessibilityLabels.MyHealthPassesScreen.navRightIconHint))
            rightNavButtons = [editNavButton, deleteNavButton]
        case .EditNote:
            let navButton = NavButton(title: "Save", image: nil, action: #selector(self.saveButtonTapped), accessibility: Accessibility(traits: .button, label: AccessibilityLabels.MyHealthPassesScreen.navRightIconTitle, hint: AccessibilityLabels.MyHealthPassesScreen.navRightIconHint))
            rightNavButtons = [navButton]
        }
        self.navDelegate?.setNavigationBarWith(title: state.getNavTitle,
                                               leftNavButton: nil,
                                               rightNavButtons: rightNavButtons,
                                               navStyle: .small,
                                               navTitleSmallAlignment: .Center,
                                               targetVC: self,
                                               backButtonHintString: nil)
        
        
    }
    
    @objc private func createButtonTapped() {
        if let errorText = validateNote(note: self.note) {
            alert(title: "Error", message: errorText)
        } else {
            guard let note = note else { return }
            guard let patient = StorageService.shared.fetchAuthenticatedPatient() else { return }
            service?.newNote(title: note.title, text: note.text, journalDate: note.journalDate, addToTimeline: note.addedToTimeline, patient: patient, completion: { note, showErrorIfNecessary in
                if let note = note {
                    self.alert(title: "Success", message: "You successfully created your note") {
                        self.navigationController?.popViewController(animated: true)
                    }
                } else if showErrorIfNecessary {
                    self.alert(title: "Error", message: "There was an error creating your note, please try again.")
                }
            })
        }
        
    }
    
    @objc private func saveButtonTapped() {
        // TODO: Update logic here
        alert(title: "Coming Soon", message: "Save an edited note coming soon") {
            self.screenStateChanged(state: .ViewNote)
        }
    }
    
    @objc private func editButtonTapped() {
        // TODO: Edit logic here
        alert(title: "Coming Soon", message: "Edit a note coming soon")
        screenStateChanged(state: .EditNote)
    }
    
    @objc private func deleteButtonTapped() {
        // TODO: Delete logic here
        self.alert(title: "Delete Note", message: "This action cannot be undone. Are you sure you want to delete this note?", buttonOneTitle: .delete, buttonOneCompletion: {
            self.alert(title: "Coming Soon", message: "Delete a note coming soon")
            // TODO: Delete note then after success, pop back to previous VC
        }, buttonTwoTitle: .cancel) {
            // Do Nothing
        }
    }
}

// MARK: Table View setup
extension NoteViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
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
            guard let cell = tableView.dequeueReusableCell(withIdentifier: EnterTextTableViewCell.getName, for: indexPath) as? EnterTextTableViewCell else { return UITableViewCell() }
            cell.configure(type: .Title, note: self.note, state: self.state, delegateOwner: self)
            return cell
        case .TimelineCell:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: AddToTimelineTableViewCell.getName, for: indexPath) as? AddToTimelineTableViewCell else { return UITableViewCell() }
            cell.configure(for: self.note, state: self.state, delegateOwner: self)
            return cell
        case .TextCell:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: EnterTextTableViewCell.getName, for: indexPath) as? EnterTextTableViewCell else { return UITableViewCell() }
            cell.configure(type: .Text, note: self.note, state: self.state, delegateOwner: self)
            return cell
        case .PlainTextCell:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: TextTableViewCell.getName, for: indexPath) as? TextTableViewCell else { return UITableViewCell() }
            cell.configure(forType: .plainText, text: "Details", withFont: UIFont.bcSansBoldWithSize(size: 17), labelSpacingAdjustment: 0.0)
            return cell
        }
    }
    
}

// MARK: Delegates
extension NoteViewController: AddToTimelineTableViewCellDelegate, EnterTextTableViewCellDelegate {
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
    
    func resizeTableView(type: NotesTextViewType?, shouldScrollDown: Bool) {
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
        guard let type = type else { return }
        if let indexRow = dataSource.firstIndex(of: type.getTableViewStructureType), shouldScrollDown == true {
            let indexPath = IndexPath(row: indexRow, section: 0)
            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
        }
    }
    
    func noteValueChanged(type: NotesTextViewType, text: String) {
        switch type {
        case .Title:
            self.note?.title = text
        case .Text:
            self.note?.text = text
        }
    }
    
    func didBeginEditing(type: NotesTextViewType?) {
        // Not using right now - will delete after notes feature is finished if we don't end up using
        guard let type = type else { return }

    }
    
}

// MARK: Validation
extension NoteViewController {
    private func validateNote(note: PostNote?) -> String? {
        guard let note = note else {
            return "You must complete your note before creating"
        }
        var errorText: String?
        if note.title.trimWhiteSpacesAndNewLines.count == 0 {
            errorText = "You must enter a title for your note"
        }
        // TODO: Confirm this still works
//        else if note.text.trimWhiteSpacesAndNewLines.count == 0 {
//            errorText = "You must enter some text for your note"
//        }
        return errorText
    }
}

// MARK: TableView Keyboard ext
// TODO: Put in extension file if it works
extension UITableView {

    func setBottomInset(to value: CGFloat) {
        let edgeInset = UIEdgeInsets(top: 0, left: 0, bottom: value, right: 0)

        self.contentInset = edgeInset
        self.scrollIndicatorInsets = edgeInset
    }
}
