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
                return .healthResources
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
        
        func increment() -> ScreenNumber? {
            switch self {
            case .one:
                return .two
            case .two:
                return .three
            case .three:
                return nil
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
    @IBOutlet weak private var bottomButtonWidthConstraint: NSLayoutConstraint!
    
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
        onboardingTitleLabel.font = UIFont.bcSansBoldWithSize(size: 24)
        onboardingTitleLabel.textColor = AppColours.appBlue
        onboardingDescriptionLabel.font = UIFont.bcSansRegularWithSize(size: 17)
        onboardingDescriptionLabel.textColor = AppColours.textBlack
    }
    
    private func createInitialRotatingImageView() {
        self.rotatingImageView = UIImageView()
        guard let rotatingImageView = rotatingImageView else { return }
        self.contentView.addSubview(rotatingImageView)
        rotatingImageView.translatesAutoresizingMaskIntoConstraints = false
//        let widthConstraint = rotatingImageView.widthAnchor.constraint(equalToConstant: 124)
//        let heightConstraint = rotatingImageView.heightAnchor.constraint(equalToConstant: 107)
//        contentView.addConstraints([widthConstraint, heightConstraint])
    }
    
    func initialConfigure(screenNumber: ScreenNumber, delegateOwner: UIViewController) {
        commonConfigurationAndUpdates(screenNumber: screenNumber, delegateOwner: delegateOwner)
    }
    
    func adjustUI(screenNumber: ScreenNumber, delegateOwner: UIViewController) {
        adjustPhoneImageDots(screenNumber: screenNumber)
        adjustProgressImageDotsUI(screenNumber: screenNumber)
        commonConfigurationAndUpdates(screenNumber: screenNumber, delegateOwner: delegateOwner)
    }
    
    private func commonConfigurationAndUpdates(screenNumber: ScreenNumber, delegateOwner: UIViewController) {
        adjustText(screenNumber: screenNumber)
        adjustRotatingImageViewConstraints(screenNumber: screenNumber)
        updateRotatingImage(screenNumber: screenNumber)
        adjustBottomButton(screenNumber: screenNumber, delegateOwner: delegateOwner)
        self.contentView.layoutIfNeeded()
    }
}

// MARK: Adjusting functions
extension InitialOnboardingView {
    
    private func adjustPhoneImageDots(screenNumber: ScreenNumber) {
        for (index, imageView) in phoneImageDotsCollection.enumerated() {
            imageView.image = screenNumber.getSelectedImageIndex == index ? UIImage(named: "selected-dot-small") : UIImage(named: "unselected-dot-small")
        }
    }
    
    private func adjustProgressImageDotsUI(screenNumber: ScreenNumber) {
        guard screenProgressImageDotsWidthConstraintCollection.count == screenProgressImageDotsCollection.count else { return }
        for (index, imageView) in screenProgressImageDotsCollection.enumerated() {
            screenProgressImageDotsWidthConstraintCollection[index].constant = screenNumber.getSelectedImageIndex == index ? 20 : 10
            imageView.image = screenNumber.getSelectedImageIndex == index ? UIImage(named: "selected-dot-large") : UIImage(named: "unselected-dot-large")
        }
    }
    
