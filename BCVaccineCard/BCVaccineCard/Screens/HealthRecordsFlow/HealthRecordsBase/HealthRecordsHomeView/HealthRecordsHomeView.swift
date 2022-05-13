//
//  HealthRecordsHomeView.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2022-05-06.
//

import UIKit

class HealthRecordsHomeView: UIView {
    
    @IBOutlet weak private var contentView: UIView!
    @IBOutlet weak private var introTextLabel: UILabel!
    @IBOutlet weak private var recordsImageView: UIImageView!
    @IBOutlet weak private var loginWithBCServiceCardButton: AppStyleButton!
        
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
        Bundle.main.loadNibNamed(HealthRecordsHomeView.getName, owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        setup()
    }
    
    private func setup() {
        self.backgroundColor = .clear
        setupUI()
    }
    
    private func setupUI() {
        introTextLabel.font = UIFont.bcSansRegularWithSize(size: 17)
        introTextLabel.textColor = AppColours.textBlack
        introTextLabel.text = "Log in with your BC Service Card to view, manage all the health records." // TODO: Put in strings file
        recordsImageView.image = UIImage(named: "health-records-home-image")
    }
    
    func configure(buttonDelegateOwner: UIViewController) {
        loginWithBCServiceCardButton.configure(withStyle: .blue, buttonType: .login, delegateOwner: buttonDelegateOwner, enabled: true)
    }
}
