//
//  RecommendationsViewController.swift
//  HealthGatewayTest
//
//  Created by Amir Shayegh on 2022-08-23.
//

import UIKit

class RecommendationsViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var tableView: UITableView!
    
    private var recommendations: [ImmunizationRecommendation] = []
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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        recommendations = StorageService.shared.fetchRecommendations()
        guard let tableView = tableView else {return}
        tableView.reloadData()
    }
    
    func setup() {
        title = "Recommended immunizations"
        
        setupTableView()
    }
    
    private func setupTextView() {
        
    }

}
extension RecommendationsViewController: UITextViewDelegate {
//ReccomandationTableViewCell
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
