//
//  CommentsListView.swift
//  BCVaccineCard
//
//  Created by Amir on 2022-03-03.
//

import UIKit

class CommentsListView: UIView {

    @IBOutlet weak var tableView: UITableView!
    
    var comments: [Comment] = []
    
    func configure(comments: [Comment]) {
        self.comments = comments
        setupTableView()
    }
}

extension CommentsListView: UITableViewDelegate, UITableViewDataSource {
    private func setupTableView() {
        
        tableView.register(UINib.init(nibName: CommentsViewTableViewCell.getName, bundle: .main), forCellReuseIdentifier: CommentsViewTableViewCell.getName)
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func getCell(indexPath: IndexPath) -> CommentsViewTableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CommentsViewTableViewCell.getName, for: indexPath) as? CommentsViewTableViewCell else {
            return CommentsViewTableViewCell()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = getCell(indexPath: indexPath)
        cell.configure(comment: comments[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? FormTableViewCell {
            cell.formTextFieldView.openKeyboardAction()
        }
    }

}

