//
//  InitialOnboardingView.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-10-11.
//

import UIKit
// TODO: Update UI for 4th screen. Steps:
/// First, update image assets, get logic working for 3 initial screens, make sure that data saves (Need to get image assets from the girls)
///  Second, update UI to contain 4 dots (in phone and above get started - maybe look at setting this up so that the UI is created programatically for the dot views...yeah, do that
///  Third, Add in UI constraints for health records, adjust health resourcs and news feed (health will now have same constraints as news feed, and news feed will be the same as what resources was, just with a different reference dot)
///   Fourth, adjust UI to have option to hide lower dots, adjust button title (based on what has been shown or not), have 'NEW' label showing'
///   Fifth - test it out thoroughly
enum OnboardingScreenType: String, Codable, CaseIterable {
    case healthPasses = "Health Passes"
//    case healthRecords = "Health Records"
    case healthResources = "Health Resources"
    case newsFeed = "News Feed"
    
    var getStartScreenNumber: InitialOnboardingView.ScreenNumber {
        switch self {
        case .healthPasses:
            return .one
        case .healthResources:
            return .two
        case .newsFeed:
            return .three
        }
    }
}

class InitialOnboardingView: UIView {
    
    enum ScreenNumber: CaseIterable {
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
        
        var getType: OnboardingScreenType {
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
        
//        // TODO: Will need to fix this function
//        func increment() -> ScreenNumber? {
//            switch self {
//            case .one:
//                return .two
//            case .two:
//                return .three
//            case .three:
//                return nil
//            }
//        }
    }
    
    enum ImageCollectionType {
        case phoneDotCollection
        case screenProgressCollection
    }
    
    @IBOutlet weak private var contentView: UIView!
    @IBOutlet weak private var phoneImageView: UIImageView!
    @IBOutlet weak private var phoneImageDotsStackView: UIStackView!
    @IBOutlet weak private var phoneImageDotsStackViewWidthConstraintToDelete: NSLayoutConstraint!
    @IBOutlet weak private var onboardingTitleLabel: UILabel!
    @IBOutlet weak private var onboardingDescriptionLabel: UILabel!
    @IBOutlet weak private var screenProgressImageDotsStackView: UIStackView!
    @IBOutlet weak private var screenProgressImageDotsStackViewWidthConstraintToDelete: NSLayoutConstraint!
    @IBOutlet weak private var bottomButton: AppStyleButton!
    @IBOutlet weak private var bottomButtonWidthConstraint: NSLayoutConstraint!
    
    private var phoneImageDotsCollection: [UIImageView] = []
    private var screenProgressImageDotsCollection: [UIImageView] = []
    private var screenProgressImageDotsWidthConstraintCollection: [NSLayoutConstraint] = []
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
        stackViewSetup()
        createInitialRotatingImageView()
    }
    
    private func labelSetup() {
        onboardingTitleLabel.font = UIFont.bcSansBoldWithSize(size: 24)
        onboardingTitleLabel.textColor = AppColours.appBlue
        onboardingDescriptionLabel.font = UIFont.bcSansRegularWithSize(size: 17)
        onboardingDescriptionLabel.textColor = AppColours.textBlack
    }
    
    private func stackViewSetup() {
        phoneImageDotsStackView.axis = .horizontal
        phoneImageDotsStackView.alignment = .fill
        phoneImageDotsStackView.distribution = .fill
        screenProgressImageDotsStackView.axis = .horizontal
        screenProgressImageDotsStackView.alignment = .fill
        screenProgressImageDotsStackView.distribution = .fill
        screenProgressImageDotsStackView.spacing = 10
    }
    
