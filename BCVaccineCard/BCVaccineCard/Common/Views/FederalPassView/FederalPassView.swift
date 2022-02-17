//
//  FederalPassView.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-11-03.
//

import UIKit

protocol FederalPassViewDelegate: AnyObject {
    func federalPassButtonTapped(model: AppVaccinePassportModel?)
}

class FederalPassView: UIView {
    
    @IBOutlet weak private var contentView: UIView!
    @IBOutlet weak private var canadaLogo: UIImageView!
    @IBOutlet weak private var passTitleLabel: UILabel!
    @IBOutlet weak private var passSubtitleLabel: UILabel!
    @IBOutlet weak private var rightIconImageView: UIImageView!
    @IBOutlet weak private var rightIconImageViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak private var passButtonForAction: UIButton!
    
    weak var delegate: FederalPassViewDelegate?
    private var model: AppVaccinePassportModel?
    
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
        Bundle.main.loadNibNamed(FederalPassView.getName, owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        setup()
    }
    
    private func setup() {
        self.backgroundColor = .clear
        labelSetup()
        elementAccessibilityDistinction()
    }
    
    private func labelSetup() {
        passTitleLabel.textColor = AppColours.textBlack
        passTitleLabel.font = UIFont.bcSansBoldWithSize(size: 15)
        passSubtitleLabel.textColor = AppColours.textBlack
        passSubtitleLabel.font = UIFont.bcSansRegularWithSize(size: 13)
    }
    
    private func elementAccessibilityDistinction() {
        canadaLogo.isAccessibilityElement = false
        passTitleLabel.isAccessibilityElement = false
        passSubtitleLabel.isAccessibilityElement = false
        rightIconImageView.isAccessibilityElement = false
        passButtonForAction.isAccessibilityElement = true
    }
    
    private func setupAccessibility(model: AppVaccinePassportModel) {
        self.passButtonForAction.accessibilityLabel = AccessibilityLabels.FederalPassView.fedPassDescriptionDoesNotHavePass
        self.accessibilityHint = model.codableModel.fedCode != nil ? AccessibilityLabels.FederalPassView.hasPassHint : AccessibilityLabels.FederalPassView.noPassHint
    }
    
    func configure(model: AppVaccinePassportModel, delegateOwner: UIViewController) {
        self.isAccessibilityElement = false
        self.model = model
        passTitleLabel.text = model.codableModel.fedCode != nil ? .showFederalProof : .getFederalProof
        passSubtitleLabel.text = .federalProofSubtitle
        let image = model.codableModel.fedCode != nil ? UIImage(named: "arrow-right-black") : UIImage(named: "add-icon-black")
        rightIconImageView.image = image
        rightIconImageViewWidthConstraint.constant = model.codableModel.fedCode != nil ? 20.0 : 32.0
        setupAccessibility(model: model)
        self.delegate = delegateOwner as? FederalPassViewDelegate
    }
    
    @IBAction func fedPassButtonTapped(_ sender: UIButton) {
        self.delegate?.federalPassButtonTapped(model: model)
    }
}
