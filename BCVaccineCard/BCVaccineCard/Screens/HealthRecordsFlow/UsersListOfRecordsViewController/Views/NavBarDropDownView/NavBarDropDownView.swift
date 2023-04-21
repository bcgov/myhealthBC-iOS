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
    case settings
    
    var getTitle: String {
        return self.rawValue.capitalized
    }
    
    var getImage: UIImage? {
        switch self {
        case .refresh: return UIImage(named: "refresh")
        case .profile: return UIImage(named: "profile-icon")
        case .settings: return UIImage(named: "nav-settings")
        }
    }
}

protocol NavBarDropDownViewDelegate: AnyObject {
    func optionSelected(_ option: NavBarDropDownViewOptions)
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
        contentView.layer.cornerRadius = 5.0
        contentView.clipsToBounds = true
        setupTableView()
    }
    
    private func configure(delegateOwner: UIViewController, dataSource: [NavBarDropDownViewOptions]) {
        self.delegate = delegateOwner as? NavBarDropDownViewDelegate
        self.dataSource = dataSource
        self.tableView.reloadData()
    }
    
    func addView(delegateOwner: UIViewController, dataSource: [NavBarDropDownViewOptions], parentView: UIView) {
        parentView.addSubview(self)
        
        let heightInt = (49 * dataSource.count) + (dataSource.count - 1)
        let height = CGFloat(heightInt)
        let width: CGFloat = 208
        
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: width).isActive = true
        NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: height).isActive = true
        self.topAnchor.constraint(equalTo: parentView.safeAreaLayoutGuide.topAnchor).isActive = true
        self.rightAnchor.constraint(equalTo: parentView.rightAnchor, constant: -20).isActive = true
        
        configure(delegateOwner: delegateOwner, dataSource: dataSource)
    }
    
    func removeView() {
        self.removeFromSuperview()
    }
    
}

// MARK: Table view logic
extension NavBarDropDownView: UITableViewDelegate, UITableViewDataSource {
    private func setupTableView() {
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NavBarDropDownOptionTableViewCell.getName, for: indexPath) as? NavBarDropDownOptionTableViewCell, dataSource.count > indexPath.row else { return UITableViewCell() }
        let option = dataSource[indexPath.row]
        cell.configure(option: option, dataSourceCount: dataSource.count, positionInDropDown: indexPath.row)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard dataSource.count > indexPath.row else { return }
        let option = dataSource[indexPath.row]
        delegate?.optionSelected(option)
    }
}