    private func createInitialRotatingImageView() {
        self.rotatingImageView = UIImageView()
        guard let rotatingImageView = rotatingImageView else { return }
        self.contentView.addSubview(rotatingImageView)
        rotatingImageView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func initialConfigure(screenNumber: ScreenNumber, screensToShow: [ScreenNumber], delegateOwner: UIViewController) {
        configureScreenProgressDots(screenNumber: screenNumber, screensToShow: screensToShow)
        configurePhoneDots(screenNumber: screenNumber)
        commonConfigurationAndUpdates(screenNumber: screenNumber, delegateOwner: delegateOwner)
    }
    
    private func configurePhoneDots(screenNumber: ScreenNumber) {
        let count = OnboardingScreenType.allCases.count
        reusableImageCreationFunction(count: count, imageName: "unselected-dot-small", size: 8, collectionType: .phoneDotCollection)
        guard phoneImageDotsCollection.count > screenNumber.getSelectedImageIndex else { return }
        phoneImageDotsCollection[screenNumber.getSelectedImageIndex].image = UIImage(named: "selected-dot-small")
        addConfigurePhoneDotsToStackView(count: phoneImageDotsCollection.count)
    }
    
    private func addConfigurePhoneDotsToStackView(count: Int) {
        let spacing: CGFloat = count >= 4 ? 6 : 8
        phoneImageDotsStackView.spacing = spacing
        phoneImageDotsCollection.forEach { phoneImageDotsStackView.addArrangedSubview($0) }
        // This constraint is just used to satisfy autolayout complaints - not necessary once views are added
        phoneImageDotsStackView.removeConstraint(phoneImageDotsStackViewWidthConstraintToDelete)
    }
    
    private func configureScreenProgressDots(screenNumber: ScreenNumber, screensToShow: [ScreenNumber]) {
        let count = screensToShow.count
        guard count > 1 else {
            screenProgressImageDotsStackView.isHidden = true
            return
        }
        reusableImageCreationFunction(count: count, imageName: "unselected-dot-large", size: 10, collectionType: .screenProgressCollection)
        screenProgressImageDotsCollection[0].image = UIImage(named: "selected-dot-large")
        screenProgressImageDotsWidthConstraintCollection[0].constant = 20
        addConfigureScreenDotsToStackView()
    }
    
    private func addConfigureScreenDotsToStackView() {
        screenProgressImageDotsCollection.forEach { screenProgressImageDotsStackView.addArrangedSubview($0) }
        // This constraint is just used to satisfy autolayout complaints - not necessary once views are added
        screenProgressImageDotsStackView.removeConstraint(screenProgressImageDotsStackViewWidthConstraintToDelete)
    }
    
    private func reusableImageCreationFunction(count: Int, imageName: String, size: CGFloat, collectionType: ImageCollectionType) {
        for _ in 1...count {
            let imageView = UIImageView(image: UIImage(named: imageName))
            imageView.translatesAutoresizingMaskIntoConstraints = false
            let width = imageView.widthAnchor.constraint(equalToConstant: size)
            let height = imageView.heightAnchor.constraint(equalToConstant: size)
            imageView.addConstraints([width, height])
            collectionType == .phoneDotCollection ? self.phoneImageDotsCollection.append(imageView) : self.screenProgressImageDotsCollection.append(imageView)
            if collectionType == .screenProgressCollection {
                self.screenProgressImageDotsWidthConstraintCollection.append(width)
            }
        }
    }
    
    func adjustUI(screenNumber: ScreenNumber, screensToShow: [ScreenNumber], delegateOwner: UIViewController) {
        adjustPhoneImageDots(screenNumber: screenNumber)
        commonConfigurationAndUpdates(screenNumber: screenNumber, delegateOwner: delegateOwner)
        if screensToShow.count > 1 {
            adjustProgressImageDotsUI(screenNumber: screenNumber)
        }
    }
    
    func increment(screenNumber: ScreenNumber, screensToShow: [ScreenNumber]) -> ScreenNumber? {
        guard screensToShow.count > 1 else { return nil }
        if let index = screensToShow.firstIndex(of: screenNumber), screensToShow.count > index + 1 {
            return screensToShow[index + 1]
        } else {
            return nil
        }
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
        guard phoneImageDotsCollection.count > screenNumber.getSelectedImageIndex else { return }
        let relativeView: UIImageView = phoneImageDotsCollection[screenNumber.getSelectedImageIndex]
        switch screenNumber {
        case .one:
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
            let relatedImageYReference: NSLayoutAnchor<NSLayoutYAxisAnchor> = relativeView.centerYAnchor
            let verticalConstraint = imageView.centerYAnchor.constraint(equalTo: relatedImageYReference, constant: 1)
            let relatedImageTrailingReference: NSLayoutAnchor<NSLayoutXAxisAnchor> = relativeView.centerXAnchor
            let trailingConstraint = imageView.trailingAnchor.constraint(equalTo: relatedImageTrailingReference, constant: 14)
            let widthConstraint = imageView.widthAnchor.constraint(equalToConstant: 132)
            let heightConstraint = imageView.heightAnchor.constraint(equalToConstant: 99)
            self.rotatingImageViewConstraints = [verticalConstraint, trailingConstraint, widthConstraint, heightConstraint]
            contentView.addConstraints([verticalConstraint, trailingConstraint, widthConstraint, heightConstraint])
        case .three:
            if let constraintsToRemove = self.rotatingImageViewConstraints {
                contentView.removeConstraints(constraintsToRemove)
            }
            let relatedImageXReference: NSLayoutAnchor<NSLayoutXAxisAnchor> = relativeView.centerXAnchor
            let horizontalConstraint = imageView.centerXAnchor.constraint(equalTo: relatedImageXReference, constant: 1)
            let relatedImageYReference: NSLayoutAnchor<NSLayoutYAxisAnchor> = relativeView.topAnchor
            let bottomConstraint = imageView.bottomAnchor.constraint(equalTo: relatedImageYReference, constant: 0)
            let widthConstraint = imageView.widthAnchor.constraint(equalToConstant: 124)
            let heightConstraint = imageView.heightAnchor.constraint(equalToConstant: 107)
            self.rotatingImageViewConstraints = [horizontalConstraint, bottomConstraint, widthConstraint, heightConstraint]
            contentView.addConstraints([horizontalConstraint, bottomConstraint, widthConstraint, heightConstraint])
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

    // TODO: Need to have provision in here for if screens have been shown before, and this is an updated screen or not
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

// MARK: Defaults helper
extension InitialOnboardingView {
    func getAllScreensForDefaults() -> [OnboardingScreenType] {
        let one = ScreenNumber.one.getType
        let two = ScreenNumber.two.getType
        let three = ScreenNumber.three.getType
        return [one, two, three]
    }
}
