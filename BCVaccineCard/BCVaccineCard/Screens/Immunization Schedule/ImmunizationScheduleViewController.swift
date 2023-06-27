//
//  ImmunizationScheduleViewController.swift
//  HealthGatewayTest
//
//  Created by Amir Shayegh on 2023-06-26.
//

import UIKit

class ImmunizationScheduleViewController: UIViewController {
    class func construct() -> ImmunizationScheduleViewController {
        if let vc = Storyboard.immunizationSchedule.instantiateViewController(withIdentifier: String(describing: ImmunizationScheduleViewController.self)) as? ImmunizationScheduleViewController {
            return vc
        }
        return ImmunizationScheduleViewController()
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
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
        let cell = getCell(indexPath: indexPath)
        return cell
    }
}

extension ImmunizationScheduleViewController {
    enum ScheduleType: Int, CaseIterable {
        case Infant = 0
        case SchoolAge
        case Adults
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
