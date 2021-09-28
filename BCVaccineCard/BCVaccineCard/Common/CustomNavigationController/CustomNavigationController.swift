//
//  CustomNavigationController.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-09-27.
//

import UIKit

class CustomNavigationController: UINavigationController {
    
    private var rightNavButton: UIButton?

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    

    private func setup() {
        navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        navigationBar.sizeToFit()
        navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: AppColours.appBlue]
        navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: AppColours.appBlue]
        navigationBar.tintColor = AppColours.appBlue
        navigationController?.navigationBar.barTintColor = .white
        buttonSetup()
    }
    
    private func buttonSetup() {
        self.rightNavButton = UIButton()
        guard let rightNavButton = rightNavButton else { return }
        rightNavButton.tag = Constants.NavBarConstants.buttonTag
        navigationBar.addSubview(rightNavButton)
        rightNavButton.layer.cornerRadius = Constants.NavBarConstants.ImageSizeForLargeState / 2
        rightNavButton.clipsToBounds = true
        rightNavButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            rightNavButton.rightAnchor.constraint(equalTo: navigationBar.rightAnchor, constant: -Constants.NavBarConstants.ImageRightMargin),
            rightNavButton.bottomAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: -Constants.NavBarConstants.ImageBottomMarginForLargeState),
            rightNavButton.heightAnchor.constraint(equalToConstant: Constants.NavBarConstants.ImageSizeForLargeState),
            rightNavButton.widthAnchor.constraint(equalTo: rightNavButton.heightAnchor)
        ])
    }
    
    func setImageAndTarget(image: UIImage?, action: Selector, target: Any?) {
        guard let rightNavButton = rightNavButton else { return }
        rightNavButton.setImage(image, for: .normal)
        rightNavButton.addTarget(target, action: action, for: .touchUpInside)
    }
    
    func hideRightBarButton() {
        self.rightNavButton?.isHidden = true
    }
    
    func getRightBarButton() -> UIButton? {
        return self.rightNavButton
    }

}

