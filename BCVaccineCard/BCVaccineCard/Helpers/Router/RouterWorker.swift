//
//  RouterWorker.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2022-04-20.
//

import UIKit
// Note for Developer: CurrentPatientScenarios are for the result after the action
enum CurrentPatientScenarios {
    case NoUsers
    case OneAuthUser
    case OneUnauthUser
    case MoreThanOneUnauthUser
    case OneAuthUserAndOneUnauthUser
    case OneAuthUserAndMoreThanOneUnauthUser
    
    static func getCurrentScenario(authCount: Int, unauthCount: Int) -> Self {
        if authCount == 0 && unauthCount == 0 {
            return .NoUsers
        } else if authCount == 1 && unauthCount == 0 {
            return .OneAuthUser
        } else if authCount == 0 && unauthCount == 1 {
            return .OneUnauthUser
        } else if authCount == 0 && unauthCount > 1 {
            return .MoreThanOneUnauthUser
        } else if authCount == 1 && unauthCount == 1 {
            return .OneAuthUserAndOneUnauthUser
        } else if authCount == 1 && unauthCount > 1 {
            return .OneAuthUserAndMoreThanOneUnauthUser
        } else {
            return .NoUsers
        }
    }
}
// Note for Developer: HealthRecordsStackActionScenarios should be called at the completion of the action in question (after core data changes)
enum HealthRecordsStackActionScenarios {
    case AuthenticatedFetch(actioningPatient: Patient)
    case SessionExpiredAuthenticatedFetch(actioningPatient: Patient)
    case ManualFetch(actioningPatient: Patient, addedRecord: HealthRecordsDetailDataSource)
    case ManuallyDeletedAllOfThisUnauthPatientRecords(actioningPatient: Patient)
    case Logout(actioningPatient: Patient)
    case SessionExpired(actioningPatient: Patient)
    case InitialProtectedMedicalRecordsFetch(actioningPatient: Patient)
    case ClearAllData(actioningPatient: Patient)
}

protocol HealthRecordsRouterDelegate: AnyObject  {
    func recordsActionScenario(viewControllerStack: [UIViewController])
}

class RouterWorker: NSObject {
    
    weak private var delegate: HealthRecordsRouterDelegate?
    
    private var getAuthenticatedPatient: Patient? {
        return StorageService.shared.fetchAuthenticatedPatient()
    }
    
    private var getUnathenticatedPatients: [Patient]? {
        return StorageService.shared.fetchUnauthenticatedPatients()
    }
    
    private var currentPatientScenario: CurrentPatientScenarios {
        let authPatientCount = StorageService.shared.fetchAuthenticatedPatient() != nil ? 1 : 0
        let unauthPatientsCount = StorageService.shared.fetchUnauthenticatedPatients()?.count ?? 0
        return CurrentPatientScenarios.getCurrentScenario(authCount: authPatientCount, unauthCount: unauthPatientsCount)
    }
    
    init(delegateOwner: UIViewController) {
        self.delegate = delegateOwner as? HealthRecordsRouterDelegate
    }
    
    public func healthRecordsAction(scenario: HealthRecordsStackActionScenarios) {
        let stack = setupNavStackForScenario(scenario: scenario)
        self.delegate?.recordsActionScenario(viewControllerStack: stack)
    }
}

// Nav stack setup
extension RouterWorker {
    private func setupNavStackForScenario(scenario: HealthRecordsStackActionScenarios) -> [UIViewController] {
        // TODO: Delete this once this is implemented
        return []
        
        switch scenario {
        case .AuthenticatedFetch(let actioningPatient):
            return authenticatedFetch(actioningPatient: actioningPatient)
        case .SessionExpiredAuthenticatedFetch(actioningPatient: let actioningPatient):
            return sessionExpiredAuthFetch(actioningPatient: actioningPatient)
        case .ManualFetch(let actioningPatient, let addedRecord):
            return manualUnauthFetch(actioningPatient: actioningPatient, addedRecord: addedRecord)
        case .ManuallyDeletedAllOfThisUnauthPatientRecords(let actioningPatient):
            <#code#>
        case .Logout(let actioningPatient):
            <#code#>
        case .SessionExpired(let actioningPatient):
            <#code#>
        case .InitialProtectedMedicalRecordsFetch(let actioningPatient):
            <#code#>
        case .ClearAllData(let actioningPatient):
            <#code#>
        }
    }
    
    private func authenticatedFetch(actioningPatient patient: Patient) -> [UIViewController] {
        switch self.currentPatientScenario {
        case .NoUsers, .OneUnauthUser, .MoreThanOneUnauthUser:
            // Not possible here - after an authFetch, there has to be at least one Auth user, so do nothing
            return []
        case .OneAuthUser:
            // Stack should be UsersListOfRecordsViewController (after fetch is completed)
            // Note - hasUpdatedUnauthPendingTest is irrelevant here
            let vc = UsersListOfRecordsViewController.constructUsersListOfRecordsViewController(patient: patient, authenticated: true, navStyle: .singleUser, hasUpdatedUnauthPendingTest: true)
            return [vc]
        case .OneAuthUserAndOneUnauthUser, .OneAuthUserAndMoreThanOneUnauthUser:
            // Stack should be HealthRecordsViewController, then UsersListOfRecordsViewController (after fetch is completed)
            // Note - setting hasUpdatedUnauthPendingTest to false just in case unauth user has to check for background update for pending covid test
            let vc1 = HealthRecordsViewController.constructHealthRecordsViewController()
            let vc2 = UsersListOfRecordsViewController.constructUsersListOfRecordsViewController(patient: patient, authenticated: true, navStyle: .multiUser, hasUpdatedUnauthPendingTest: false)
            return [vc1, vc2]
        }
    }
    
