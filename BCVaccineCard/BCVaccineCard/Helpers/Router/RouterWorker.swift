//
//  RouterWorker.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2022-04-20.


// Rules are - Use router worker to construct the nav stack
// Use Storage changes to adjust screen state on a given screen (storage change should not pop or push or adjust nav stack on its own)

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
    case InitialAppLaunch
    case AuthenticatedFetch(actioningPatient: Patient?, recentlyAddedCardId: String?)
//    case SessionExpiredAuthenticatedFetch(actioningPatient: Patient)
    case ManualFetch(actioningPatient: Patient?, addedRecord: HealthRecordsDetailDataSource)
    case ManuallyDeletedAllOfAnUnauthPatientRecords
    case Logout(currentTab: TabBarVCs)
//    case SessionExpired(actioningPatient: Patient)
//    case InitialProtectedMedicalRecordsFetch(actioningPatient: Patient)
    case ClearAllData(currentTab: TabBarVCs)
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
    
    public func routingAction(scenario: AppUserActionScenarios) {
        let recordsStack = setupHealthRecordsNavStackForScenario(scenario: scenario)
        self.delegate?.recordsActionScenario(viewControllerStack: recordsStack)
        let passesStack = setupHealthPassNavStackForScenario(scenario: scenario)
        self.delegate?.passesActionScenario(viewControllerStack: passesStack)
    }
}

// MARK: Nav stack setup Health Records
extension RouterWorker {
    private func setupHealthRecordsNavStackForScenario(scenario: AppUserActionScenarios) -> [UIViewController] {
        switch scenario {
        case .InitialAppLaunch:
            return initialAppLaunchRecordsStack()
        case .AuthenticatedFetch(let actioningPatient, let _):
            return authenticatedFetchRecordsStack(actioningPatient: actioningPatient)
//        case .SessionExpiredAuthenticatedFetch(actioningPatient: let actioningPatient):
//            return sessionExpiredAuthFetch(actioningPatient: actioningPatient)
        case .ManualFetch(let actioningPatient, let addedRecord):
            return manualUnauthFetchRecordsStack(actioningPatient: actioningPatient, addedRecord: addedRecord)
        case .ManuallyDeletedAllOfAnUnauthPatientRecords:
            return manuallyDeletedAllUnauthPatientRecordsForPatientRecordsStack()
        case .Logout(let currentTab):
            return manualLogOutRecordsStack(currentTab: currentTab)
//        case .SessionExpired(let actioningPatient):
//            <#code#>
//        case .InitialProtectedMedicalRecordsFetch(let actioningPatient):
//            <#code#>
        case .ClearAllData(let currentTab):
            return self.clearAllDataRecordsStack(currentTab: currentTab)
        }
    }
    
    private func initialAppLaunchRecordsStack() -> [UIViewController] {
        switch self.currentPatientScenario {
        case .NoUsers:
            let vc = FetchHealthRecordsViewController.constructFetchHealthRecordsViewController(hideNavBackButton: true, showSettingsIcon: true, hasHealthRecords: false, completion: {})
            return [vc]
        case .OneAuthUser:
            guard let patient = self.getAuthenticatedPatient else {
                let vc = FetchHealthRecordsViewController.constructFetchHealthRecordsViewController(hideNavBackButton: true, showSettingsIcon: true, hasHealthRecords: false, completion: {})
                return [vc]
            }
            let vc = UsersListOfRecordsViewController.constructUsersListOfRecordsViewController(patient: patient, authenticated: true, navStyle: .singleUser, hasUpdatedUnauthPendingTest: false)
            return [vc]
        case .OneUnauthUser:
            guard let patient = self.getUnathenticatedPatients?.first else {
                let vc = FetchHealthRecordsViewController.constructFetchHealthRecordsViewController(hideNavBackButton: true, showSettingsIcon: true, hasHealthRecords: false, completion: {})
                return [vc]
            }
            let vc = UsersListOfRecordsViewController.constructUsersListOfRecordsViewController(patient: patient, authenticated: false, navStyle: .singleUser, hasUpdatedUnauthPendingTest: false)
            return [vc]
        case .MoreThanOneUnauthUser, .OneAuthUserAndOneUnauthUser, .OneAuthUserAndMoreThanOneUnauthUser:
            let vc = HealthRecordsViewController.constructHealthRecordsViewController()
            return [vc]
        }
    }
    
