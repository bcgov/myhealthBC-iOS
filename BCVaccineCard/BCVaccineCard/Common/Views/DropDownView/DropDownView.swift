//
//  DropDownView.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-11-02.
//

import UIKit

protocol DropDownViewDelegate: AnyObject {
    func didChooseStoragePHN(details: GatewayStorageProperties)
}

class DropDownView: UIView {
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var roundedView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    private var dataSource: [GatewayStorageProperties]!
    private weak var delegate: DropDownViewDelegate?
    
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
        Bundle.main.loadNibNamed(DropDownView.getName, owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        setup()
    }
    
    private func setup() {
        viewSetup()
    }
    
    private func viewSetup() {
        self.backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        shadowView.backgroundColor = UIColor.clear
        shadowView.layer.shadowColor = UIColor.black.cgColor
        shadowView.layer.shadowOffset = CGSize(width: 2, height: 2)
        shadowView.layer.shadowRadius = 6.0
        
        roundedView.layer.cornerRadius = 3
        roundedView.layer.masksToBounds = true
    }
    
    private func tableViewSetup() {
        tableView.register(UINib.init(nibName: TextTableViewCell.getName, bundle: .main), forCellReuseIdentifier: TextTableViewCell.getName)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = Constants.RememberPHNDropDownRowHeight.height
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func configure(rememberGatewayDetails: RememberedGatewayDetails, delegateOwner: UIViewController) {
        guard let storedData = rememberGatewayDetails.storageArray else {
            self.removeFromSuperview()
            return
        }
        self.dataSource = storedData
        self.delegate = delegateOwner as? DropDownViewDelegate
        tableViewSetup()
    }
}

extension DropDownView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: TextTableViewCell.getName, for: indexPath) as? TextTableViewCell {
            cell.configure(forType: .plainText, text: dataSource[indexPath.row].phn, withFont: UIFont.bcSansRegularWithSize(size: 17), labelSpacingAdjustment: 16)
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let details = dataSource[indexPath.row]
        self.delegate?.didChooseStoragePHN(details: details)
    }

}
