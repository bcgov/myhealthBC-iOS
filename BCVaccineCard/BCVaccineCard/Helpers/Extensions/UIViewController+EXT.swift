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
    // MARK: Alert
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
    
    func alertConfirmation(title: String,
                           message: String,
                           confirmTitle: String,
                           confirmStyle: UIAlertAction.Style,
                           onConfirm: @escaping()->Void,
                           cancelTitle: String? = .cancel,
                           cancelStyle: UIAlertAction.Style? = .cancel,
                           onCancel: @escaping()->Void) {
        
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        controller.isAccessibilityElement = true
        
        controller.addAction(UIAlertAction(title: cancelTitle, style: cancelStyle ?? .cancel, handler: { action in
            return onCancel()
        }))
        controller.addAction(UIAlertAction(title: confirmTitle, style: confirmStyle, handler: { action in
            return onConfirm()
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
    
    // MARK: Banner
    func showBanner(message: String, style: BannerStyle) {
        // Create label and container
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {return}
            if let parent = self.parent as? CustomNavigationController {
                parent.showBanner(message: message, style: style)
                return
            }
            if let parent = self.parent as? TabBarController {
                parent.showBanner(message: message, style: style)
                return
            }
            let container = UIView(frame: .zero)
            let label = UILabel(frame: .zero)
            
            if style == .Bottom {
                label.isAccessibilityElement = true
                label.accessibilityTraits = .staticText
                label.accessibilityValue = "\(message)"
            }
            
            
            // Remove existing Banner / Container
            if let existing = self.view.viewWithTag(Constants.UI.Banner.tag) {
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
                self.presentBannerFromTop(container: container, label: label, labelTAG: labelTAG)
            case .Bottom:
                self.presentBannerAtBottom(container: container, label: label, labelTAG: labelTAG)
            }
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
        container.layer.cornerRadius = Constants.UI.Theme.cornerRadiusRegular
        
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
        container.layer.cornerRadius = Constants.UI.Theme.cornerRadiusRegular
        
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
    
    // MARK: Local Auth
    func showLocalAuth() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {return}
            if let parent = self.parent as? CustomNavigationController {
                parent.showLocalAuth()
                return
            }
            if let parent = self.parent as? TabBarController {
                parent.showLocalAuth()
                return
            }
            if !LocalAuthManager.shouldAuthenticate {return}
            
            LocalAuthManager.shared.performLocalAuth(on: self) { [weak self] status in
                switch status {
                case .Authorized:
                    self?.localAuthSucceded()
                case .Unauthorized, .Unavailable:
                    self?.localAuthFailed()
                }
                return
            }

        }
    }
    
    private func localAuthFailed() {
        Logger.log(string: "Local auth Failed", type: .localAuth)
    }
    
    private func localAuthSucceded() {
        Logger.log(string: "Local auth successful", type: .localAuth)
    }
    
    // MARK: Helpers
    
    /// returns the tab bar controller: the main parent of all viewcontrollers in this app
    /// Call this from the main thread:
    /// DispatchQueue.main.async { [weak self] in guard let self = self else {return} }
    /// - Returns: tab bar UIViewController
    func findTabBarController() -> UIViewController {
        if let parent = self.parent as? CustomNavigationController {
            return parent.findTabBarController()
            
        }
        if let parent = self.parent as? TabBarController {
            return parent.findTabBarController()
            
        }
        return self
    }
    
    
}

//MARK: Pop-back functions
extension UIViewController {
    //Position in stack popback
    func popBackBy(_ x: Int) {
        DispatchQueue.main.async {
            if let viewControllers: [UIViewController] = self.navigationController?.viewControllers {
                guard viewControllers.count < x else {
                    self.navigationController?.popToViewController(viewControllers[viewControllers.count - x], animated: true)
                    return
                }
            }
        }
    }
    
    //Specific VC in stack
    func popBack<T: UIViewController>(toControllerType: T.Type) {
        DispatchQueue.main.async {
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
}


// MARK: For Local Storage - FIXME: Should find a better spot for this
extension UIViewController {
    func storeVaccineCard(model: LocallyStoredVaccinePassportModel,
                          authenticated: Bool,
                          sortOrder: Int64? = nil,
                          completion: @escaping()->Void
    ) {
        let birthdate =  Date.Formatter.yearMonthDay.date(from: model.birthdate) ?? Date()
        guard let patient: Patient = StorageService.shared.fetchOrCreatePatient(phn: model.phn, name: model.name, birthday: birthdate) else {
            Logger.log(string: "**Could not fetch or create patent to store vaccine card", type: .storage)
            return completion()
        }
        StorageService.shared.storeVaccineCard(vaccineQR: model.code, name: model.name, issueDate: Date(timeIntervalSince1970: model.issueDate), hash: model.hash, patient: patient, authenticated: authenticated, federalPass: model.fedCode, vaxDates: model.vaxDates, sortOrder: sortOrder, completion: {_ in completion()})
    }
    
    func updateCardInLocalStorage(model: LocallyStoredVaccinePassportModel, authenticated: Bool = false, completion: @escaping(Bool)->Void) {
        StorageService.shared.updateVaccineCard(newData: model, authenticated: authenticated, completion: {[weak self] card in
            guard let `self` = self else {return}
            if card != nil {
                self.showBanner(message: .updatedCard, style: .Top)
            } else {
                self.alert(title: .error, message: .updateCardFailed)
            }
            completion(true)
        })
    }
    
    func updateFedCodeForCardInLocalStorage(model: LocallyStoredVaccinePassportModel, completion: @escaping(Bool)->Void) {
        guard let card = StorageService.shared.fetchVaccineCard(code: model.code), let fedCode = model.fedCode else {return}
        StorageService.shared.updateVaccineCard(card: card, federalPass: fedCode, completion: {[weak self] card in
            guard let `self` = self else {return}
            if card != nil {
                self.showBanner(message: .updatedCard, style: .Top)
            } else {
                self.alert(title: .error, message: .updateCardFailed)
            }
            completion(true)
        })
    }
    
    func convertScanResultModelIntoLocalData(data: ScanResultModel, source: Source) -> LocallyStoredVaccinePassportModel {
        return data.toLocal(source: source)
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

// MARK: Notification Center posting
extension UIViewController {
    func postCardAddedNotification(id: String) {
        NotificationCenter.default.post(name: .cardAddedNotification, object: nil, userInfo: ["id": id])
    }
}

// MARK: GoTo Health Gateway Logic
extension UIViewController {
    // Note: This is currently only being used for fetching fed pass only
    // TODO: May need to be refactored in the future if we use this function anywhere else
    func goToHealthGateway(fetchType: GatewayFormViewControllerFetchType, source: GatewayFormSource, owner: UIViewController, completion: ((String?) -> Void)?) {
        var rememberDetails = RememberedGatewayDetails(storageArray: nil)
        if let details = Defaults.rememberGatewayDetails {
            rememberDetails = details
        }
        
        let vc = GatewayFormViewController.constructGatewayFormViewController(rememberDetails: rememberDetails, fetchType: fetchType)
        if fetchType.isFedPassOnly {
            vc.completionHandler = { [weak self] details in
                DispatchQueue.main.async {
                    if let fedPass = details.fedPassId {
                        self?.openPDFView(pdfString: fedPass, vc: owner, id: details.id, type: .fedPass, completion: completion)
                    } else {
                        self?.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: Open PDF (used for federal pass and other PDF views)
extension UIViewController {
    func openPDFView(pdfString: String, vc: UIViewController, id: String?, type: PDFType?, completion: ((String?) -> Void)?) {
        guard let data = Data(base64URLEncoded: pdfString) else {
            return
        }
        let pdfView: AppPDFView = AppPDFView.fromNib()
        pdfView.show(data: data, in: vc.parent ?? vc, id: id, type: type)
        pdfView.completionHandler = completion
    }
}
