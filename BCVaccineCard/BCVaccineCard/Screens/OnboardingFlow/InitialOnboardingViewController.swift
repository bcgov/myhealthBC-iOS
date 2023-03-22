//
//  InitialOnboardingViewController.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-10-11.
//
// TODO: 1.) Add in UI for OnboardingCollectionViewCell, and for this VC 2.) Remove old code from this VC, 3.) Test out

import UIKit

class InitialOnboardingViewController: UIViewController {
    
    struct ViewModel {
        let startScreenNumber: OnboardingScreenType
        let screensToShow: [OnboardingScreenType]
        let completion: (_ authenticated: Bool)->Void
    }
    
    class func construct(viewModel: ViewModel) -> InitialOnboardingViewController {
        if let vc = Storyboard.main.instantiateViewController(withIdentifier: String(describing: InitialOnboardingViewController.self)) as? InitialOnboardingViewController {
            vc.screensToShow = viewModel.screensToShow
            vc.screenNumber = viewModel.startScreenNumber
            vc.viewModel = viewModel
            return vc
        }
        return InitialOnboardingViewController()
    }
    
    @IBOutlet weak private var collectionView: UICollectionView!
    @IBOutlet weak private var progressStackView: UIStackView!
    @IBOutlet weak private var progressStackViewWidthConstraintToDelete: NSLayoutConstraint!
    @IBOutlet weak private var bottomButton: AppStyleButton!
    @IBOutlet weak private var bottomButtonWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak private var skipButton: UIButton!
    
    private var viewModel: ViewModel?
    private var screensToShow: [OnboardingScreenType] = []
    private var screenNumber: OnboardingScreenType = .healthPasses
    private var newTextShown: Bool = false
    private var screenProgressImageDotsCollection: [UIImageView] = []
    private var screenProgressImageDotsWidthConstraintCollection: [NSLayoutConstraint] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup() {
        uiSetup()
        stackViewSetup()
        setupCollectionView()
    }
    
    private func uiSetup() {
        newTextShown = !(screensToShow.count == OnboardingScreenType.allCases.count)
        // TODO: put in AppColours
        let skipButtonColour = UIColor(red: 0.102, green: 0.353, blue: 0.588, alpha: 1)
        skipButton.setTitleColor(skipButtonColour, for: .normal)
        skipButton.setTitle("Skip intro", for: .normal)
        skipButton.titleLabel?.font = UIFont.bcSansBoldWithSize(size: 17)
        adjustBottomButton(screenNumber: screenNumber, screensToShow: screensToShow)
        skipButton.isHidden = screensToShow.count == 1
        
    }
    
    @IBAction private func skipButtonTapped(_ sender: UIButton) {
        Defaults.storeInitialOnboardingScreensSeen(types: screensToShow)
        showLocalAuth {[weak self] in
            self?.goToAuthentication()
        }
    }
    
}

// MARK: Progress stack view logic
extension InitialOnboardingViewController {
    private func stackViewSetup() {
        let count = screensToShow.count
        guard count > 1 else {
            progressStackView.isHidden = true
            return
        }
        progressStackView.axis = .horizontal
        progressStackView.alignment = .fill
        progressStackView.distribution = .fill
        progressStackView.spacing = 10
        reusableImageCreationFunction(count: count, imageName: "unselected-dot-large", size: 10)
        screenProgressImageDotsCollection[0].image = UIImage(named: "selected-dot-large")
        screenProgressImageDotsWidthConstraintCollection[0].constant = 20
        addConfigureScreenDotsToStackView()
    }
    
    private func addConfigureScreenDotsToStackView() {
        screenProgressImageDotsCollection.forEach { progressStackView.addArrangedSubview($0) }
        // This constraint is just used to satisfy autolayout complaints - not necessary once views are added
        progressStackView.removeConstraint(progressStackViewWidthConstraintToDelete)
    }
    
    private func reusableImageCreationFunction(count: Int, imageName: String, size: CGFloat) {
        for _ in 1...count {
            let imageView = UIImageView(image: UIImage(named: imageName))
            imageView.translatesAutoresizingMaskIntoConstraints = false
            let width = imageView.widthAnchor.constraint(equalToConstant: size)
            let height = imageView.heightAnchor.constraint(equalToConstant: size)
            imageView.addConstraints([width, height])
            self.screenProgressImageDotsCollection.append(imageView)
            self.screenProgressImageDotsWidthConstraintCollection.append(width)
        }
    }
    
    private func adjustProgressImageDotsUI(screenNumber: OnboardingScreenType) {
        guard screenProgressImageDotsWidthConstraintCollection.count == screenProgressImageDotsCollection.count else { return }
        for (index, imageView) in screenProgressImageDotsCollection.enumerated() {
            screenProgressImageDotsWidthConstraintCollection[index].constant = screenNumber.rawValue == index ? 20 : 10
            imageView.image = screenNumber.rawValue == index ? UIImage(named: "selected-dot-large") : UIImage(named: "unselected-dot-large")
        }
    }
    
    private func adjustUI() {
        if screensToShow.count > 1 {
            adjustProgressImageDotsUI(screenNumber: screenNumber)
        }
        adjustBottomButton(screenNumber: self.screenNumber, screensToShow: screensToShow)
    }

}

