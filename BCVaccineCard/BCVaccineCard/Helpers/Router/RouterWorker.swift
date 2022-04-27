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
    case InitialAppLaunch(affectedTabs: [TabBarVCs])
    case AuthenticatedFetch(actioningPatient: Patient?, recentlyAddedCardId: String?, fedPassStringToOpen: String?)
    case ManualFetch(actioningPatient: Patient?, addedRecord: HealthRecordsDetailDataSource?, recentlyAddedCardId: String?, fedPassStringToOpen: String?, fedPassAddedFromHealthPassVC: Bool?)
    case ManuallyDeletedAllOfAnUnauthPatientRecords(affectedTabs: [TabBarVCs])
    case Logout(currentTab: TabBarVCs)
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
        case .InitialAppLaunch(let affectedTabs):
            return initialAppLaunchRecordsStack(affectedTabs: affectedTabs)
        case .AuthenticatedFetch(let actioningPatient, let _, let _):
            return authenticatedFetchRecordsStack(actioningPatient: actioningPatient)
        case .ManualFetch(let actioningPatient, let addedRecord, let _, let _, let _):
            return manualUnauthFetchRecordsStack(actioningPatient: actioningPatient, addedRecord: addedRecord)
        case .ManuallyDeletedAllOfAnUnauthPatientRecords(let affectedTabs):
            return manuallyDeletedAllOfAnUnauthPatientRecordsForPatientRecordsStack(affectedTabs: affectedTabs)
        case .Logout(let currentTab):
            return manualLogOutRecordsStack(currentTab: currentTab)
        case .ClearAllData(let currentTab):
            return self.clearAllDataRecordsStack(currentTab: currentTab)
        }
    }
    
    private func initialAppLaunchRecordsStack(affectedTabs: [TabBarVCs]) -> [UIViewController] {
        guard affectedTabs.contains(.records) else { return [] }
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
    
    private func manualUnauthFetchRecordsStack(actioningPatient patient: Patient?, addedRecord record: HealthRecordsDetailDataSource?) -> [UIViewController] {
        switch self.currentPatientScenario {
        case .NoUsers, .OneAuthUser:
            // Not possible here - after a successful manual fetch, there has to be at least 1 unauth patient
            return []
        case .OneUnauthUser:
            // Stack should be UsersListOfRecordsViewController, then HealthRecordDetailViewController
            guard let patient = patient else { return [] }
            let vc1 = UsersListOfRecordsViewController.constructUsersListOfRecordsViewController(patient: patient, authenticated: false, navStyle: .singleUser, hasUpdatedUnauthPendingTest: false)
            let recordsCount = StorageService.shared.getHeathRecords().detailDataSource(patient: patient).count
            guard let record = record else { return [vc1] }
            let vc2 = HealthRecordDetailViewController.constructHealthRecordDetailViewController(dataSource: record, authenticatedRecord: false, userNumberHealthRecords: recordsCount)
            return [vc1, vc2]
        case .MoreThanOneUnauthUser, .OneAuthUserAndOneUnauthUser, .OneAuthUserAndMoreThanOneUnauthUser:
            // Stack should be HealthRecordsViewController, UsersListOfRecordsViewController, then HealthRecordDetailViewController
            let vc1 = HealthRecordsViewController.constructHealthRecordsViewController()
            guard let patient = patient else { return [vc1] }
            let authenticated = self.currentPatientScenario == .MoreThanOneUnauthUser ? false : true
            let vc2 = UsersListOfRecordsViewController.constructUsersListOfRecordsViewController(patient: patient, authenticated: authenticated, navStyle: .multiUser, hasUpdatedUnauthPendingTest: false)
            guard let record = record else { return [vc1, vc2] }
            let recordsCount = StorageService.shared.getHeathRecords().detailDataSource(patient: patient).count
            let vc3 = HealthRecordDetailViewController.constructHealthRecordDetailViewController(dataSource: record, authenticatedRecord: false, userNumberHealthRecords: recordsCount)
            return [vc1, vc2, vc3]
        }
    }
    
    private func manuallyDeletedAllOfAnUnauthPatientRecordsForPatientRecordsStack(affectedTabs: [TabBarVCs]) -> [UIViewController] {
        guard affectedTabs.contains(.records) else { return [] }
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
        let vc3 = SecurityAndDataViewController.constructSecurityAndDataViewController()
        return [vc1, vc2, vc3]
    }
    
}

// MARK: Nav stack setup Health Records
extension RouterWorker {
    private func setupHealthPassNavStackForScenario(scenario: AppUserActionScenarios) -> [UIViewController] {
        switch scenario {
        case .InitialAppLaunch(let affectedTabs):
            return initialAppLaunchPassesStack(affectedTabs: affectedTabs)
        case .AuthenticatedFetch(let _, let recentlyAddedCardId, let fedPassStringToOpen):
            return authenticatedFetchPassesStack(recentlyAddedCardId: recentlyAddedCardId, fedPassStringToOpen: fedPassStringToOpen)
        case .ManualFetch(let _, let _, let recentlyAddedCardId, let fedPassStringToOpen, let fedPassAddedFromHealthPassVC):
            return manualUnauthFetchPassessStack(recentlyAddedCardId: recentlyAddedCardId, fedPassStringToOpen: fedPassStringToOpen, fedPassAddedFromHealthPassVC: fedPassAddedFromHealthPassVC)
        case .ManuallyDeletedAllOfAnUnauthPatientRecords(let affectedTabs):
            return manuallyDeletedVaccineCardForPatientPassesStack(affectedTabs: affectedTabs)
        case .Logout(let currentTab):
            return manualLogOutPassesStack(currentTab: currentTab)
        case .ClearAllData(let currentTab):
            return clearAllDataPassesStack(currentTab: currentTab)
        }
    }
    