    private func sessionExpiredAuthFetch(actioningPatient patient: Patient) -> [UIViewController] {
        switch self.currentPatientScenario {
        case .NoUsers, .OneUnauthUser, .MoreThanOneUnauthUser:
            // Not possible here - for a session to expire, there has to be an authenticed user, so do nothing
            return []
        case .OneAuthUser:
            // Stack should be UsersListOfRecordsViewController (after fetch is completed)
            // Note - hasUpdatedUnauthPendingTest is irrelevant here
            let vc = UsersListOfRecordsViewController.constructUsersListOfRecordsViewController(patient: patient, authenticated: true, navStyle: .singleUser, hasUpdatedUnauthPendingTest: true)
            return [vc]
        case .OneAuthUserAndOneUnauthUser, .OneAuthUserAndMoreThanOneUnauthUser:
            // Stack should be HealthRecordsViewController, then UsersListOfRecordsViewController (after fetch is completed)
            // Note - setting hasUpdatedUnauthPendingTest to false just in case unauth user has to check for background update for pending covid test
            let vc1 = HealthRecordsViewController.constructHealthRecordsViewController()
            let vc2 = UsersListOfRecordsViewController.constructUsersListOfRecordsViewController(patient: patient, authenticated: true, navStyle: .multiUser, hasUpdatedUnauthPendingTest: false)
            return [vc1, vc2]
        }
    }
    
    private func manualUnauthFetch(actioningPatient patient: Patient, addedRecord record: HealthRecordsDetailDataSource) -> [UIViewController] {
        switch self.currentPatientScenario {
        case .NoUsers, .OneAuthUser:
            // Not possible here - after a successful manual fetch, there has to be at least 1 unauth patient
            return []
        case .OneUnauthUser:
            // Stack should be UsersListOfRecordsViewController, then HealthRecordDetailViewController
            let vc1 = UsersListOfRecordsViewController.constructUsersListOfRecordsViewController(patient: patient, authenticated: false, navStyle: .singleUser, hasUpdatedUnauthPendingTest: false)
            let recordsCount = StorageService.shared.getHeathRecords().detailDataSource(patient: patient).count
            let vc2 = HealthRecordDetailViewController.constructHealthRecordDetailViewController(dataSource: record, authenticatedRecord: false, userNumberHealthRecords: recordsCount)
            return [vc1, vc2]
        case .MoreThanOneUnauthUser, .OneAuthUserAndOneUnauthUser, .OneAuthUserAndMoreThanOneUnauthUser:
            let vc1 = HealthRecordsViewController.constructHealthRecordsViewController()
            let authenticated = self.currentPatientScenario == .MoreThanOneUnauthUser ? false : true
            let vc2 = UsersListOfRecordsViewController.constructUsersListOfRecordsViewController(patient: patient, authenticated: authenticated, navStyle: .multiUser, hasUpdatedUnauthPendingTest: false)
            let recordsCount = StorageService.shared.getHeathRecords().detailDataSource(patient: patient).count
            let vc3 = HealthRecordDetailViewController.constructHealthRecordDetailViewController(dataSource: record, authenticatedRecord: false, userNumberHealthRecords: recordsCount)
            return [vc1, vc2, vc3]
        }
    }
    
    private func manuallyDeletedAllUnauthPatientRecordsForPatient(actioningPatient patient: Patient) -> [UIViewController] {
        
    }
}

// Rules are - Use router worker to construct the nav stack
// Use Storage changes to adjust screen state on a given screen (storage change should not pop or push or adjust nav stack on its own)

/* Various cases:
 1.) No users:
 - Existing stack:
 - AuthFetch:
 - ManualFetch:
 - DeletedAllOfThisPatientsRecords:
 - Logout
 - SessionExpired
 - InitialProtectedMedicalRecordsFetch
 
 2.) 1 Auth user:
 - Existing stack:
 - AuthFetch:
 - ManualFetch:
 - DeletedAllOfThisPatientsRecords:
 - Logout
 - SessionExpired
 - InitialProtectedMedicalRecordsFetch
 
 3.) 1 Unauth user:
 - Existing stack:
 - AuthFetch:
 - ManualFetch:
 - DeletedAllOfThisPatientsRecords:
 - Logout
 - SessionExpired
 - InitialProtectedMedicalRecordsFetch
 
 4.) 1 Auth user and 1 Unauth user:
 - Existing stack:
 - AuthFetch:
 - ManualFetch:
 - DeletedAllOfThisPatientsRecords:
 - Logout
 - SessionExpired
 - InitialProtectedMedicalRecordsFetch
*/
