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
    
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var tableView: UITableView!
    @IBOutlet weak private var fieldContainer: UIView!
    
    override func viewDidLoad() {
        self.title = "Comments"
        setup()
    }
    
    func setup() {
        titleLabel.text = "Only you can see comments added to your medical records."
        
        let commentTextField: CommentTextFieldView = CommentTextFieldView.fromNib()
        fieldContainer.addSubview(commentTextField)
        commentTextField.addEqualSizeContraints(to: fieldContainer)
       
        commentTextField.setup()
        commentTextField.delegate = self
        
        comments = model?.comments ?? []
        setupTableView()
        style()
    }
    
    func style() {
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
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: { [weak self] in
                let row = (self?.comments.count ?? 0) - 1
                guard row >= 0 else { return }
                let indexPath = IndexPath(row: row, section: 0)
                self?.tableView?.scrollToRow(at: indexPath, at: .bottom, animated: true)
            })
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
