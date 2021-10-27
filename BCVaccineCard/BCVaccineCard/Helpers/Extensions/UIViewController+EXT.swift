//
//  UIViewController.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2021-09-20.
//

import Foundation
import UIKit
import BCVaccineValidator
import SafariServices

extension UIViewController {
    
    enum BannerStyle {
        case Top, Bottom
    }
    func alert(title: String, message: String) {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        controller.isAccessibilityElement = true
        controller.addAction(UIAlertAction(title: .ok, style: .default))
        DispatchQueue.main.async {
            self.present(controller, animated: true)
        }
    }
    
    func alert(title: String, message: String, completion: @escaping()->Void) {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        controller.isAccessibilityElement = true
        controller.addAction(UIAlertAction(title: .ok, style: .default, handler: { action in
            return completion()
        }))
        DispatchQueue.main.async {
            self.present(controller, animated: true)
        }
    }
    
    func alert(title: String, message: String, buttonOneTitle: String, buttonOneCompletion: @escaping()->Void, buttonTwoTitle: String?, buttonTwoCompletion: @escaping()->Void) {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        controller.isAccessibilityElement = true
        controller.addAction(UIAlertAction(title: buttonOneTitle, style: .default, handler: { action in
            return buttonOneCompletion()
        }))
        if let buttonTitle = buttonTwoTitle {
            controller.addAction(UIAlertAction(title: buttonTitle, style: .default, handler: { action in
                return buttonTwoCompletion()
            }))
        }
        DispatchQueue.main.async {
            self.present(controller, animated: true)
        }
    }
    
    fileprivate func presentBannerFromTop(container: UIView, label: UILabel, labelTAG: Int) {
        let textPadding: CGFloat = Constants.UI.Banner.labelPadding
        let containerPadding: CGFloat = Constants.UI.Banner.containerPadding
        let messageHeight = label.text?.heightForView(font: Constants.UI.Banner.labelFont, width: container.bounds.width) ?? 32
        let bannerHeight = messageHeight + (textPadding * 2) + 45
        let closedTopAnchor = 0 - bannerHeight
        let openTopAnchor: CGFloat = 0
        
        // Position container
        container.translatesAutoresizingMaskIntoConstraints = false
        let topContraint = container.topAnchor.constraint(equalTo: self.view.topAnchor, constant: closedTopAnchor)
        container.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0).isActive = true
        container.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0).isActive = true
        container.heightAnchor.constraint(equalToConstant: bannerHeight).isActive = true
        
        NSLayoutConstraint.activate([topContraint])
        
        // Position Label
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.topAnchor.constraint(greaterThanOrEqualTo: container.topAnchor, constant: textPadding).isActive = true
        label.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: 0 - textPadding * 2).isActive = true
        label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: textPadding).isActive = true
        label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: 0 - textPadding).isActive = true
        
        // Style
        label.textAlignment = .center
        label.font = Constants.UI.Banner.labelFont
        label.textColor = Constants.UI.Banner.labelColor
        container.backgroundColor = Constants.UI.Banner.backgroundColor
        container.layer.cornerRadius = Constants.UI.Theme.cornerRadius
        
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {[weak self] in
            guard let `self` = self else {return}
            topContraint.constant = openTopAnchor
            self.view.layoutIfNeeded()
        }
        
