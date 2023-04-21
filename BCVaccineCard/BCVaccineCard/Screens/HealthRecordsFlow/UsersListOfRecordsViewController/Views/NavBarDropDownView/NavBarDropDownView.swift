//
//  CommentsOptionsDropDownView.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2023-04-10.
//

import UIKit

enum NavBarDropDownViewOptions: String, Codable {
    case refresh
    case profile
    
    var getTitle: String {
        return self.rawValue.capitalized
    }
    
    var getImage: UIImage? {
        switch self {
        case .refresh: return UIImage(named: "refresh")
        case .profile: return UIImage(named: "profile-icon")
        }
    }
}

protocol NavBarDropDownViewDelegate: AnyObject {
    func optionSelected()
}

class NavBarDropDownView: UIView {
    
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var tableView: UITableView!
    
    weak var delegate: NavBarDropDownViewDelegate?
    
    var dataSource: [NavBarDropDownViewOptions] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed(NavBarDropDownView.getName, owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        setup()
    }
    
    private func setup() {
        contentView.layer.cornerRadius = 3.0
        contentView.clipsToBounds = true
        setupTableView()
    }
    
    func configure(delegateOwner: UIViewController, dataSource: [NavBarDropDownViewOptions] = []) {
        self.delegate = delegateOwner as? NavBarDropDownViewDelegate
        if dataSource.count > 0 {
            self.dataSource = dataSource
            tableView.reloadData()
        }
    }
    
}

// MARK: Table view logic
extension NavBarDropDownView: UITableViewDelegate, UITableViewDataSource {
    private func setupTableView() {
        dataSource = [.refresh, .profile]
        tableView.register(UINib.init(nibName: NavBarDropDownOptionTableViewCell.getName, bundle: .main), forCellReuseIdentifier: NavBarDropDownOptionTableViewCell.getName)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 50
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NavBarDropDownOptionTableViewCell.getName, for: indexPath) as? NavBarDropDownOptionTableViewCell else { return UITableViewCell() }
//        cell.configure
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        <#code#>
    }
}
