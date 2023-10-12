//
//  ImmunizationScheduleViewController.swift
//  HealthGatewayTest
//
//  Created by Amir Shayegh on 2023-06-26.
//
// FIXME: NEED TO LOCALIZE 
import UIKit

class ImmunizationScheduleViewController: BaseViewController {
    class func construct() -> ImmunizationScheduleViewController {
        if let vc = Storyboard.immunizationSchedule.instantiateViewController(withIdentifier: String(describing: ImmunizationScheduleViewController.self)) as? ImmunizationScheduleViewController {
            return vc
        }
        return ImmunizationScheduleViewController()
    }
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        style()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func style() {
        navigationItem.title = "Immunization Schedules"
        navigationItem.largeTitleDisplayMode = .never
        descriptionLabel.font = UIFont.bcSansRegularWithSize(size: 13)
        descriptionLabel.textColor = UIColor(red: 0.38, green: 0.38, blue: 0.38, alpha: 1)
    }

}

extension ImmunizationScheduleViewController: UITableViewDelegate, UITableViewDataSource {
    
    private func setupTableView() {
        tableView.register(UINib.init(nibName: ImmunizationScheduleTableViewCell.getName, bundle: .main), forCellReuseIdentifier: ImmunizationScheduleTableViewCell.getName)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func getCell(indexPath: IndexPath) -> ImmunizationScheduleTableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: ImmunizationScheduleTableViewCell.getName, for: indexPath) as? ImmunizationScheduleTableViewCell else {
            return ImmunizationScheduleTableViewCell()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ScheduleType.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let type = ScheduleType.init(rawValue: indexPath.row) else {return UITableViewCell()}
        let cell = getCell(indexPath: indexPath)
        cell.setup(type: type, delegate: self)
        return cell
    }
}

extension ImmunizationScheduleViewController: ImmunizationScheduleTableViewCellDelegate {

    enum ScheduleType: Int, CaseIterable {
        case Infant = 0
        case SchoolAge
        case Adults
    }
    
    func tapped(type: ScheduleType) {
        openURLInSafariVC(withURL: type.url())
    }
    
    
}

extension ImmunizationScheduleViewController.ScheduleType {
    func url()-> String {
        switch self {
        case .Infant:
            return "https://www.healthlinkbc.ca/bc-immunization-schedules#child"
        case .SchoolAge:
            return "https://www.healthlinkbc.ca/bc-immunization-schedules#school"
        case .Adults:
            return "https://www.healthlinkbc.ca/bc-immunization-schedules#adult"
        }
    }
    
    func title()-> String {
        switch self {
        case .Infant:
            return "Infant and children"
        case .SchoolAge:
            return "School age children"
        case .Adults:
            return "Adult, seniors and individual with high risk"
        }
    }
    
    func imageName()-> String {
        switch self {
        case .Infant:
            return "infant-schedule"
        case .SchoolAge:
            return "schoolage-schedule"
        case .Adults:
            return "adult-schedule"
        }
    }
}
