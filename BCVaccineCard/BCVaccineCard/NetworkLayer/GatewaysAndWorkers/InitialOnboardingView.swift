//
//  InitialOnboardingView.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-10-11.
//

import UIKit

class InitialOnboardingView: UIView {
    
    enum ScreenNumber {
        case one, two, three
        
        var getRotatingImage: UIImage? {
            switch self {
            case .one:
                return UIImage(named: "bubble-one")
            case .two:
                return UIImage(named: "bubble-two")
            case .three:
                return UIImage(named: "bubble-three")
            }
        }
        
        var getTitle: String {
            switch self {
            case .one:
                return .healthPasses
            case .two:
                return .healthResource
            case .three:
                return .newsFeed
            }
        }
        
        var getDescription: String {
            switch self {
            case .one:
                return .initialOnboardingOneDescription
            case .two:
                return .initialOnboardingTwoDescription
            case .three:
                return .initialOnboardingThreeDescription
            }
        }
        
        var getSelectedImageIndex: Int {
            switch self {
            case .one:
                return 0
            case .two:
                return 1
            case .three:
                return 2
            }
        }
    }
    
    @IBOutlet weak private var contentView: UIView!
    @IBOutlet weak private var phoneImageView: UIImageView!
    @IBOutlet private var phoneImageDotsCollection: [UIImageView]!
    @IBOutlet weak private var onboardingTitleLabel: UILabel!
    @IBOutlet weak private var onboardingDescriptionLabel: UILabel!
    @IBOutlet private var screenProgressImageDotsCollection: [UIImageView]!
    @IBOutlet private var screenProgressImageDotsWidthConstraintCollection: [NSLayoutConstraint]!
    @IBOutlet weak private var bottomButton: AppStyleButton!
    
    private var rotatingImageView: UIImageView?
    private var rotatingImageViewConstraints: [NSLayoutConstraint]?
        
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
        Bundle.main.loadNibNamed(InitialOnboardingView.getName, owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        setup()
    }
    
    private func setup() {
        self.backgroundColor = .clear
        labelSetup()
        createInitialRotatingImageView()
    }
    
    private func labelSetup() {
        onboardingTitleLabel.font = UIFont.bcSansRegularWithSize(size: 24)
        onboardingTitleLabel.textColor = AppColours.appBlue
        onboardingDescriptionLabel.font = UIFont.bcSansRegularWithSize(size: 17)
        onboardingDescriptionLabel.textColor = AppColours.textBlack
    }
    
    private func createInitialRotatingImageView() {
        self.rotatingImageView = UIImageView()
        guard let rotatingImageView = rotatingImageView else { return }
        self.contentView.addSubview(rotatingImageView)
        rotatingImageView.translatesAutoresizingMaskIntoConstraints = false
        let widthConstraint = rotatingImageView.widthAnchor.constraint(equalToConstant: 124)
        let heightConstraint = rotatingImageView.heightAnchor.constraint(equalToConstant: 107)
        contentView.addConstraints([widthConstraint, heightConstraint])
    }
    
    private func adjustRotatingImageViewConstraints(screenNumber: ScreenNumber) {
        
    }
    
    private func getNewConstraintsArray(screenNumber: ScreenNumber) {
        guard let imageView = self.rotatingImageView else { return }
        
        switch screenNumber {
        case .one:
            let relativeView: UIImageView = phoneImageDotsCollection[0]
            let relatedImageYReference: NSLayoutAnchor<NSLayoutYAxisAnchor> = relativeView.centerYAnchor
            let verticalConstraint = imageView.centerYAnchor.constraint(equalTo: relatedImageYReference)
            let relatedImageLeadingReference: NSLayoutAnchor<NSLayoutXAxisAnchor> = relativeView.centerXAnchor
            let leadingConstraint = imageView.leadingAnchor.constraint(equalTo: relatedImageLeadingReference)
            self.rotatingImageViewConstraints = [verticalConstraint, leadingConstraint]
            contentView.addConstraints([verticalConstraint, leadingConstraint])
        case .two:
            if let constraintsToRemove = self.rotatingImageViewConstraints {
                contentView.removeConstraints(constraintsToRemove)
            }
            let relativeView: UIImageView = phoneImageDotsCollection[1]
            let relatedImageXReference: NSLayoutAnchor<NSLayoutXAxisAnchor> = relativeView.centerXAnchor
            let horizontalConstraint = imageView.centerXAnchor.constraint(equalTo: relatedImageXReference)
            let relatedImageYReference: NSLayoutAnchor<NSLayoutYAxisAnchor> = relativeView.topAnchor
            let bottomConstraint = imageView.bottomAnchor.constraint(equalTo: relatedImageYReference, constant: 9)
            self.rotatingImageViewConstraints = [horizontalConstraint, bottomConstraint]
            contentView.addConstraints([horizontalConstraint, bottomConstraint])
        case .three:
            if let constraintsToRemove = self.rotatingImageViewConstraints {
                contentView.removeConstraints(constraintsToRemove)
            }
            let relativeView: UIImageView = phoneImageDotsCollection[2]
            let relatedImageYReference: NSLayoutAnchor<NSLayoutYAxisAnchor> = relativeView.centerYAnchor
            let verticalConstraint = imageView.centerYAnchor.constraint(equalTo: relatedImageYReference)
            let relatedImageTrailingReference: NSLayoutAnchor<NSLayoutXAxisAnchor> = relativeView.centerXAnchor
            let trailingConstraint = imageView.trailingAnchor.constraint(equalTo: relatedImageTrailingReference)
            self.rotatingImageViewConstraints = [verticalConstraint, trailingConstraint]
            contentView.addConstraints([verticalConstraint, trailingConstraint])
        }
    }
    
    private func adjustImageDotsCollection(screenNumber: ScreenNumber) {
        // LEFT OFF HERE...
    }
    
    private func adjustBottomButton(screenNumber: ScreenNumber, delegateOwner: UIViewController) {
        let buttonType: AppStyleButton.ButtonType
        let accessibilityValue: String = "To do later"
        let accessibilityHint: String = "To do value later"
        switch screenNumber {
        case .one:
            buttonType = .next
        case .two:
            buttonType = .next
        case .three:
            buttonType = .getStarted
        }
        bottomButton.configure(withStyle: .blue, buttonType: buttonType, delegateOwner: delegateOwner, enabled: true, accessibilityValue: accessibilityValue, accessibilityHint: accessibilityHint)
    }
    
    func configure(screenNumber: ScreenNumber, delegateOwner: UIViewController) {
        
    }
}
