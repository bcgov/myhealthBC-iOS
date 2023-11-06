//
//  class BaseDependentViewController() {      class BaseDependentViewController() {      BaseDependentViewController.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2022-11-01.
//
// FIXME: NEED TO LOCALIZE 
import UIKit

class BaseDependentViewController: BaseViewController {

    let networkService = DependentService(network: AFNetwork(), authManager: AuthManager(), configService: MobileConfigService(network: AFNetwork()))
    
    func delete(dependent: Dependent, completion: @escaping(_ confirmed: Bool) -> Void) {
        guard NetworkConnection.shared.hasConnection else {
            alert(title: "Device is Offline", message: "Please connect to the internet to remove dependents")
            return completion(false)
        }
        
        guard let patient = dependent.guardian else {return completion(false)}
        
        alert(title: .deleteDependentTitle, message: .deleteDependentMessage(name: dependent.info?.firstName ?? ""), buttonOneTitle: .no, buttonOneCompletion: {
            return completion(false)
        }, buttonTwoTitle: .yes) { [weak self] in
            guard let `self` = self else {return}
            self.networkService.delete(dependents: [dependent], for: patient, completion: {success in
                if let cachedIndex =
                    SessionStorage.dependentRecordsFetched.firstIndex(where: {$0.dependencyInfo?.info?.hdid == dependent.info?.hdid}) {
                    SessionStorage.dependentRecordsFetched.remove(at: cachedIndex)
                }
                StorageService.shared.deleteHealthRecordsForDependent(dependent: dependent)
                return completion(true)
            })
        }
    }
 
}
