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
    func alert(title: String, message: String) {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: "OK", style: .default))
        DispatchQueue.main.async {
            self.present(controller, animated: true)
        }
    }
    
    func alert(title: String, message: String, completion: @escaping()->Void) {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            return completion()
        }))
        DispatchQueue.main.async {
            self.present(controller, animated: true)
        }
    }
    
    func alert(title: String, message: String, buttonOneTitle: String, buttonOneCompletion: @escaping()->Void, buttonTwoTitle: String?, buttonTwoCompletion: @escaping()->Void) {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
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
    
    func showBanner(message: String) {
        // padding Constants
        let textPadding: CGFloat = Constants.UI.Banner.labelPadding
        let containerPadding: CGFloat = Constants.UI.Banner.containerPadding
        
        // Create label and container
        let container = UIView(frame: .zero)
        let label = UILabel(frame: .zero)
        
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
        
        // Position container
        container.translatesAutoresizingMaskIntoConstraints = false
        container.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0 - containerPadding).isActive = true
        container.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: containerPadding).isActive = true
        container.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0 - containerPadding).isActive = true
        let messageHeight = message.heightForView(font: Constants.UI.Banner.labelFont, width: container.bounds.width)
        container.heightAnchor.constraint(equalToConstant: messageHeight + (textPadding * 2)).isActive = true
        
        // Position Label
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: 0 - textPadding).isActive = true
        label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: textPadding).isActive = true
        label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: 0 - textPadding).isActive = true
        label.topAnchor.constraint(equalTo: container.topAnchor, constant: textPadding).isActive = true
        
        // Style
        label.text = message
        label.textAlignment = .center
        label.font = Constants.UI.Banner.labelFont
        label.textColor = Constants.UI.Banner.labelColor
        container.backgroundColor = Constants.UI.Banner.backgroundColor
        container.layer.cornerRadius = Constants.UI.Theme.cornerRadius
        
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
    
    func hideBanner() {
        guard let banner = view.viewWithTag(Constants.UI.Banner.tag) else {
            return
        }
        UIView.animate(withDuration: Constants.UI.Theme.animationDuration) {
            banner.alpha = 0
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
        if Defaults.vaccinePassports == nil {
            Defaults.vaccinePassports = []
            Defaults.vaccinePassports?.append(model)
        } else {
            Defaults.vaccinePassports?.append(model)
        }
    }
    
    func convertScanResultModelIntoLocalData(data: ScanResultModel) -> LocallyStoredVaccinePassportModel {
        let status = VaccineStatus.init(rawValue: data.status.rawValue) ?? .notVaxed
        return LocallyStoredVaccinePassportModel(code: data.code, birthdate: data.birthdate, name: data.name, status: status)
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
}

// MARK: Check for duplicates - again, should probably find a better spot for this
extension UIViewController {
    func isCardAlreadyInWallet(modelToAdd model: AppVaccinePassportModel) -> Bool {
        guard let localDS = Defaults.vaccinePassports, !localDS.isEmpty else { return false }
        let appDS = localDS.map { $0.transform() }
        let idArray = appDS.compactMap({ $0.id })
        guard let id = model.id else { return false } // May need some form of error handling here, as this just means the new model is incomplete
        guard idArray.firstIndex(where: { $0 == id }) == nil else { return true }
        return false
    }
}