    private func authenticatedFetchRecordsStack(actioningPatient patient: Patient?) -> [UIViewController] {
        switch self.currentPatientScenario {
        case .NoUsers, .OneUnauthUser, .MoreThanOneUnauthUser:
            // Not possible here - after an authFetch, there has to be at least one Auth user, so do nothing
            return []
        case .OneAuthUser:
            // Stack should be UsersListOfRecordsViewController (after fetch is completed)
            // Note - hasUpdatedUnauthPendingTest is irrelevant here
            guard let patient = patient else { return [] }
            let vc = UsersListOfRecordsViewController.constructUsersListOfRecordsViewController(patient: patient, authenticated: true, navStyle: .singleUser, hasUpdatedUnauthPendingTest: true)
            return [vc]
        case .OneAuthUserAndOneUnauthUser, .OneAuthUserAndMoreThanOneUnauthUser:
            // Stack should be HealthRecordsViewController, then UsersListOfRecordsViewController (after fetch is completed)
            // Note - setting hasUpdatedUnauthPendingTest to false just in case unauth user has to check for background update for pending covid test
            let vc1 = HealthRecordsViewController.constructHealthRecordsViewController()
            guard let patient = patient else { return [vc1] }
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
    
    private func manualUnauthFetchRecordsStack(actioningPatient patient: Patient?, addedRecord record: HealthRecordsDetailDataSource) -> [UIViewController] {
        switch self.currentPatientScenario {
        case .NoUsers, .OneAuthUser:
            // Not possible here - after a successful manual fetch, there has to be at least 1 unauth patient
            return []
        case .OneUnauthUser:
            // Stack should be UsersListOfRecordsViewController, then HealthRecordDetailViewController
            guard let patient = patient else { return [] }
            let vc1 = UsersListOfRecordsViewController.constructUsersListOfRecordsViewController(patient: patient, authenticated: false, navStyle: .singleUser, hasUpdatedUnauthPendingTest: false)
            let recordsCount = StorageService.shared.getHeathRecords().detailDataSource(patient: patient).count
            let vc2 = HealthRecordDetailViewController.constructHealthRecordDetailViewController(dataSource: record, authenticatedRecord: false, userNumberHealthRecords: recordsCount)
            return [vc1, vc2]
        case .MoreThanOneUnauthUser, .OneAuthUserAndOneUnauthUser, .OneAuthUserAndMoreThanOneUnauthUser:
            // Stack should be HealthRecordsViewController, UsersListOfRecordsViewController, then HealthRecordDetailViewController
            let vc1 = HealthRecordsViewController.constructHealthRecordsViewController()
            guard let patient = patient else { return [vc1] }
            let authenticated = self.currentPatientScenario == .MoreThanOneUnauthUser ? false : true
            let vc2 = UsersListOfRecordsViewController.constructUsersListOfRecordsViewController(patient: patient, authenticated: authenticated, navStyle: .multiUser, hasUpdatedUnauthPendingTest: false)
            let recordsCount = StorageService.shared.getHeathRecords().detailDataSource(patient: patient).count
            let vc3 = HealthRecordDetailViewController.constructHealthRecordDetailViewController(dataSource: record, authenticatedRecord: false, userNumberHealthRecords: recordsCount)
            return [vc1, vc2, vc3]
        }
    }
    
    private func manuallyDeletedAllUnauthPatientRecordsForPatientRecordsStack() -> [UIViewController] {
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
    
    private func manualLogOutRecordsStack(currentTab: TabBarVCs) -> [UIViewController] {
        // Note - this is a unique case as we need to reset the stack in some cases, but still need to show the same screen
        switch self.currentPatientScenario {
        case .NoUsers:
            let vc1 = FetchHealthRecordsViewController.constructFetchHealthRecordsViewController(hideNavBackButton: true, showSettingsIcon: true, hasHealthRecords: false, completion: {})
            guard currentTab == .records else { return [vc1] }
            let vc2 = ProfileAndSettingsViewController.constructProfileAndSettingsViewController()
            return [vc1, vc2]
        case .OneAuthUser, .OneAuthUserAndOneUnauthUser, .OneAuthUserAndMoreThanOneUnauthUser:
            // This isn't possible - after logout, there is no auth user
            return []
        case .OneUnauthUser:
            guard let remainingUnauthPatient = self.getUnathenticatedPatients?.first else { return [] }
            let vc1 = UsersListOfRecordsViewController.constructUsersListOfRecordsViewController(patient: remainingUnauthPatient, authenticated: false, navStyle: .singleUser, hasUpdatedUnauthPendingTest: false)
            guard currentTab == .records else { return [vc1] }
            let vc2 = ProfileAndSettingsViewController.constructProfileAndSettingsViewController()
            return [vc1, vc2]
        case .MoreThanOneUnauthUser:
            let vc1 = HealthRecordsViewController.constructHealthRecordsViewController()
            guard currentTab == .records else { return [vc1] }
            let vc2 = ProfileAndSettingsViewController.constructProfileAndSettingsViewController()
            return [vc1, vc2]
        }
    }
    
    private func clearAllDataRecordsStack(currentTab: TabBarVCs) -> [UIViewController] {
        let vc1 = FetchHealthRecordsViewController.constructFetchHealthRecordsViewController(hideNavBackButton: true, showSettingsIcon: true, hasHealthRecords: false, completion: {})
        guard currentTab == .records else { return [vc1] }
        let vc2 = ProfileAndSettingsViewController.constructProfileAndSettingsViewController()
        return [vc1, vc2]
    }
    
}

// MARK: Nav stack setup Health Records
extension RouterWorker {
    private func setupHealthPassNavStackForScenario(scenario: AppUserActionScenarios) -> [UIViewController] {
        switch scenario {
        case .InitialAppLaunch:
            return initialAppLaunchPassesStack()
        case .AuthenticatedFetch(let _, let recentlyAddedCardId):
            return authenticatedFetchPassesStack(recentlyAddedCardId: recentlyAddedCardId)
        case .ManualFetch(let actioningPatient, let addedRecord):
            <#code#>
        case .ManuallyDeletedAllOfAnUnauthPatientRecords:
            <#code#>
        case .Logout(let currentTab):
            <#code#>
        case .ClearAllData(let currentTab):
            <#code#>
        }
    }
    
    private func initialAppLaunchPassesStack() -> [UIViewController] {
        let vc = HealthPassViewController.constructHealthPassViewController()
        return [vc]
    }
    
    private func authenticatedFetchPassesStack(recentlyAddedCardId: String?) -> [UIViewController] {
        switch self.currentPatientScenario {
        case .NoUsers, .OneUnauthUser, .MoreThanOneUnauthUser:
            // Not possible here - after an authFetch, there has to be at least one Auth user, so do nothing
            return []
        case .OneAuthUser:
            // Stack should be UsersListOfRecordsViewController (after fetch is completed)
            // Note - hasUpdatedUnauthPendingTest is irrelevant here
            let vc = HealthPassViewController.constructHealthPassViewController()
            return [vc]
        case .OneAuthUserAndOneUnauthUser, .OneAuthUserAndMoreThanOneUnauthUser:
            // Stack should be HealthRecordsViewController, then UsersListOfRecordsViewController (after fetch is completed)
            // Note - setting hasUpdatedUnauthPendingTest to false just in case unauth user has to check for background update for pending covid test
            let vc1 = HealthPassViewController.constructHealthPassViewController()
            let vc2 = CovidVaccineCardsViewController.constructCovidVaccineCardsViewController(recentlyAddedCardId: recentlyAddedCardId)
            return [vc1, vc2]
        }
    }
    
    private func manualUnauthFetchPassessStack(actioningPatient patient: Patient, addedRecord record: HealthRecordsDetailDataSource) -> [UIViewController] {
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
    
    private func manuallyDeletedAllUnauthPatientRecordsForPatientPassesStack() -> [UIViewController] {
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
    
    private func manualLogOutPassesStack(currentTab: TabBarVCs) -> [UIViewController] {
        // Note - this is a unique case as we need to reset the stack in some cases, but still need to show the same screen
        switch self.currentPatientScenario {
        case .NoUsers:
            let vc1 = FetchHealthRecordsViewController.constructFetchHealthRecordsViewController(hideNavBackButton: true, showSettingsIcon: true, hasHealthRecords: false, completion: {})
            guard currentTab == .records else { return [vc1] }
            let vc2 = ProfileAndSettingsViewController.constructProfileAndSettingsViewController()
            return [vc1, vc2]
        case .OneAuthUser, .OneAuthUserAndOneUnauthUser, .OneAuthUserAndMoreThanOneUnauthUser:
            // This isn't possible - after logout, there is no auth user
            return []
        case .OneUnauthUser:
            guard let remainingUnauthPatient = self.getUnathenticatedPatients?.first else { return [] }
            let vc1 = UsersListOfRecordsViewController.constructUsersListOfRecordsViewController(patient: remainingUnauthPatient, authenticated: false, navStyle: .singleUser, hasUpdatedUnauthPendingTest: false)
            guard currentTab == .records else { return [vc1] }
            let vc2 = ProfileAndSettingsViewController.constructProfileAndSettingsViewController()
            return [vc1, vc2]
        case .MoreThanOneUnauthUser:
            let vc1 = HealthRecordsViewController.constructHealthRecordsViewController()
            guard currentTab == .records else { return [vc1] }
            let vc2 = ProfileAndSettingsViewController.constructProfileAndSettingsViewController()
            return [vc1, vc2]
        }
    }
    
    private func clearAllDataPassesStack(currentTab: TabBarVCs) -> [UIViewController] {
        let vc1 = HealthPassViewController.constructHealthPassViewController()
        guard currentTab == .healthPass else { return [vc1] }
        let vc2 = ProfileAndSettingsViewController.constructProfileAndSettingsViewController()
        return [vc1, vc2]
    }
    
}
