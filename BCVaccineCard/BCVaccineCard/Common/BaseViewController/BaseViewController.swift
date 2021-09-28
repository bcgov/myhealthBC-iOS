//
//  BaseViewController.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-09-15.
//

import UIKit

protocol NavigationSetupProtocol: AnyObject {
    func setNavigationBarWith(title: String, andImage image: UIImage?, action: Selector?)
}

class BaseViewController: UIViewController, NavigationSetupProtocol {
    
    weak var navDelegate: NavigationSetupProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationSetup()
    }
    
}

// MARK: Navigation setup
extension BaseViewController {
    private func navigationSetup() {
        self.navDelegate = self
        navigationItem.setHidesBackButton(true, animated: true)
    }
    
    func setNavigationBarWith(title: String, andImage image: UIImage?, action: Selector?) {
        navigationItem.title = title
        guard let nav = self.navigationController as? CustomNavigationController else { return }
        guard let action = action else {
                nav.hideRightBarButton()
            return
        }
        nav.setImageAndTarget(image: image, action: action, target: self)
    }
    
    func removeRightButtonTarget(action: Selector) {
        guard let nav = self.navigationController as? CustomNavigationController else { return }
        let subviews = nav.navigationBar.subviews
        for view in subviews{
            if view.tag == Constants.NavBarConstants.buttonTag, let button = view as? UIButton {
                button.removeTarget(self, action: action, for: .touchUpInside)
            }
        }
    }
    
    private func moveAndResizeImage(for height: CGFloat) {
        guard let nav = self.navigationController as? CustomNavigationController else { return }
        let coeff: CGFloat = {
            let delta = height - Constants.NavBarConstants.NavBarHeightSmallState
            let heightDifferenceBetweenStates = (Constants.NavBarConstants.NavBarHeightLargeState - Constants.NavBarConstants.NavBarHeightSmallState)
            return delta / heightDifferenceBetweenStates
        }()

        let factor = Constants.NavBarConstants.ImageSizeForSmallState / Constants.NavBarConstants.ImageSizeForLargeState

        let scale: CGFloat = {
            let sizeAddendumFactor = coeff * (1.0 - factor)
            return min(1.0, sizeAddendumFactor + factor)
        }()

        // Value of difference between icons for large and small states
        let sizeDiff = Constants.NavBarConstants.ImageSizeForLargeState * (1.0 - factor) // 8.0
        let yTranslation: CGFloat = {
            /// This value = 14. It equals to difference of 12 and 6 (bottom margin for large and small states). Also it adds 8.0 (size difference when the image gets smaller size)
            let maxYTranslation = Constants.NavBarConstants.ImageBottomMarginForLargeState - Constants.NavBarConstants.ImageBottomMarginForSmallState + sizeDiff
            return max(0, min(maxYTranslation, (maxYTranslation - coeff * (Constants.NavBarConstants.ImageBottomMarginForSmallState + sizeDiff))))
        }()

        let xTranslation = max(0, sizeDiff - coeff * sizeDiff)
        guard let button = nav.getRightBarButton() else { return }
        button.transform = CGAffineTransform.identity
            .scaledBy(x: scale, y: scale)
            .translatedBy(x: xTranslation, y: yTranslation)
    }
}

extension BaseViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let nav = self.navigationController as? CustomNavigationController else { return }
        let height = nav.navigationBar.frame.height
        moveAndResizeImage(for: height)
    }
}

