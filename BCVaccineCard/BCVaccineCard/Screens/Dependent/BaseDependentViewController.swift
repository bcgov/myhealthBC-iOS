//
//  class BaseDependentViewController() {      class BaseDependentViewController() {      BaseDependentViewController.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2022-11-01.
//

import UIKit

class BaseDependentViewController: BaseViewController {

    let networkService = DependentService(network: AFNetwork(), authManager: AuthManager())
    

    func delete(dependent: Dependent, completion: @escaping(_ confirmed: Bool) -> Void) {
        guard NetworkConnection.shared.hasConnection else {
            alert(title: "Device is Offline", message: "Please connect to the internet to remove dependents")
            return completion(false)
        }
        
        guard let patient = dependent.guardian else {return completion(false)}
        
        alertConfirmation(title: .deleteDependentTitle, message: .deleteDependentMessage, confirmTitle: .delete, confirmStyle: .destructive) { [weak self] in
            guard let `self` = self else {return}
            self.networkService.delete(dependents: [dependent], for: patient, completion: {success in
                return completion(true)
            })
        } onCancel: {
            return completion(false)
        }
    }
 
}
