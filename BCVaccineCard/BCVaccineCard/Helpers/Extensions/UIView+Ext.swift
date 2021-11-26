//
//  UIView+Ext.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-09-20.
//

import UIKit

extension UIView {
    
    static var getName: String {
        return String(describing: self.self)
    }
}


extension UIView {
    func isSmallScreen() -> Bool {
        let bounds = UIScreen.main.bounds
        let height = bounds.size.height
        let iPhone5ScreenHeight: CGFloat = 568.0
        
        return height <= iPhone5ScreenHeight
    }
}

extension UIView {
    func startLoadingIndicator(backgroundColor: UIColor = Constants.UI.LoadingIndicator.backdropColor) {
        if let existing = self.viewWithTag(Constants.UI.LoadingIndicator.backdropTag) {
            existing.removeFromSuperview()
        }
        
        let backdrop = UIView(frame: .zero)
        backdrop.tag = Constants.UI.LoadingIndicator.backdropTag
        let indicator = UIActivityIndicatorView(frame: .zero)
        indicator.tintColor = AppColours.appBlue
        let loadingContainer = UIView(frame:.zero)
        
        self.addSubview(backdrop)
        backdrop.addSubview(loadingContainer)
        loadingContainer.addSubview(indicator)
        
        backdrop.backgroundColor = backgroundColor
        loadingContainer.backgroundColor = Constants.UI.LoadingIndicator.containerColor
        loadingContainer.layer.cornerRadius = Constants.UI.Theme.cornerRadius
        
        backdrop.addEqualSizeContraints(to: self)
        
        loadingContainer.center(in: backdrop, width: Constants.UI.LoadingIndicator.containerSize, height: Constants.UI.LoadingIndicator.containerSize)
        indicator.center(in: loadingContainer, width: Constants.UI.LoadingIndicator.size, height: Constants.UI.LoadingIndicator.size)
        
        indicator.startAnimating()
    }
    
    func endLoadingIndicator() {
        if let existing = self.viewWithTag(Constants.UI.LoadingIndicator.backdropTag) {
            existing.removeFromSuperview()
        }
    }
    
    public func addEqualSizeContraints(to toView: UIView) {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.heightAnchor.constraint(equalTo: toView.heightAnchor, constant: 0).isActive = true
        self.widthAnchor.constraint(equalTo: toView.widthAnchor, constant: 0).isActive = true
        self.leadingAnchor.constraint(equalTo: toView.leadingAnchor, constant: 0).isActive = true
        self.trailingAnchor.constraint(equalTo: toView.trailingAnchor, constant: 0).isActive = true
    }
    
    public func center(in view: UIView, width: CGFloat, height: CGFloat) {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.heightAnchor.constraint(equalToConstant: height).isActive = true
        self.widthAnchor.constraint(equalToConstant: width).isActive = true
        self.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        self.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0).isActive = true
    }
    
    // Load a nib
    public class func fromNib<T: UIView>(bundle: Bundle? = Bundle.main) -> T {
        return bundle!.loadNibNamed(String(describing: T.self), owner: nil, options: nil)![0] as! T
    }
}