//        UIAccessibility.setFocusTo(label)
        
        // Remove banner after x seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.UI.Banner.displayDuration) {[weak self] in
            guard let `self` = self else {return}
            /*
             We Randomly generated labelTAG.
             here we check if after the display duration, the same label is still displayed.
             this helps us avoid removing a banner that was just displayed
             */
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut) {[weak self] in
                guard let `self` = self,
                      let container = self.view.viewWithTag(Constants.UI.Banner.tag),
                      container.viewWithTag(labelTAG) != nil
                      else {return}
                container.alpha = 0
            } completion: { done in
                container.removeFromSuperview()
            }
        }
    }
    
    fileprivate func presentBannerAtBottom(container: UIView, label: UILabel, labelTAG: Int) {
        let textPadding: CGFloat = Constants.UI.Banner.labelPadding
        let containerPadding: CGFloat = Constants.UI.Banner.containerPadding
        let messageHeight = label.text?.heightForView(font: Constants.UI.Banner.labelFont, width: container.bounds.width) ?? 32
        let bannerHeight = messageHeight + (textPadding * 2)
        
        // Position container
        container.translatesAutoresizingMaskIntoConstraints = false
        container.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant:  0 - containerPadding).isActive = true
        container.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0).isActive = true
        container.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0).isActive = true
        container.heightAnchor.constraint(equalToConstant: bannerHeight).isActive = true
        
        // Position Label
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.topAnchor.constraint(greaterThanOrEqualTo: container.topAnchor, constant: textPadding).isActive = true
        label.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: 0 - textPadding).isActive = true
        label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: textPadding).isActive = true
        label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: 0 - textPadding).isActive = true
        
        // Style
        label.textAlignment = .center
        label.font = Constants.UI.Banner.labelFont
        label.textColor = Constants.UI.Banner.labelColor
        container.backgroundColor = Constants.UI.Banner.backgroundColor
        container.layer.cornerRadius = Constants.UI.Theme.cornerRadius
        
        self.view.layoutIfNeeded()
        
        UIAccessibility.setFocusTo(label)
        
        // Remove banner after x seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.UI.Banner.displayDuration) {[weak self] in
            guard let `self` = self,
                  let container = self.view.viewWithTag(Constants.UI.Banner.tag),
                  container.viewWithTag(labelTAG) != nil
                  else {return}
            /*
             We Randomly generated labelTAG.
             here we check if after the display duration, the same label is still displayed.
             this helps us avoid removing a banner that was just displayed
             */
            container.removeFromSuperview()
        }
    }
    
    func showBanner(message: String, style: BannerStyle) {
        // Create label and container
        let container = UIView(frame: .zero)
        let label = UILabel(frame: .zero)
        
        if style == .Bottom {
            label.isAccessibilityElement = true
            label.accessibilityTraits = .staticText
            label.accessibilityValue = "\(message)"
        }
        
        
        // Remove existing Banner / Container
        if let existing = view.viewWithTag(Constants.UI.Banner.tag) {
            existing.removeFromSuperview()
        }
        
        // Add subviews
        container.tag = Constants.UI.Banner.tag
        let labelTAG = Int.random(in: 4000..<9000)
        label.tag = labelTAG
        self.view.addSubview(container)
        container.addSubview(label)
        label.text = message
        
        switch style {
        case .Top:
            presentBannerFromTop(container: container, label: label, labelTAG: labelTAG)
        case .Bottom:
            presentBannerAtBottom(container: container, label: label, labelTAG: labelTAG)
        }
    }
    
    func hideBanner() {
        guard let banner = view.viewWithTag(Constants.UI.Banner.tag) else {
            return
        }
        UIView.animate(withDuration: Constants.UI.Theme.animationDuration) {
            banner.alpha = 0
            banner.layoutIfNeeded()
        } completion: { done in
            banner.removeFromSuperview()
        }

    }
}

//MARK: Pop-back functions
extension UIViewController {
    //Position in stack popback
    func popBackBy(_ x: Int) {
        if let viewControllers: [UIViewController] = self.navigationController?.viewControllers {
            guard viewControllers.count < x else {
                self.navigationController?.popToViewController(viewControllers[viewControllers.count - x], animated: true)
                return
            }
        }
    }
    
    //Specific VC in stack
    func popBack<T: UIViewController>(toControllerType: T.Type) {
        if var viewControllers: [UIViewController] = self.navigationController?.viewControllers {
            viewControllers = viewControllers.reversed()
            for currentViewController in viewControllers {
                if currentViewController .isKind(of: toControllerType) {
                    self.navigationController?.popToViewController(currentViewController, animated: true)
                    break
                }
            }
        }
    }
}

