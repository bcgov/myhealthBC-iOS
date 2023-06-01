//
//  NotificationsViewController.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2023-05-31.
//

import UIKit

class NotificationsViewController: BaseViewController {
    
    class func construct() -> NotificationsViewController {
        if let vc = Storyboard.notifications.instantiateViewController(withIdentifier: String(describing: NotificationsViewController.self)) as? NotificationsViewController {
            return vc
        }
        return NotificationsViewController()
    }
    
    @IBOutlet weak var tableView: UITableView!
    private let unavailableTag = 21939012
    private let networkManager = AFNetwork()
    private var notifications: [GatewayNotification] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navSetup()
        AppStates.shared.listenToNotificationChange { [weak self] in
            self?.fetchData()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fetchData()
    }
    
    func fetchData() {
        self.notifications = StorageService.shared.fetchNotifications()
        
        if notifications.isEmpty {
            showUnavailable()
            tableView.reloadData()
        } else {
            setupTableView()
            removeUnavailable()
        }
    }
    
    func removeUnavailable() {
        tableView.viewWithTag(unavailableTag)?.removeFromSuperview()
    }
    func showUnavailable() {
        removeUnavailable()
        let imageView = UIImageView(frame: tableView.bounds)
        tableView.addSubview(imageView)
        imageView.image = UIImage(named: "NotificationsNotAvailable")
        imageView.contentMode = .scaleAspectFit
        imageView.tag = unavailableTag
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.topAnchor.constraint(equalTo: tableView.topAnchor, constant: 64).isActive = true
        imageView.leadingAnchor.constraint(equalTo: tableView.leadingAnchor, constant: 32).isActive = true
        imageView.centerYAnchor.constraint(equalTo: tableView.centerYAnchor).isActive = true
        imageView.centerXAnchor.constraint(equalTo: tableView.centerXAnchor).isActive = true
    }
    
    @objc func clearNotifications() {
    }
}

extension NotificationsViewController: UITableViewDelegate, UITableViewDataSource {
    
    private func setupTableView() {
        tableView.register(UINib.init(nibName: NotificationTableViewCell.getName, bundle: .main), forCellReuseIdentifier: NotificationTableViewCell.getName)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.delegate = self
        tableView.dataSource = self
    }
    private func notificationCell(indexPath: IndexPath) -> NotificationTableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: NotificationTableViewCell.getName, for: indexPath) as? NotificationTableViewCell else {
            return NotificationTableViewCell()
        }
        cell.setup(notification: notifications[indexPath.row], delegate: self)
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = notificationCell(indexPath: indexPath)
        return cell
    }
    
}

extension NotificationsViewController: NotificationTableViewCellDelegate {
    func remove(notification: GatewayNotification) {
        guard let id = notification.id else {return}
        let service = NotificationService(network: networkManager, authManager: AuthManager(), configService: MobileConfigService(network: networkManager))
        
        service.dimiss(id: id, completion: {[weak self] in
            self?.fetchData()
        })
    }
}


// MARK: Navigation setup
extension NotificationsViewController {
    private func navSetup() {
        var buttons: [NavButton] = []
        
        let deleteButton = NavButton(title: nil, image: UIImage(named: "Remove"), action: #selector(self.clearNotifications), accessibility: Accessibility(traits: .button, label: "", hint: ""))
        buttons.append(deleteButton)
        
        
        self.navDelegate?.setNavigationBarWith(title: "Notifications",
                                               leftNavButton: nil,
                                               rightNavButtons: buttons,
                                               navStyle: .small,
                                               navTitleSmallAlignment: .Center,
                                               targetVC: self,
                                               backButtonHintString: nil)
    }
}
