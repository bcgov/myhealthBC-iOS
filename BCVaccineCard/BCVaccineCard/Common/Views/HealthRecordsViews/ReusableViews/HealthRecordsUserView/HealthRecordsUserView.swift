//
//  HealthRecordsUserView.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-11-26.
// https://www.figma.com/file/ga1F6q5Kvi6CD6FLS27fXq/My-Health-BC?node-id=3275%3A42476
// This is just the text component

import UIKit

class HealthRecordsUserView: UIView {
    
    static let nameFont = UIFont.bcSansBoldWithSize(size: 17)
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var backgroundWhiteView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var recordCountLabel: UILabel!
    @IBOutlet weak var recordIconImageView: UIImageView!
    
    
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
        Bundle.main.loadNibNamed(HealthRecordsUserView.getName, owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        setup()
    }
    
    private func setup() {
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        uiSetup()
    }
    
    private func uiSetup() {
        backgroundWhiteView.layer.masksToBounds = true
        backgroundWhiteView.layer.borderWidth = 1
        backgroundWhiteView.layer.borderColor = AppColours.borderGray.cgColor
        backgroundWhiteView.layer.cornerRadius = Constants.UI.Theme.cornerRadiusRegular
        nameLabel.font = HealthRecordsUserView.nameFont
        nameLabel.textColor = AppColours.appBlue
        recordCountLabel.font = UIFont.bcSansRegularWithSize(size: 13)
        recordCountLabel.textColor = AppColours.textBlack
        recordIconImageView.image = UIImage(named: "vaccine-record-icon")
    }
    
    func styleAuthStatus(authenticated: Bool) {
        if !authenticated {return}
        let bcscLogo = UIImage(named: "bcscLogo")
        recordIconImageView.image = bcscLogo
        let isAuthenticated = AuthManager().isAuthenticated
        recordIconImageView.alpha = isAuthenticated ? 1 : 0.3
        if !isAuthenticated {return}
        Notification.Name.refreshTokenExpired.onPost(object: nil, queue: .main) {[weak self] _ in
            guard let `self` = self else {return}
            self.recordIconImageView.alpha = 0.3
        }
    }
    
    func configure(name: String, records: Int, authenticated: Bool) {
        setupAccessibility()
        // NOTE: This is for weird logic where we word wrap, unless there is a name that is really long and hyphenated (so, going to make assumptions here)
        let numberOfSpaces = name.reduce(0) { $1 == " " ? $0 + 1 : $0 }
        nameLabel.lineBreakMode = name.count >= 20 && numberOfSpaces <= 1 ? .byTruncatingTail : .byWordWrapping
        nameLabel.text = name
        var recordText = "\(records) " + .recordText
        if records != 1 {
            recordText.append("s")
        }
        recordCountLabel.text = recordText
        styleAuthStatus(authenticated: authenticated)
    }
    
    // TODO: Setup accessibility
    private func setupAccessibility() {
        self.isAccessibilityElement = true
        let accessibilityLabel = ""
        self.accessibilityLabel = accessibilityLabel
//        let accessibilityValue = expanded ? "\(model.codableModel.name), \(model.codableModel.status.getTitle), \(model.getFormattedIssueDate()), \(AccessibilityLabels.VaccineCardView.qrCodeImage)" : "\(model.codableModel.name), \(model.codableModel.status.getTitle)"
//        self.accessibilityValue = accessibilityValue
        self.accessibilityHint = ""
    }
}
