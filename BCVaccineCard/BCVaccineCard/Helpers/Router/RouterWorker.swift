//
//  RouterWorker.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2022-04-20.

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
// Note for Developer: AppUserActionScenarios should be called at the completion of the action in question (after core data changes)
enum AppUserActionScenarios {
    case InitialAppLaunch(actioningPatient: Patient)
    case AuthenticatedFetch(actioningPatient: Patient)
//    case SessionExpiredAuthenticatedFetch(actioningPatient: Patient)
    case ManualFetch(actioningPatient: Patient, addedRecord: HealthRecordsDetailDataSource)
    case ManuallyDeletedAllOfThisUnauthPatientRecords(actioningPatient: Patient)
    case Logout(actioningPatient: Patient, isOnHealthRecordsTab: Bool)
//    case SessionExpired(actioningPatient: Patient)
//    case InitialProtectedMedicalRecordsFetch(actioningPatient: Patient)
    case ClearAllData(actioningPatient: Patient, isOnHealthRecordsTab: Bool)
}

protocol RouterWorkerDelegate: AnyObject  {
    func recordsActionScenario(viewControllerStack: [UIViewController])
    func passesActionScenario(viewControllerStack: [UIViewController])
}

class RouterWorker: NSObject {
    
    weak private var delegate: RouterWorkerDelegate?
    
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
        self.delegate = delegateOwner as? RouterWorkerDelegate
    }
    
    public func healthRecordsAction(scenario: AppUserActionScenarios) {
        let stack = setupHealthRecordsNavStackForScenario(scenario: scenario)
        self.delegate?.recordsActionScenario(viewControllerStack: stack)
    }
    
    public func healthPassAction(scenario: AppUserActionScenarios) {
        // TODO: Nav stack setup for health passes here
//        let stack = setupHealthPassNavStackForScenario(scenario: scenario)
//        self.delegate?.passesActionScenario(viewControllerStack: stack)
    }
}

// Nav stack setup
extension RouterWorker {
    private func setupHealthRecordsNavStackForScenario(scenario: AppUserActionScenarios) -> [UIViewController] {
        switch scenario {
        case .InitialAppLaunch(let actioningPatient):
            return initialAppLaunchStack(actioningPatient: actioningPatient)
        case .AuthenticatedFetch(let actioningPatient):
            return authenticatedFetch(actioningPatient: actioningPatient)
//        case .SessionExpiredAuthenticatedFetch(actioningPatient: let actioningPatient):
//            return sessionExpiredAuthFetch(actioningPatient: actioningPatient)
        case .ManualFetch(let actioningPatient, let addedRecord):
            return manualUnauthFetch(actioningPatient: actioningPatient, addedRecord: addedRecord)
        case .ManuallyDeletedAllOfThisUnauthPatientRecords(let actioningPatient):
            return manuallyDeletedAllUnauthPatientRecordsForPatient(actioningPatient: actioningPatient)
        case .Logout(let actioningPatient, let isOnHealthRecordsTab):
            return manualLogOut(actioningPatient: actioningPatient, isOnHealthRecordsTab: isOnHealthRecordsTab)
//        case .SessionExpired(let actioningPatient):
//            <#code#>
//        case .InitialProtectedMedicalRecordsFetch(let actioningPatient):
//            <#code#>
        case .ClearAllData(let actioningPatient, let isOnHealthRecordsTab):
            return self.clearAllData(actioningPatient: actioningPatient, isOnHealthRecordsTab: isOnHealthRecordsTab)
        }
    }
    
    private func initialAppLaunchStack(actioningPatient patient: Patient) -> [UIViewController] {
        switch self.currentPatientScenario {
        case .NoUsers:
            let vc = FetchHealthRecordsViewController.constructFetchHealthRecordsViewController(hideNavBackButton: true, showSettingsIcon: true, hasHealthRecords: false, completion: {})
            return [vc]
        case .OneAuthUser:
            let vc = UsersListOfRecordsViewController.constructUsersListOfRecordsViewController(patient: patient, authenticated: true, navStyle: .singleUser, hasUpdatedUnauthPendingTest: false)
            return [vc]
        case .OneUnauthUser:
            let vc = UsersListOfRecordsViewController.constructUsersListOfRecordsViewController(patient: patient, authenticated: false, navStyle: .singleUser, hasUpdatedUnauthPendingTest: false)
            return [vc]
        case .MoreThanOneUnauthUser, .OneAuthUserAndOneUnauthUser, .OneAuthUserAndMoreThanOneUnauthUser:
            let vc = HealthRecordsViewController.constructHealthRecordsViewController()
            return [vc]
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
    
//    private func sessionExpiredAuthFetch(actioningPatient patient: Patient) -> [UIViewController] {
//        switch self.currentPatientScenario {
//        case .NoUsers, .OneUnauthUser, .MoreThanOneUnauthUser:
//            // Not possible here - for a session to expire, there has to be an authenticed user, so do nothing
//            return []
//        case .OneAuthUser:
//            // Stack should be UsersListOfRecordsViewController (after fetch is completed)
//            // Note - hasUpdatedUnauthPendingTest is irrelevant here
//            let vc = UsersListOfRecordsViewController.constructUsersListOfRecordsViewController(patient: patient, authenticated: true, navStyle: .singleUser, hasUpdatedUnauthPendingTest: true)
//            return [vc]
//        case .OneAuthUserAndOneUnauthUser, .OneAuthUserAndMoreThanOneUnauthUser:
//            // Stack should be HealthRecordsViewController, then UsersListOfRecordsViewController (after fetch is completed)
//            // Note - setting hasUpdatedUnauthPendingTest to false just in case unauth user has to check for background update for pending covid test
//            let vc1 = HealthRecordsViewController.constructHealthRecordsViewController()
//            let vc2 = UsersListOfRecordsViewController.constructUsersListOfRecordsViewController(patient: patient, authenticated: true, navStyle: .multiUser, hasUpdatedUnauthPendingTest: false)
//            return [vc1, vc2]
//        }
//    }
    
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
            // Stack should be HealthRecordsViewController, UsersListOfRecordsViewController, then HealthRecordDetailViewController
            let vc1 = HealthRecordsViewController.constructHealthRecordsViewController()
            let authenticated = self.currentPatientScenario == .MoreThanOneUnauthUser ? false : true
            let vc2 = UsersListOfRecordsViewController.constructUsersListOfRecordsViewController(patient: patient, authenticated: authenticated, navStyle: .multiUser, hasUpdatedUnauthPendingTest: false)
            let recordsCount = StorageService.shared.getHeathRecords().detailDataSource(patient: patient).count
            let vc3 = HealthRecordDetailViewController.constructHealthRecordDetailViewController(dataSource: record, authenticatedRecord: false, userNumberHealthRecords: recordsCount)
            return [vc1, vc2, vc3]
        }
    }
    