    private func adjustRotatingImageViewConstraints(screenNumber: ScreenNumber) {
        guard let imageView = self.rotatingImageView else { return }
        
        switch screenNumber {
        case .one:
            let relativeView: UIImageView = phoneImageDotsCollection[0]
            let relatedImageYReference: NSLayoutAnchor<NSLayoutYAxisAnchor> = relativeView.centerYAnchor
            let verticalConstraint = imageView.centerYAnchor.constraint(equalTo: relatedImageYReference, constant: 1)
            let relatedImageLeadingReference: NSLayoutAnchor<NSLayoutXAxisAnchor> = relativeView.centerXAnchor
            let leadingConstraint = imageView.leadingAnchor.constraint(equalTo: relatedImageLeadingReference, constant: -12)
            let widthConstraint = imageView.widthAnchor.constraint(equalToConstant: 133)
            let heightConstraint = imageView.heightAnchor.constraint(equalToConstant: 99)
            self.rotatingImageViewConstraints = [verticalConstraint, leadingConstraint, widthConstraint, heightConstraint]
            contentView.addConstraints([verticalConstraint, leadingConstraint, widthConstraint, heightConstraint])
        case .two:
            if let constraintsToRemove = self.rotatingImageViewConstraints {
                contentView.removeConstraints(constraintsToRemove)
            }
            let relativeView: UIImageView = phoneImageDotsCollection[1]
            let relatedImageXReference: NSLayoutAnchor<NSLayoutXAxisAnchor> = relativeView.centerXAnchor
            let horizontalConstraint = imageView.centerXAnchor.constraint(equalTo: relatedImageXReference, constant: 1)
            let relatedImageYReference: NSLayoutAnchor<NSLayoutYAxisAnchor> = relativeView.topAnchor
            let bottomConstraint = imageView.bottomAnchor.constraint(equalTo: relatedImageYReference, constant: 0)
            let widthConstraint = imageView.widthAnchor.constraint(equalToConstant: 124)
            let heightConstraint = imageView.heightAnchor.constraint(equalToConstant: 107)
            self.rotatingImageViewConstraints = [horizontalConstraint, bottomConstraint, widthConstraint, heightConstraint]
            contentView.addConstraints([horizontalConstraint, bottomConstraint, widthConstraint, heightConstraint])
        case .three:
            if let constraintsToRemove = self.rotatingImageViewConstraints {
                contentView.removeConstraints(constraintsToRemove)
            }
            let relativeView: UIImageView = phoneImageDotsCollection[2]
            let relatedImageYReference: NSLayoutAnchor<NSLayoutYAxisAnchor> = relativeView.centerYAnchor
            let verticalConstraint = imageView.centerYAnchor.constraint(equalTo: relatedImageYReference, constant: 1)
            let relatedImageTrailingReference: NSLayoutAnchor<NSLayoutXAxisAnchor> = relativeView.centerXAnchor
            let trailingConstraint = imageView.trailingAnchor.constraint(equalTo: relatedImageTrailingReference, constant: 14)
            let widthConstraint = imageView.widthAnchor.constraint(equalToConstant: 132)
            let heightConstraint = imageView.heightAnchor.constraint(equalToConstant: 99)
            self.rotatingImageViewConstraints = [verticalConstraint, trailingConstraint, widthConstraint, heightConstraint]
            contentView.addConstraints([verticalConstraint, trailingConstraint, widthConstraint, heightConstraint])
        }
    }
    
    private func updateRotatingImage(screenNumber: ScreenNumber) {
        guard let imageView = self.rotatingImageView else { return }
        imageView.image = screenNumber.getRotatingImage
    }

    private func adjustText(screenNumber: ScreenNumber) {
        onboardingTitleLabel.text = screenNumber.getTitle
        onboardingDescriptionLabel.text = screenNumber.getDescription
    }

    private func adjustBottomButton(screenNumber: ScreenNumber, delegateOwner: UIViewController) {
        let buttonType: AppStyleButton.ButtonType
        let accessibilityValue: String
        let accessibilityHint: String
        switch screenNumber {
        case .one:
            buttonType = .next
            accessibilityValue = AccessibilityLabels.Onboarding.buttonNextTitle
            accessibilityHint = AccessibilityLabels.Onboarding.buttonNextHint
        case .two:
            buttonType = .next
            accessibilityValue = AccessibilityLabels.Onboarding.buttonNextTitle
            accessibilityHint = AccessibilityLabels.Onboarding.buttonNextHint
        case .three:
            buttonType = .getStarted
            bottomButtonWidthConstraint.constant = 162
            accessibilityValue = AccessibilityLabels.Onboarding.buttonGetStartedTitle
            accessibilityHint = AccessibilityLabels.Onboarding.buttonGetStartedHint
        }
        bottomButton.configure(withStyle: .blue, buttonType: buttonType, delegateOwner: delegateOwner, enabled: true, accessibilityValue: accessibilityValue, accessibilityHint: accessibilityHint)
    }
}