    private func initialAppLaunchPassesStack(affectedTabs: [TabBarVCs]) -> [UIViewController] {
        guard affectedTabs.contains(.healthPass) else { return [] }
        let vc = HealthPassViewController.constructHealthPassViewController(fedPassStringToOpen: nil)
        return [vc]
    }
    // For now, handling this separately from below, even though logic is the same as unauth fetch, because we may remove vaccine card but keep fed pass, so having this separated is a good idea
    private func authenticatedFetchPassesStack(recentlyAddedCardId: String?, fedPassStringToOpen: String?) -> [UIViewController] {
        switch self.currentPatientScenario {
        case .NoUsers, .OneUnauthUser, .MoreThanOneUnauthUser:
            // Not possible here - after an authFetch, there has to be at least one Auth user, so do nothing
            return []
        case .OneAuthUser:
            // Stack should be UsersListOfRecordsViewController (after fetch is completed)
            // Note - hasUpdatedUnauthPendingTest is irrelevant here
            let vc = HealthPassViewController.constructHealthPassViewController(fedPassStringToOpen: fedPassStringToOpen)
            return [vc]
        case .OneAuthUserAndOneUnauthUser, .OneAuthUserAndMoreThanOneUnauthUser:
            // Stack should be HealthPassViewController, then CovidVaccineCardsViewController, scrolling to the given id row and expanding
            let vc1 = HealthPassViewController.constructHealthPassViewController(fedPassStringToOpen: nil)
            let vc2 = CovidVaccineCardsViewController.constructCovidVaccineCardsViewController(recentlyAddedCardId: recentlyAddedCardId, fedPassStringToOpen: fedPassStringToOpen)
            return [vc1, vc2]
        }
    }
    
    private func manualUnauthFetchPassessStack(recentlyAddedCardId: String?, fedPassStringToOpen: String?, fedPassAddedFromHealthPassVC: Bool?) -> [UIViewController] {
        switch self.currentPatientScenario {
        case .NoUsers, .OneAuthUser:
            // Not possible here - after a successful manual fetch, there has to be at least 1 unauth patient
            return []
        case .OneUnauthUser:
            // In this case, user is just shown base view controller
            let vc = HealthPassViewController.constructHealthPassViewController(fedPassStringToOpen: fedPassStringToOpen)
            return [vc]
        case .MoreThanOneUnauthUser, .OneAuthUserAndOneUnauthUser, .OneAuthUserAndMoreThanOneUnauthUser:
            // Stack should be HealthPassViewController, CovidVaccineCardsViewController
            if fedPassAddedFromHealthPassVC == true {
                let vc1 = HealthPassViewController.constructHealthPassViewController(fedPassStringToOpen: fedPassStringToOpen)
                return [vc1]
            } else {
                let vc1 = HealthPassViewController.constructHealthPassViewController(fedPassStringToOpen: nil)
                let vc2 = CovidVaccineCardsViewController.constructCovidVaccineCardsViewController(recentlyAddedCardId: recentlyAddedCardId, fedPassStringToOpen: fedPassStringToOpen)
                return [vc1, vc2]
            }
        }
    }
    
    private func manuallyDeletedVaccineCardForPatientPassesStack(affectedTabs: [TabBarVCs]) -> [UIViewController] {
        guard affectedTabs.contains(.healthPass) else { return [] }
        switch self.currentPatientScenario {
        case .NoUsers, .OneAuthUser, .OneUnauthUser:
            // In this case, show initial screen
            let vc = HealthPassViewController.constructHealthPassViewController(fedPassStringToOpen: nil)
            return [vc]
        case .MoreThanOneUnauthUser, .OneAuthUserAndOneUnauthUser, .OneAuthUserAndMoreThanOneUnauthUser:
            // In this case, just show health records screen and vaccine cards screen
            let vc1 = HealthPassViewController.constructHealthPassViewController(fedPassStringToOpen: nil)
            let vc2 = CovidVaccineCardsViewController.constructCovidVaccineCardsViewController(recentlyAddedCardId: nil, fedPassStringToOpen: nil)
            return [vc1, vc2]
        }
    }
    
    private func manualLogOutPassesStack(currentTab: TabBarVCs) -> [UIViewController] {
        // Note - this is a unique case as we need to reset the stack in some cases, but still need to show the same screen
        switch self.currentPatientScenario {
        case .NoUsers, .OneUnauthUser, .MoreThanOneUnauthUser:
            let vc1 = HealthPassViewController.constructHealthPassViewController(fedPassStringToOpen: nil)
            guard currentTab == .records else { return [vc1] }
            let vc2 = ProfileAndSettingsViewController.constructProfileAndSettingsViewController()
            return [vc1, vc2]
        case .OneAuthUser, .OneAuthUserAndOneUnauthUser, .OneAuthUserAndMoreThanOneUnauthUser:
            // This isn't possible - after logout, there is no auth user
            return []
        }
    }
    
    private func clearAllDataPassesStack(currentTab: TabBarVCs) -> [UIViewController] {
        let vc1 = HealthPassViewController.constructHealthPassViewController(fedPassStringToOpen: nil)
        guard currentTab == .healthPass else { return [vc1] }
        let vc2 = ProfileAndSettingsViewController.constructProfileAndSettingsViewController()
        let vc3 = SecurityAndDataViewController.constructSecurityAndDataViewController()
        return [vc1, vc2, vc3]
    }
    
}