    private func manuallyDeletedAllUnauthPatientRecordsForPatient(actioningPatient patient: Patient) -> [UIViewController] {
        switch self.currentPatientScenario {
        case .NoUsers:
            // In this case, show initial fetch screen - stack should be FetchHealthRecordsViewController
            let vc = FetchHealthRecordsViewController.constructFetchHealthRecordsViewController(hideNavBackButton: true, showSettingsIcon: true, hasHealthRecords: false, completion: {})
            return [vc]
        case .OneAuthUser:
            // This means that we have removed the only other unauth user and should show the auth user records by default UsersListOfRecordsViewController
            // Note - hasUpdatedUnauthPendingTest doesnt matter here
            guard let remainingAuthPatient = self.getAuthenticatedPatient else { return [] }
            let vc = UsersListOfRecordsViewController.constructUsersListOfRecordsViewController(patient: remainingAuthPatient, authenticated: true, navStyle: .singleUser, hasUpdatedUnauthPendingTest: false)
            return [vc]
        case .OneUnauthUser:
            // This means that we have removed an unauth user and should show the remaining unauth user records by default UsersListOfRecordsViewController
            // Note - hasUpdatedUnauthPendingTest should be false here, to make sure that pending covid test result can be fetched in the background, just in case an update is required
            guard let remainingUnauthPatient = self.getUnathenticatedPatients?.first else { return [] }
            let vc = UsersListOfRecordsViewController.constructUsersListOfRecordsViewController(patient: remainingUnauthPatient, authenticated: false, navStyle: .singleUser, hasUpdatedUnauthPendingTest: false)
            return [vc]
        case .MoreThanOneUnauthUser, .OneAuthUserAndOneUnauthUser, .OneAuthUserAndMoreThanOneUnauthUser:
            // In this case, just show the health records home screen with a list of folders
            let vc = HealthRecordsViewController.constructHealthRecordsViewController()
            return [vc]
        }
    }
    
    private func manualLogOut(actioningPatient patient: Patient, isOnHealthRecordsTab: Bool) -> [UIViewController] {
        // Note - this is a unique case as we need to reset the stack in some cases, but still need to show the same screen
        switch self.currentPatientScenario {
        case .NoUsers:
            let vc1 = FetchHealthRecordsViewController.constructFetchHealthRecordsViewController(hideNavBackButton: true, showSettingsIcon: true, hasHealthRecords: false, completion: {})
            guard isOnHealthRecordsTab else { return [vc1] }
            let vc2 = ProfileAndSettingsViewController.constructProfileAndSettingsViewController()
            return [vc1, vc2]
        case .OneAuthUser, .OneAuthUserAndOneUnauthUser, .OneAuthUserAndMoreThanOneUnauthUser:
            // This isn't possible - after logout, there is no auth user
            return []
        case .OneUnauthUser:
            guard let remainingUnauthPatient = self.getUnathenticatedPatients?.first else { return [] }
            let vc1 = UsersListOfRecordsViewController.constructUsersListOfRecordsViewController(patient: remainingUnauthPatient, authenticated: false, navStyle: .singleUser, hasUpdatedUnauthPendingTest: false)
            guard isOnHealthRecordsTab else { return [vc1] }
            let vc2 = ProfileAndSettingsViewController.constructProfileAndSettingsViewController()
            return [vc1, vc2]
        case .MoreThanOneUnauthUser:
            let vc1 = HealthRecordsViewController.constructHealthRecordsViewController()
            guard isOnHealthRecordsTab else { return [vc1] }
            let vc2 = ProfileAndSettingsViewController.constructProfileAndSettingsViewController()
            return [vc1, vc2]
        }
    }
    
    private func clearAllData(actioningPatient patient: Patient, isOnHealthRecordsTab: Bool) -> [UIViewController] {
        let vc1 = FetchHealthRecordsViewController.constructFetchHealthRecordsViewController(hideNavBackButton: true, showSettingsIcon: true, hasHealthRecords: false, completion: {})
        guard isOnHealthRecordsTab else { return [vc1] }
        let vc2 = ProfileAndSettingsViewController.constructProfileAndSettingsViewController()
        return [vc1, vc2]
    }
    
}

// Rules are - Use router worker to construct the nav stack
// Use Storage changes to adjust screen state on a given screen (storage change should not pop or push or adjust nav stack on its own)