// MARK: For Local Storage - FIXME: Should find a better spot for this
extension UIViewController {
    func appendModelToLocalStorage(model: LocallyStoredVaccinePassportModel) {
        _ = StorageService.shared.saveVaccineVard(vaccineQR: model.code, name: model.name, userId: AuthManager().userId())
//        if Defaults.vaccinePassports == nil {
//            Defaults.vaccinePassports = []
//            Defaults.vaccinePassports?.append(model)
//        } else {
//            Defaults.vaccinePassports?.append(model)
//        }
    }
    
    func updateCardInLocalStorage(model: LocallyStoredVaccinePassportModel) {
        // TODO: NEW STORAGE
        guard let defaultsPassports = Defaults.vaccinePassports else { return }
        if let index = Defaults.vaccinePassports?.firstIndex(where: { $0.name == model.name && $0.birthdate == model.birthdate }), defaultsPassports.count > index {
            Defaults.vaccinePassports?[index] = model
        }
    }
    
    func convertScanResultModelIntoLocalData(data: ScanResultModel, source: Source) -> LocallyStoredVaccinePassportModel {
        let status = VaccineStatus.init(rawValue: data.status.rawValue) ?? .notVaxed
        return LocallyStoredVaccinePassportModel(code: data.code, birthdate: data.birthdate, name: data.name, issueDate: data.issueDate, status: status, source: source)
    }
}

// MARK: To Open Privacy Policy - keep it simple for now, just open in safari
extension UIViewController {
    func openPrivacyPolicy() {
        if let url = URL(string: Constants.PrivacyPolicy.urlString) {
            guard UIApplication.shared.canOpenURL(url) else {return}
            let vc = SFSafariViewController(url: url)
            present(vc, animated: true)
        }
    }
    
    func openHelpScreen() {
        if let url = URL(string: Constants.Help.urlString) {
            guard UIApplication.shared.canOpenURL(url) else {return}
            let vc = SFSafariViewController(url: url)
            present(vc, animated: true)
        }
    }
}

// MARK: To open a specific URL - for now, keep it simple
extension UIViewController {
    func openURLInSafariVC(withURL link: String) {
        if let url = URL(string: link) {
            guard UIApplication.shared.canOpenURL(url) else {return}
            let vc = SFSafariViewController(url: url)
            present(vc, animated: true)
        }
    }
}

// MARK: Check for duplicates - again, should probably find a better spot for this
extension UIViewController {
    // Need to think about how to handle this... will likely need two functions
    func isCardAlreadyInWallet(modelToAdd model: AppVaccinePassportModel, completion: @escaping(Bool)->Void){
        StorageService.shared.getVaccineCardsForCurrentUser { appDS in
            let idArray = appDS.compactMap({ $0.id })
            guard let id = model.id else { return completion(false) } // May need some form of error handling here, as this just means the new model is incomplete
            guard idArray.firstIndex(where: { $0 == id }) == nil else { return completion(true) }
            return completion(false)
        }
    }
    // TODO: When we move these functions to it's own class, we should refactor how these are done as there is a fair amount of duplication.. just not doing it now as we are close to release
    func doesCardNeedToBeUpdated(modelToUpdate model: AppVaccinePassportModel, completion: @escaping(Bool) -> Void) {
        // TODO: NEW STORAGE
        StorageService.shared.getVaccineCardsForCurrentUser { localDS in
            guard !localDS.isEmpty else { return completion(false) }
            guard model.codableModel.status == .fully else { return completion(false) }
            if let _ = Defaults.vaccinePassports?.firstIndex(where: { $0.name == model.codableModel.name && $0.birthdate == model.codableModel.birthdate && $0.status == .partially }) {
                return completion(true)
            }
            return completion(false)
        }
    }
}

// MARK: Notification Center posting
extension UIViewController {
    func postCardAddedNotification(id: String) {
        NotificationCenter.default.post(name: .cardAddedNotification, object: nil, userInfo: ["id": id])
    }
}
