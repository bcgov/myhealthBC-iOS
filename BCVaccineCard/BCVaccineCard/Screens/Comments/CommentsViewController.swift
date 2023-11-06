//
//  CommentsViewController.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2022-10-04.
//
// FIXME: NEED TO LOCALIZE 
import Foundation
import UIKit

class CommentsViewController: UIViewController, CommentTextFieldViewDelegate {
    
    // TODO: move to new file
    struct ViewModel {
        var record: HealthRecordsDetailDataSource.Record
    }
    
    class func construct(viewModel: ViewModel) -> CommentsViewController {
        if let vc = Storyboard.comments.instantiateViewController(withIdentifier: String(describing: CommentsViewController.self)) as? CommentsViewController {
            vc.model = viewModel.record
            return vc
        }
        return CommentsViewController()
    }
    
    public var model: HealthRecordsDetailDataSource.Record? = nil
    private var comments: [Comment] = []
    fileprivate var debounceTitleStrollUpBlock = false
    fileprivate var debounceTitleStrollDownBlock = false
    fileprivate var debounceTitleStrollUpBlockTimer: Timer? = nil
    fileprivate var debounceTitleStrollDownBlockTimer: Timer? = nil
    fileprivate var titleVisibleContraint: CGFloat = 25
    fileprivate var titleHiddenContraint: CGFloat {
        return 0 - (titleLabel.bounds.height + titleVisibleContraint)
    }
    fileprivate var lastKnowContentOfsset: CGFloat = 0.0
    fileprivate var hideTitleAfterScroll: Bool = false
    fileprivate let titleText = "Only you can see comments added to your medical records."
    
    @IBOutlet weak var titleTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var fieldContainer: UIView!
    @IBOutlet weak var tableView: UITableView!
    
//    private var optionsDropDownView: CommentsOptionsDropDownView?
    private var actionSheetController: UIAlertController?
    
    private var indexPathBeingEdited: IndexPath? {
        didSet {
            self.tableView.reloadData()
        }
    }
        
    private var indexPathBeingDeleted: IndexPath?
    
    private var editedText: String?
    
    override func viewDidLoad() {
        self.title = "Comments"
        setup()
        listenToSync()
    }
    
    func setup() {
        guard titleLabel != nil else {return}
        titleLabel.text = titleText
        
        let commentTextField: CommentTextFieldView = CommentTextFieldView.fromNib()
        fieldContainer.addSubview(commentTextField)
        commentTextField.addEqualSizeContraints(to: fieldContainer)
       
        commentTextField.setup()
        commentTextField.delegate = self
        
        comments = model?.comments.filter({ $0.shouldHide != true }) ?? []
        comments = comments.sorted(by: {$0.createdDateTime ?? Date() < $1.createdDateTime ?? Date()})
        setupTableView()
        style()
        scrollToBottom()
        
    }
    
    func listenToSync() {
        NotificationCenter.default.addObserver(self, selector: #selector(storageChangeEvent), name: .storageChangeEvent, object: nil)
    }
        
    @objc private func storageChangeEvent(_ notification: Notification) {
        guard let event = notification.object as? StorageService.StorageEvent<Any> else {return}
        guard event.event == .Synced,
              event.entity == .Comments else {return}
        comments = model?.comments.filter({ $0.shouldHide != true }) ?? []
        comments = comments.sorted(by: {$0.createdDateTime ?? Date() < $1.createdDateTime ?? Date()})
        tableView.reloadData()
    }
    
    func style() {
        guard titleLabel != nil else {return}
        titleLabel.font = UIFont.bcSansRegularWithSize(size: 17)
    }
    
    func textChanged(text: String?) {}
    
    func submit(text: String) {
        guard let record = model, let hdid = AuthManager().hdid else {return}
        record.submitComment(text: text, hdid: hdid, completion: { [weak self] result in
            guard let self = self, let commentObject = result else {
                return
            }
            self.comments.append(commentObject)
            self.tableView.reloadData()
            self.scrollToBottom()
            self.resignFirstResponder()
        })
    }
    
    func scrollToBottom() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: { [weak self] in
            let row = (self?.comments.count ?? 0) - 1
            guard row >= 0 else { return }
            let indexPath = IndexPath(row: row, section: 0)
            self?.tableView?.scrollToRow(at: indexPath, at: .bottom, animated: true)
        })
    }
}

