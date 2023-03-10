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
            if let presentedVC = self.presentedViewController {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.present(controller, animated: true)
                }
            } else {
                self.present(controller, animated: true)
            }
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
    
    // MARK: Local Auth
    func showLocalAuth(onSuccess: @escaping()->Void) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {return}
            if let parent = self.parent as? CustomNavigationController {
                parent.showLocalAuth(onSuccess: onSuccess)
                return
            }
            if let parent = self.parent as? AppTabBarController {
                parent.showLocalAuth(onSuccess: onSuccess)
                return
            }
            if !LocalAuthManager.shouldAuthenticate {return}
            
            LocalAuthManager.shared.performLocalAuth(on: self) { [weak self] status in
                switch status {
                case .Authorized:
                    onSuccess()
                    self?.localAuthSucceded()
                    self?.checkForAppStoreVersionUpdate()
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
        if let parent = self.parent as? AppTabBarController {
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
                          patientAPI: AuthenticatedPatientDetailsResponseObject? = nil,
                          manuallyAdded: Bool,
                          completion: @escaping(CoreDataReturnObject)->Void
    ) {
        let birthdate =  Date.Formatter.yearMonthDay.date(from: model.birthdate) ?? Date()
        let name = patientAPI?.getFullName ?? model.name
        guard let patient: Patient = StorageService.shared.fetchOrCreatePatient(phn: model.phn,
                                                                                name: name,
                                                                                firstName: "",
                                                                                lastName: "",
                                                                                gender: "",
                                                                                birthday: birthdate,
                                                                                physicalAddress: nil,
                                                                                mailingAddress: nil,
                                                                                hdid: nil,
                                                                                authenticated: authenticated)
        else {
            Logger.log(string: "**Could not fetch or create patent to store vaccine card", type: .storage)
            return completion(CoreDataReturnObject(id: model.id, patient: nil))
        }
        StorageService.shared.storeVaccineCard(vaccineQR: model.code, name: model.name, issueDate: Date(timeIntervalSince1970: model.issueDate), hash: model.hash, patient: patient, authenticated: authenticated, federalPass: model.fedCode, vaxDates: model.vaxDates, sortOrder: sortOrder, manuallyAdded: manuallyAdded, completion: { card in
            completion(CoreDataReturnObject(id: card?.id, patient: patient))
        })
    }
    
    func updateCardInLocalStorage(model: LocallyStoredVaccinePassportModel, authenticated: Bool = false, patientAPI: AuthenticatedPatientDetailsResponseObject? = nil, manuallyAdded: Bool, completion: @escaping(CoreDataReturnObject)->Void) {
        StorageService.shared.updateVaccineCard(newData: model, authenticated: authenticated, patient: patientAPI, manuallyAdded: manuallyAdded, completion: {[weak self] card in
            guard let `self` = self else {return}
            if card != nil {
                self.showToast(message: .updatedCard)
            } else {
                self.alert(title: .error, message: .updateCardFailed)
            }
            completion(CoreDataReturnObject(id: card?.id, patient: card?.patient))
        })
    }
    
    func updateFedCodeForCardInLocalStorage(model: LocallyStoredVaccinePassportModel, manuallyAdded: Bool, completion: @escaping(CoreDataReturnObject)->Void) {
        guard let card = StorageService.shared.fetchVaccineCard(code: model.code), let fedCode = model.fedCode else {return}
        StorageService.shared.updateVaccineCard(card: card, federalPass: fedCode, manuallyAdded: manuallyAdded, completion: {[weak self] card in
            guard let `self` = self else {return}
            if card != nil {
                self.showToast(message: .updatedCard)
            } else {
                self.alert(title: .error, message: .updateCardFailed)
            }
            completion(CoreDataReturnObject(id: card?.id, patient: card?.patient))
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
//    func postCardAddedNotification(id: String) {
//        NotificationCenter.default.post(name: .cardAddedNotification, object: nil, userInfo: ["id": id])
//    }
    
//    func postOpenPDFFromAddingFedPassOnlyNotification(pass: String, source: GatewayFormSource) {
//        NotificationCenter.default.post(name: .fedPassOnlyAdded, object: nil, userInfo: ["pass": pass, "source": source])
//    }
}

// MARK: Open PDF (used for federal pass and other PDF views)
// FIXME: Can likely remove this as we shouldn't need to use custom PDF view anymore
//extension UIViewController {
//    func openPDFView(pdfString: String, vc: UIViewController, id: String?, type: PDFType?, completion: ((String?) -> Void)?) {
//        guard let data = Data(base64URLEncoded: pdfString) else {
//            return
//        }
//        let pdfView: AppPDFView = AppPDFView.fromNib()
//        pdfView.show(data: data, in: vc.parent ?? vc, id: id, type: type)
//        pdfView.completionHandler = completion
//    }
//}

// MARK: Logic to open pdf natively
extension UIViewController {
    
    func showPDFDocument(pdfString: String, navTitle: String, documentVCDelegate: UIViewController, navDelegate: NavigationSetupProtocol?) {
        guard let data = Data(base64URLEncoded: pdfString) else { return }
        removePDFFromFileSystem()
        do {
            try savePdf(pdfData: data)
            loadPDFAndShare(documentVCDelegate: documentVCDelegate, name: navTitle, navDelegate: navDelegate)
        } catch {
            print("Couldn't load PDF view")
        }
    }
    
    private func savePdf(pdfData: Data) throws {
        let documentsURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let pdfDocURL = documentsURL.appendingPathComponent(Constants.PDFDocumentName.name)
        try pdfData.write(to: pdfDocURL)
    }

    private func loadPDFAndShare(documentVCDelegate: UIViewController, name: String, navDelegate: NavigationSetupProtocol?) {
        do {
            let documentsURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let pdfDocURL = documentsURL.appendingPathComponent(Constants.PDFDocumentName.name)
            self.tabBarController?.tabBar.isHidden = true
            let documentVC = UIDocumentInteractionController()
            documentVC.url = pdfDocURL
            documentVC.uti = pdfDocURL.uti
            documentVC.name = name
            documentVC.delegate = documentVCDelegate as? UIDocumentInteractionControllerDelegate
            navDelegate?.adjustNavStyleForPDF(targetVC: documentVCDelegate)
            documentVC.presentPreview(animated: true)
        } catch  {
            print("document was not found")
        }
      }
    
    private func removePDFFromFileSystem() {
        do {
            let fileManager = FileManager.default
            let documentsURL = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let pdfDocURL = documentsURL.appendingPathComponent(Constants.PDFDocumentName.name)
            try fileManager.removeItem(at: pdfDocURL)
            print("document deleted properly")
        } catch  {
            print("document was not deleted")
        }
    }
}
