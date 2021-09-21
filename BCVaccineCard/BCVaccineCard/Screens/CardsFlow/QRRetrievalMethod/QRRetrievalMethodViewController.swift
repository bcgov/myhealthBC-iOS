//
//  QRRetrievalMethodViewController.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-09-16.
//

import UIKit

class QRRetrievalMethodViewController: BaseViewController {
    
    class func constructQRRetrievalMethodViewController() -> QRRetrievalMethodViewController {
        if let vc = Storyboard.main.instantiateViewController(withIdentifier: String(describing: QRRetrievalMethodViewController.self)) as? QRRetrievalMethodViewController {
            return vc
        }
        return QRRetrievalMethodViewController()
    }
    
    enum CellType {
        case text(text: String), method(type: QRRetrievalMethod)
    }
    
    @IBOutlet weak private var tableView: UITableView!
    private var dataSource: [CellType] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup() {
        navSetup()
        setupDataSource()
        setupTableView()
    }

}

// MARK: Navigation setup
extension QRRetrievalMethodViewController {
    private func navSetup() {
        self.navDelegate?.setNavigationBarWith(title: Constants.Strings.MyCardFlow.navHeader, andImage: UIImage(named: "close-icon"), action: #selector(self.closeButtonAction))
    }
    
    @objc private func closeButtonAction() {
        dismissMethodSelectionScreen()
    }
    
    private func dismissMethodSelectionScreen() {
        self.navigationController?.popViewController(animated: true)
    }
}

// MARK: Data Source Setup
extension QRRetrievalMethodViewController {
    private func setupDataSource() {
        self.dataSource = [
            .text(text: Constants.Strings.MyCardFlow.QRMethodSelection.description),
            .method(type: .scanWithCamera),
            .method(type: .uploadImage),
            .method(type: .enterGatewayInfo)
        ]
    }
}

// MARK: Table View Logic
extension QRRetrievalMethodViewController: UITableViewDelegate, UITableViewDataSource {
    private func setupTableView() {
        tableView.register(UINib.init(nibName: TextTableViewCell.getName, bundle: .main), forCellReuseIdentifier: TextTableViewCell.getName)
        tableView.register(UINib.init(nibName: QRSelectionTableViewCell.getName, bundle: .main), forCellReuseIdentifier: QRSelectionTableViewCell.getName)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = dataSource[indexPath.row]
        switch data {
        case .text(text: let text):
            if let cell = tableView.dequeueReusableCell(withIdentifier: TextTableViewCell.getName, for: indexPath) as? TextTableViewCell {
                cell.configure(forType: .plainText, text: text, withFont: UIFont.bcSansRegularWithSize(size: 16))
                return cell
            }
        case .method(type: let type):
            if let cell = tableView.dequeueReusableCell(withIdentifier: QRSelectionTableViewCell.getName, for: indexPath) as? QRSelectionTableViewCell {
                cell.configure(method: type, delegateOwner: self)
                return cell
            }
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = dataSource[indexPath.row]
        switch item {
        case .text: return
        case .method(type: let type):
            if let cell = tableView.cellForRow(at: indexPath) as? QRSelectionTableViewCell {
                cell.callDelegate(fromMethod: type)
            }
        }
    }
}

extension QRRetrievalMethodViewController: GoToQRRetrievalMethodDelegate {
    func goToEnterGateway() {
        let vc = GatewayFormViewController.constructGatewayFormViewController()
//        self.navigationController?.pushViewController(vc, animated: true)
        self.present(vc, animated: true, completion: nil)
    }
    
    func goToCameraScan() {
        print("Go to camera scan")
    }
    
    func goToUploadImage() {
        print("Go to upload image")
    }

}
