//
//  NotificationsViewController.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2023-05-31.
//

import UIKit


class NotificationsViewController: BaseViewController {
    struct ViewModel {
        let patient: Patient
        let network: Network
        let authManager: AuthManager
        let configService: MobileConfigService
        var service: NotificationService {
            return NotificationService(network: network, authManager: authManager, configService: configService)
        }
    }
    
    class func construct(viewModel: ViewModel) -> NotificationsViewController {
        if let vc = Storyboard.notifications.instantiateViewController(withIdentifier: String(describing: NotificationsViewController.self)) as? NotificationsViewController {
            vc.viewModel = viewModel
            return vc
        }
        return NotificationsViewController()
    }
    
    @IBOutlet weak var tableView: UITableView!
    private let unavailableTag = 21939012
    private let refetchButtonTag = 3401939012
    private let networkManager = AFNetwork()
    private var notifications: [GatewayNotification] = []
    private var viewModel: ViewModel? = nil
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    func fetchData() {
        self.notifications = StorageService.shared.fetchNotifications().filter({ notification in
            guard let scheduledDate = notification.scheduledDate, scheduledDate <= Date() else {
                return false
            }
            return true
        }).sorted(by: {
            $0.scheduledDate ?? Date() > $1.scheduledDate ?? Date()
        })
        
        if notifications.isEmpty || SessionStorage.notificationFethFilure {
            showUnavailable()
            tableView.reloadData()
        } else {
            setupTableView()
            removeUnavailable()
            tableView.reloadData()
        }
        navSetup()
    }
    
    func removeUnavailable() {
        tableView.viewWithTag(unavailableTag)?.removeFromSuperview()
        tableView.viewWithTag(refetchButtonTag)?.removeFromSuperview()
    }
    
    func showUnavailable() {
        removeUnavailable()
        let imageName = SessionStorage.notificationFethFilure ? "NotificationsFailed" : "NotificationsNotAvailable"
        let imageView = UIImageView(frame: tableView.bounds)
        tableView.addSubview(imageView)
        imageView.image = UIImage(named: imageName)
        imageView.contentMode = .scaleAspectFit
        imageView.tag = unavailableTag
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.topAnchor.constraint(equalTo: tableView.topAnchor, constant: 64).isActive = true
        imageView.leadingAnchor.constraint(equalTo: tableView.leadingAnchor, constant: 32).isActive = true
        imageView.centerYAnchor.constraint(equalTo: tableView.centerYAnchor).isActive = true
        imageView.centerXAnchor.constraint(equalTo: tableView.centerXAnchor).isActive = true
        
        if SessionStorage.notificationFethFilure {
            let button = UIButton(frame: .zero)
            button.tag = refetchButtonTag
            tableView.addSubview(button)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -54).isActive = true
            button.leadingAnchor.constraint(equalTo: tableView.leadingAnchor, constant: 32).isActive = true
            button.centerXAnchor.constraint(equalTo: tableView.centerXAnchor).isActive = true
            button.heightAnchor.constraint(equalToConstant: 54).isActive = true
            style(button: button, style: .Fill, title: "Try Again", image: nil)
            button.addTarget(self, action: #selector(self.refetchNotifications), for: .primaryActionTriggered)
            
        }
        
    }
    
    @objc func refetchNotifications() {
        guard let viewModel = self.viewModel else {return}
        guard NetworkConnection.shared.hasConnection else {
            showToast(message: "No internet connection")
            return
        }
        viewModel.service.fetchAndStore(for: viewModel.patient, loadingStyle: .empty, completion: {[weak self] _ in
            self?.fetchData()
        })
    }
    
    @objc func clearNotifications() {
        guard let patient = viewModel?.patient else {return}
        guard NetworkConnection.shared.hasConnection else {
            showToast(message: "No internet connection")
            return
        }
        alertConfirmation(title: "Clear all notifications",
                          message: "Are you sure you want to delete all notifications? You won't be able to access them again after this.",
                          confirmTitle: "Yes",
                          confirmStyle: .default,
                          onConfirm: {
            guard NetworkConnection.shared.hasConnection else {
                self.showToast(message: "No internet connection")
                return
            }
            self.viewModel?.service.dimissAll(for: patient) {[weak self] in
                self?.fetchData()
            }
        }, onCancel: {
            return
        })
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
    
//    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        cell.layoutIfNeeded()
//    }
    
//    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        tableView.beginUpdates()
//        tableView.endUpdates()
//    }
    
}

extension NotificationsViewController: NotificationTableViewCellDelegate {
    func showDetail(notification: GatewayNotification) {
        print(notification)
        guard let actionType = notification.actionTypeEnum else {
            return
        }
        switch actionType {
        case .externalLink:
            guard let link = notification.actionURL else {return}
            showExternalURL(url: link)
        case .internalLink:
            guard let category = notification.category else {
                print("\n\n**CATEGORY NOT FOUND LOCALLY - NEEDS TO BE ADDED\n\n")
                return
            }
            showLocalRoute(category: category)
        case .none:
            return
        }
    }
    
    func showExternalURL(url: String) {
        guard NetworkConnection.shared.hasConnection else {
            showToast(message: "This action requires an internet connection")
            return
        }
        openURLInSafariVC(withURL: url)
    }
    
    func showLocalRoute(category: NotificationCategory) {
        let filterType = category.toLocalFilter()
        if RecordsFilter.RecordType.avaiableFilters.contains(filterType) {
            SessionStorage.notificationCategoryFilter = category
        } else {
            SessionStorage.notificationCategoryFilter = nil
        }
        show(tab: .AuthenticatedRecords)
    }
    
    func remove(notification: GatewayNotification) {
        guard let id = notification.id else {return}
        guard NetworkConnection.shared.hasConnection else {
            showToast(message: "No internet connection")
            return
        }
        let service = NotificationService(network: networkManager, authManager: AuthManager(), configService: MobileConfigService(network: networkManager))
        
        service.dimiss(notification: notification, completion: {[weak self] in
            self?.fetchData()
        })
    }
}


// MARK: Navigation setup
extension NotificationsViewController {
    private func navSetup() {
        var buttons: [NavButton] = []
        
        if !notifications.isEmpty {
            let deleteButton = NavButton(title: nil, image: UIImage(named: "Remove"), action: #selector(self.clearNotifications), accessibility: Accessibility(traits: .button, label: "", hint: ""))
            buttons.append(deleteButton)
        }
        
        
        self.navDelegate?.setNavigationBarWith(title: "Notifications",
                                               leftNavButton: nil,
                                               rightNavButtons: buttons,
                                               navStyle: .small,
                                               navTitleSmallAlignment: .Center,
                                               targetVC: self,
                                               backButtonHintString: nil)
    }
}