extension CommentsViewController: UITableViewDelegate, UITableViewDataSource {
 
    private func setupTableView() {
        guard let tableView = tableView else {
            return
        }
        tableView.register(UINib.init(nibName: CommentViewTableViewCell.getName, bundle: .main), forCellReuseIdentifier: CommentViewTableViewCell.getName)
        tableView.register(UINib.init(nibName: EditCommentTableViewCell.getName, bundle: .main), forCellReuseIdentifier: EditCommentTableViewCell.getName)
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.showsVerticalScrollIndicator = false
        if Device.IS_IPHONE_5 || Device.IS_IPHONE_4 {
            tableView.estimatedRowHeight = 1000
        } else {
            tableView.estimatedRowHeight = 600
        }
        
        tableView.allowsSelection = false
        tableView.separatorStyle = .none
        tableView.separatorInset = .zero
    }
    
    public func commentCell(indexPath: IndexPath, tableView: UITableView) -> CommentViewTableViewCell? {
        return tableView.dequeueReusableCell(withIdentifier: CommentViewTableViewCell.getName, for: indexPath) as? CommentViewTableViewCell
    }
    
    func editCommentCell(indexPath: IndexPath, tableView: UITableView) -> EditCommentTableViewCell? {
        return tableView.dequeueReusableCell(withIdentifier: EditCommentTableViewCell.getName, for: indexPath) as? EditCommentTableViewCell
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let editedIndexPath = indexPathBeingEdited {
            if indexPath == editedIndexPath {
                guard let cell = editCommentCell(indexPath: indexPath, tableView: tableView) else { return UITableViewCell() }
                let comment = comments[editedIndexPath.row]
                cell.configure(comment: comment, delegateOwner: self)
                return cell
            } else {
                guard let cell = commentCell(indexPath: indexPath, tableView: tableView) else {return UITableViewCell()}
                cell.configure(comment: comments[indexPath.row], indexPath: indexPath, delegateOwner: self, showOptionsButton: true, otherCellBeingEdited: true)
                return cell
            }
        } else {
            guard let cell = commentCell(indexPath: indexPath, tableView: tableView) else {return UITableViewCell()}
            cell.configure(comment: comments[indexPath.row], indexPath: indexPath, delegateOwner: self, showOptionsButton: true)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
}

// MARK: Show and hide options drop down menu

extension CommentsViewController: CommentViewTableViewCellDelegate {
    func optionsTapped(indexPath: IndexPath) {
        if let _ = actionSheetController {
            hideOptionsDropDown()
        } else {
            showOptionsDropDown(indexPath: indexPath)
        }
    }

    private func showOptionsDropDown(indexPath: IndexPath) {
        actionSheetController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        actionSheetController?.addAction(UIAlertAction(title: "Edit comment", style: .default, handler: { _ in
            self.indexPathBeingEdited = indexPath
        }))
        
        actionSheetController?.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            self.alert(title: "Delete Comment", message: "This action cannot be undone. Are you sure you want to delete the comment?", buttonOneTitle: .cancel, buttonOneCompletion: {
                self.hideOptionsDropDown()
            }, buttonTwoTitle: .delete) {
                self.indexPathBeingDeleted = indexPath
                self.deleteComment()
            }
        }))
        
        actionSheetController?.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { [self] _ in
            self.hideOptionsDropDown()
        }))
        
        guard let actionSheetController = actionSheetController else { return }
        self.present(actionSheetController, animated: true) {
            actionSheetController.view.superview?.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.dismissActionSheet))
            guard let views = actionSheetController.view.superview?.subviews, views.count > 0 else { return }
            views[0].addGestureRecognizer(tap)
        }
    }

    private func hideOptionsDropDown() {
        actionSheetController?.dismiss(animated: true)
        actionSheetController = nil
        
    }
    
    @objc func dismissActionSheet() {
        hideOptionsDropDown()
    }


}

extension CommentsViewController: UIScrollViewDelegate {
    
    func showTitle() {
        resetUpDebounceTimer()
        resetDownDebounceTimer()
        UIView.animate(withDuration: 0.3, delay: 0.0) {
            self.titleTopConstraint.constant = self.titleVisibleContraint
            self.view.layoutIfNeeded()
        }
    }
    
