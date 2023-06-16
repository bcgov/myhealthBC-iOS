//
//  NotificationTableViewCell.swift
//  HealthGatewayTest
//
//  Created by Amir Shayegh on 2023-05-31.
//

import UIKit

protocol NotificationTableViewCellDelegate {
    func remove(notification: GatewayNotification)
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
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction func dismiss(_ sender: Any) {
        guard let notification = self.notification,
              let delegate = self.delegate
        else {
            return
        }
        delegate.remove(notification: notification)
    }
    
    func setup(notification: GatewayNotification, delegate: NotificationTableViewCellDelegate) {
        self.notification = notification
        self.delegate = delegate
        fillData()
        style()
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
                detailsLabel.alpha = 1
                detailsLabelHeight.constant = 24
                let text = NSAttributedString(string: "More information", attributes:
                    [.underlineStyle: NSUnderlineStyle.single.rawValue])
                detailsLabel.attributedText = text
            case .internalLink:
                detailsLabel.alpha = 1
                detailsLabelHeight.constant = 24
                let text = NSAttributedString(string: "View details", attributes:
                    [.underlineStyle: NSUnderlineStyle.single.rawValue])
                detailsLabel.attributedText = text
            case .none:
                detailsLabelHeight.constant = 0
                detailsLabel.alpha = 0
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
    }
}