// MARK: Collection View Delegate and Flow layout
extension InitialOnboardingViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
    private func setupCollectionView() {
        collectionView.register(UINib.init(nibName: OnboardingCollectionViewCell.getName, bundle: .main), forCellWithReuseIdentifier: OnboardingCollectionViewCell.getName)
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize =  cellSize()
        collectionView.collectionViewLayout = layout
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func cellSize() -> CGSize {
        let cView = collectionView.frame
        return CGSize(width: cView.width, height: cView.height)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return cellSize()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return screensToShow.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OnboardingCollectionViewCell.getName, for: indexPath) as? OnboardingCollectionViewCell {
            let screenType = screensToShow[indexPath.row]
            cell.configure(screenType: screenType, newTextShown: newTextShown)
            cell.layoutIfNeeded()
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // As of now, no action here
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard let indexPath = findCenterIndex() else { return }
        if let newScreen = getNewScreenTypeAfterScrollingValuesChanged(indexPath: indexPath, screensToShow: self.screensToShow) {
            self.screenNumber = newScreen
            adjustUI()
        }
        
    }
    
    private func findCenterIndex() -> IndexPath? {
        let center = self.view.convert(self.collectionView.center, to: self.collectionView)
        let indexPath = collectionView.indexPathForItem(at: center)
        return indexPath
    }
}

// MARK: For adjusting button text
extension InitialOnboardingViewController {
    private func getNewScreenTypeAfterScrollingValuesChanged(indexPath: IndexPath, screensToShow: [OnboardingScreenType]) -> OnboardingScreenType? {
        guard screensToShow.count > 1 else { return nil }
        guard let newScreenNumber = OnboardingScreenType.init(rawValue: indexPath.row) else { return nil }
        if let index = screensToShow.firstIndex(of: newScreenNumber) {
            return screensToShow[index]
        } else {
            return nil
        }
    }
    
    private func increment(screenNumber: OnboardingScreenType, screensToShow: [OnboardingScreenType]) -> OnboardingScreenType? {
        guard screensToShow.count > 1 else { return nil }
        if let index = screensToShow.firstIndex(of: screenNumber), screensToShow.count > index + 1 {
            return screensToShow[index + 1]
        } else {
            return nil
        }
    }
    
    private func adjustBottomButton(screenNumber: OnboardingScreenType, screensToShow: [OnboardingScreenType]) {
        let buttonType: AppStyleButton.ButtonType
        let accessibilityValue: String
        let accessibilityHint: String
        
        if screensToShow.count == 1 {
            // user has seen screens before, only one new one to show, only show ok button
            buttonType = .ok
            accessibilityValue = AccessibilityLabels.Onboarding.buttonOkTitle
            accessibilityHint = AccessibilityLabels.Onboarding.buttonOkHint
        } else if screensToShow.count == OnboardingScreenType.allCases.count {
            // brand new user - first count - 1 buttons are next, last one is 'getStarted'
            if let index = screensToShow.firstIndex(of: screenNumber), index == screensToShow.count - 1 {
                buttonType = .getStarted
                bottomButtonWidthConstraint.constant = 162
                accessibilityValue = AccessibilityLabels.Onboarding.buttonGetStartedTitle
                accessibilityHint = AccessibilityLabels.Onboarding.buttonGetStartedHint
                skipButton.alpha = 0
            } else {
                skipButton.alpha = 1
                buttonType = .next
                accessibilityValue = AccessibilityLabels.Onboarding.buttonNextTitle
                accessibilityHint = AccessibilityLabels.Onboarding.buttonNextHint
            }
        } else {
            // there are more than one screen to show, but user has still seen some before
            if let index = screensToShow.firstIndex(of: screenNumber), index == screensToShow.count - 1 {
                buttonType = .ok
                accessibilityValue = AccessibilityLabels.Onboarding.buttonOkTitle
                accessibilityHint = AccessibilityLabels.Onboarding.buttonOkHint
            } else {
                buttonType = .next
                accessibilityValue = AccessibilityLabels.Onboarding.buttonNextTitle
                accessibilityHint = AccessibilityLabels.Onboarding.buttonNextHint
            }
        }
        bottomButton.configure(withStyle: .blue, buttonType: buttonType, delegateOwner: self, enabled: true, accessibilityValue: accessibilityValue, accessibilityHint: accessibilityHint)
        self.view.layoutIfNeeded()
    }

}

extension InitialOnboardingViewController: AppStyleButtonDelegate {
    func buttonTapped(type: AppStyleButton.ButtonType) {
        if type == .next, let newScreenNumber = increment(screenNumber: screenNumber, screensToShow: screensToShow) {
            self.screenNumber = newScreenNumber
            let indexPath = IndexPath(row: screenNumber.rawValue, section: 0)
            collectionView.scrollToItem(at: indexPath, at: .right, animated: true)
            adjustUI()
        }
        if type == .getStarted || type == .ok {
            Defaults.storeInitialOnboardingScreensSeen(types: screensToShow)
            
            showLocalAuth {[weak self] in
                self?.goToAuthentication()
            }
        }
    }
    
    private func goToAuthentication() {
        if AuthManager().isAuthenticated {
            showHomeScreen(authStatus: nil)
        } else {
            showLogin(initialView: .Landing, presentationStyle: .fullScreen, showTabOnSuccess: .Home)
            Defaults.hasSeenFirstLogin = true
        }
        
    }
    
    func showHomeScreen(authStatus: AuthenticationViewController.AuthenticationStatus?) {
        guard let callback = viewModel?.completion else {
            return
        }
        self.dismiss(animated: true) {
            callback(authStatus == .Completed)
        }
    }
}