    func hideTitle() {
        resetUpDebounceTimer()
        resetDownDebounceTimer()
        UIView.animate(withDuration: 0.3, delay: 0.0) {
            self.titleTopConstraint.constant = self.titleHiddenContraint
            self.view.layoutIfNeeded()
        }
    }
    
    func scrollTitle(by amount: CGFloat) {
        if amount > 0 {
            if debounceTitleStrollDownBlock {return}
            guard titleTopConstraint.constant + amount <= self.titleVisibleContraint / 2
            else {return}
            guard titleTopConstraint.constant != titleVisibleContraint
            else {return}
            resetUpDebounceTimer()
            titleTopConstraint.constant += amount
        } else {
            if debounceTitleStrollUpBlock {return}
            guard titleTopConstraint.constant + amount >= self.titleHiddenContraint / 2
            else {return}
            guard titleTopConstraint.constant != titleHiddenContraint
            else {return}
            resetDownDebounceTimer()
            titleTopConstraint.constant += amount
        }
    }
    
    private func resetDownDebounceTimer() {
        debounceTitleStrollDownBlock = true
        debounceTitleStrollDownBlockTimer?.invalidate()
        debounceTitleStrollDownBlockTimer = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(resetDownDebounce), userInfo: nil, repeats: false)
    }
    private func resetUpDebounceTimer() {
        debounceTitleStrollUpBlock = true
        debounceTitleStrollUpBlockTimer?.invalidate()
        debounceTitleStrollUpBlockTimer = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(resetUpDebounce), userInfo: nil, repeats: false)
       
    }
    
    @objc private func resetUpDebounce() {
        debounceTitleStrollUpBlock = false
    }
    @objc private func resetDownDebounce() {
        debounceTitleStrollDownBlock = false
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == tableView {
            let contentOffset = scrollView.contentOffset.y
            
            let change = lastKnowContentOfsset - contentOffset
            if contentOffset == 0 {
                hideTitleAfterScroll = false
            } else if change > 0.0 {
                scrollTitle(by: change)
                hideTitleAfterScroll = false
            } else if change < 0.0 {
                scrollTitle(by: change)
                hideTitleAfterScroll = true
            }
            lastKnowContentOfsset = contentOffset
        }
    }
    
    func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        hideTitleAfterScroll = false
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if hideTitleAfterScroll {
            hideTitle()
        } else {
            showTitle()
        }
    }
}

// MARK: Logic for editing comment
extension CommentsViewController: AppStyleButtonDelegate {
    func buttonTapped(type: AppStyleButton.ButtonType) {
        switch type {
        case .cancel:
            self.indexPathBeingEdited = nil
            self.editedText = nil
        case .update:
            updateComment()
        default: return
        }
    }
    
    private func updateComment() {
        guard let editedText = self.editedText else { return }
        guard let record = model, let hdid = AuthManager().hdid else {return}
        guard let index = indexPathBeingEdited else { return }
        let oldComment = comments[index.row]
        record.updateComment(text: editedText, hdid: hdid, oldComment: oldComment) { [weak self] result in
            guard let self = self, let commentObject = result else {
                return
            }
            self.comments.insert(commentObject, at: index.row)
            if let oldCommentIndex = self.comments.firstIndex(of: oldComment) {
                self.comments.remove(at: oldCommentIndex)
            }
            self.indexPathBeingEdited = nil
            self.resignFirstResponder()
            
        }
    }
    
    private func deleteComment() {
        guard let record = model, let hdid = AuthManager().hdid else {return}
        guard let indexPath = indexPathBeingDeleted else { return }
        let comment = comments[indexPath.row]
        record.deleteComment(comment: comment, hdid: hdid) { [weak self] result in
            guard let self = self, let commentObject = result else {
                return
            }
            self.indexPathBeingDeleted = nil
            self.comments.remove(at: indexPath.row)
            self.tableView.reloadData()
            self.resignFirstResponder()
            
            if self.comments.isEmpty {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
}

// MARK: Delegate For EditCommentTableViewCell
extension CommentsViewController: EditCommentTableViewCellDelegate {
    func newText(string: String) {
        editedText = string
    }
}

