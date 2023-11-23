//
//  NotificationTableViewCell.swift
//  HealthGatewayTest
//
//  Created by Amir Shayegh on 2023-05-31.
//
// FIXME: NEED TO LOCALIZE 
import UIKit

protocol NotificationTableViewCellDelegate {
    func remove(notification: GatewayNotification)
    func showDetail(notification: GatewayNotification)
}

class NotificationTableViewCell: UITableViewCell {
    
    var delegate: NotificationTableViewCellDelegate?
    var notification: GatewayNotification?
    
    @IBOutlet weak var detailsLabelHeight: NSLayoutConstraint!
    @IBOutlet weak var messageContainer: UIView!
    @IBOutlet weak var detailsLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet private weak var topMarginConstraint: NSLayoutConstraint!
    @IBOutlet private weak var bottomMarginConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    @IBAction func dismiss(_ sender: Any) {
        guard let notification = self.notification,
              let delegate = self.delegate
        else {
            return
        }
        delegate.remove(notification: notification)
    }
    
    @objc func showDetailsAction() {
        guard let notification = self.notification,
              let delegate = self.delegate
        else {
            return
        }
        delegate.showDetail(notification: notification)
    }
    
    private func setupUI() {
        style()
        layoutIfNeeded()
    }
    
    func setup(notification: GatewayNotification, delegate: NotificationTableViewCellDelegate) {
        self.notification = notification
        self.delegate = delegate
        fillData()
//        style()
        layoutIfNeeded()
    }
    
    func fillData() {
        guard let notification = self.notification else {
            return
        }
        messageLabel.text = notification.displayText
        timeLabel.text = notification.scheduledDate?.notificationDisplayDate
        if let type = notification.actionTypeEnum {
            switch type {
            case .externalLink:
                detailsLabel.isHidden = false
                let text = NSAttributedString(string: "More information", attributes:
                                                [.underlineStyle: NSUnderlineStyle.single.rawValue])
                detailsLabel.attributedText = text
            case .internalLink:
                detailsLabel.isHidden = false
                let text = NSAttributedString(string: "View details", attributes:
                                                [.underlineStyle: NSUnderlineStyle.single.rawValue])
                detailsLabel.attributedText = text
            case .none:
                detailsLabel.isHidden = true
            }
        }
    }
    
    func style() {
        messageLabel.textColor = UIColor(red: 0.192, green: 0.192, blue: 0.196, alpha: 1)
        messageLabel.font = UIFont.bcSansRegularWithSize(size: 17)
        timeLabel.font = UIFont.bcSansRegularWithSize(size: 13)
        timeLabel.textColor = UIColor(red: 0.376, green: 0.376, blue: 0.376, alpha: 1)
        detailsLabel.textColor = AppColours.appBlue
        detailsLabel.font = UIFont.bcSansRegularWithSize(size: 15)
        messageContainer.layer.cornerRadius = 3
        messageContainer.backgroundColor = UIColor(red: 0.969, green: 0.969, blue: 0.969, alpha: 1)
        let getstureRecognizer = UITapGestureRecognizer(target: self, action: #selector(showDetailsAction))
        detailsLabel.isUserInteractionEnabled = true
        detailsLabel.addGestureRecognizer(getstureRecognizer)
        let isIpad = Constants.deviceType == .iPad
        bottomMarginConstraint.constant = isIpad ? 16 : 8
        topMarginConstraint.constant = isIpad ? 16 : 8
    }
}
