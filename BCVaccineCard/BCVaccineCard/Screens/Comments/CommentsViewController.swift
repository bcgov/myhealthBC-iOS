//
//  CommentsViewController.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2022-10-04.
//

import Foundation
import UIKit

class CommentsViewController: UIViewController, CommentTextFieldViewDelegate {
    
    class func constructCommentsViewController(model: HealthRecordsDetailDataSource.Record) -> CommentsViewController {
        if let vc = Storyboard.comments.instantiateViewController(withIdentifier: String(describing: CommentsViewController.self)) as? CommentsViewController {
            vc.model = model
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
    
    override func viewDidLoad() {
        self.title = "Comments"
        setup()
    }
    
    func setup() {
        guard titleLabel != nil else {return}
        titleLabel.text = titleText
        
        let commentTextField: CommentTextFieldView = CommentTextFieldView.fromNib()
        fieldContainer.addSubview(commentTextField)
        commentTextField.addEqualSizeContraints(to: fieldContainer)
       
        commentTextField.setup()
        commentTextField.delegate = self
        
        comments = model?.comments ?? []
        comments = comments.sorted(by: {$0.createdDateTime ?? Date() < $1.createdDateTime ?? Date()})
        setupTableView()
        style()
        scrollToBottom()
        
    }
    
    func listenToSync() {
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.addObserver(self, selector: #selector(storageChangeEvent), name: .storageChangeEvent, object: nil)
    }
        
    @objc private func storageChangeEvent(_ notification: Notification) {
        guard let event = notification.object as? StorageService.StorageEvent<Any> else {return}
        guard event.event == .Synced,
              event.entity == .Comments else {return}
        comments = model?.comments ?? []
        comments = comments.sorted(by: {$0.createdDateTime ?? Date() < $1.createdDateTime ?? Date()})
        tableView.reloadData()
    }
    
    func style() {
        guard titleLabel != nil else {return}
        titleLabel.font = UIFont.bcSansRegularWithSize(size: 17)
//        showTitle()
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = commentCell(indexPath: indexPath, tableView: tableView) else {return UITableViewCell()}
        cell.configure(comment: comments[indexPath.row])
        return cell

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
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
