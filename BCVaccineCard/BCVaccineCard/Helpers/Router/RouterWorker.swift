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

enum VaccineCardNumber {
    case NoCards
    case OneCard
    case MultiplCards
    
    static func getCurrentNumber(cards: Int) -> Self {
        if cards == 0 {
            return .NoCards
        } else if cards == 1 {
            return .OneCard
        } else {
            return .MultiplCards
        }
    }
}
// Note for Developer: AppUserActionScenarios should be called at the completion of the action in question (after core data changes)
//enum AppUserActionScenarios {
//    case InitialAppLaunch(affectedTabs: [TabBarVCs])
//    case AuthenticatedFetch(actioningPatient: Patient?, recentlyAddedCardId: String?, fedPassStringToOpen: String?)
//    case ManualFetch(actioningPatient: Patient?, addedRecord: HealthRecordsDetailDataSource?, recentlyAddedCardId: String?, fedPassStringToOpen: String?, fedPassAddedFromHealthPassVC: Bool?)
//    case ManuallyDeletedAllOfAnUnauthPatientRecords(affectedTabs: [TabBarVCs])
//    case Logout(currentTab: TabBarVCs)
//    case ClearAllData(currentTab: TabBarVCs)
//}

enum AppUserActionScenarios {
    case InitialAppLaunch(values: ActionScenarioValues)
    case AuthenticatedFetch(values: ActionScenarioValues)
    case ManualFetch(values: ActionScenarioValues)
    case ManuallyDeletedAllOfAnUnauthPatientRecords(values: ActionScenarioValues)
    case Logout(values: ActionScenarioValues)
    case ClearAllData(values: ActionScenarioValues)
}

struct ActionScenarioValues {
    let currentTab: TabBarVCs
    var affectedTabs: [TabBarVCs] = [.healthPass, .records]
    var recordFlowDetails: RecordsFlowDetails?
    var passesFlowDetails: PassesFlowDetails?
}

struct CurrentRecordsAndPassesStacks {
    let recordsStack: [RecordsFlowVCs]
    let passesStack: [PassesFlowVCs]
}

enum RecordsFlowVCs {
    case HealthRecordsViewController
    case UsersListOfRecordsViewController(patient: Patient?)
    case FetchHealthRecordsViewController
    case HealthRecordDetailViewController(patient: Patient?, dataSource: HealthRecordsDetailDataSource)
    case ProfileAndSettingsViewController
    case SecurityAndDataViewController
}

enum PassesFlowVCs {
    case HealthPassViewController
    case CovidVaccineCardsViewController
    case QRRetrievalMethodViewController
    case ProfileAndSettingsViewController
    case SecurityAndDataViewController
}

struct RecordsFlowDetails {
    let currentStack: [RecordsFlowVCs]
    var actioningPatient: Patient? = nil
    var addedRecord: HealthRecordsDetailDataSource? = nil
}

struct PassesFlowDetails {
    let currentStack: [PassesFlowVCs]
    var recentlyAddedCardId: String? = nil
    var fedPassStringToOpen: String? = nil
    var fedPassAddedFromHealthPassVC: Bool? = nil
}

protocol RouterWorkerDelegate: AnyObject  {
    func recordsActionScenario(viewControllerStack: [BaseViewController])
    func passesActionScenario(viewControllerStack: [BaseViewController])
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
    
    private var currentNumberOfVaccineCards: VaccineCardNumber {
        let count = StorageService.shared.fetchVaccineCards().count
        return VaccineCardNumber.getCurrentNumber(cards: count)
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
    private func setupHealthRecordsNavStackForScenario(scenario: AppUserActionScenarios) -> [BaseViewController] {
        switch scenario {
        case .InitialAppLaunch(let values):
            return initialAppLaunchRecordsStack(values: values)
        case .AuthenticatedFetch(let values):
            return authenticatedFetchRecordsStack(values: values)
        case .ManualFetch(let values):
            return manualUnauthFetchRecordsStack(values: values)
        case .ManuallyDeletedAllOfAnUnauthPatientRecords(let values):
            return manuallyDeletedAllOfAnUnauthPatientRecordsForPatientRecordsStack(values: values)
        case .Logout(let values):
            return manualLogOutRecordsStack(values: values)
        case .ClearAllData(let values):
            return self.clearAllDataRecordsStack(values: values)
        }
    }
    
    private func initialAppLaunchRecordsStack(values: ActionScenarioValues) -> [BaseViewController] {
        guard values.affectedTabs.contains(.records) else { return [] }
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
    
    private func authenticatedFetchRecordsStack(values: ActionScenarioValues) -> [BaseViewController] {
        switch self.currentPatientScenario {
        case .NoUsers, .OneUnauthUser, .MoreThanOneUnauthUser:
            // Not possible here - after an authFetch, there has to be at least one Auth user, so do nothing
            return []
        case .OneAuthUser:
            // Stack should be UsersListOfRecordsViewController (after fetch is completed)
            // Note - hasUpdatedUnauthPendingTest is irrelevant here
            guard let patient = values.recordFlowDetails?.actioningPatient else { return [] }
            let vc = UsersListOfRecordsViewController.constructUsersListOfRecordsViewController(patient: patient, authenticated: true, navStyle: .singleUser, hasUpdatedUnauthPendingTest: true)
            return [vc]
        case .OneAuthUserAndOneUnauthUser, .OneAuthUserAndMoreThanOneUnauthUser:
            // Stack should be HealthRecordsViewController, then UsersListOfRecordsViewController (after fetch is completed)
            // Note - setting hasUpdatedUnauthPendingTest to false just in case unauth user has to check for background update for pending covid test
            let vc1 = HealthRecordsViewController.constructHealthRecordsViewController()
            guard let patient = values.recordFlowDetails?.actioningPatient else { return [vc1] }
            let vc2 = UsersListOfRecordsViewController.constructUsersListOfRecordsViewController(patient: patient, authenticated: true, navStyle: .multiUser, hasUpdatedUnauthPendingTest: false)
            return [vc1, vc2]
        }
    }
    
    private func manualUnauthFetchRecordsStack(values: ActionScenarioValues) -> [BaseViewController] {
        switch self.currentPatientScenario {
        case .NoUsers, .OneAuthUser:
            // Not possible here - after a successful manual fetch, there has to be at least 1 unauth patient
            return []
        case .OneUnauthUser:
            // Stack should be UsersListOfRecordsViewController, then HealthRecordDetailViewController
            guard let patient = values.recordFlowDetails?.actioningPatient else { return [] }
            let vc1 = UsersListOfRecordsViewController.constructUsersListOfRecordsViewController(patient: patient, authenticated: false, navStyle: .singleUser, hasUpdatedUnauthPendingTest: false)
            let recordsCount = StorageService.shared.getHeathRecords().detailDataSource(patient: patient).count
            guard let record = values.recordFlowDetails?.addedRecord else { return [vc1] }
            let vc2 = HealthRecordDetailViewController.constructHealthRecordDetailViewController(dataSource: record, authenticatedRecord: false, userNumberHealthRecords: recordsCount, patient: patient)
            return [vc1, vc2]
        case .MoreThanOneUnauthUser, .OneAuthUserAndOneUnauthUser, .OneAuthUserAndMoreThanOneUnauthUser:
            // Stack should be HealthRecordsViewController, UsersListOfRecordsViewController, then HealthRecordDetailViewController
            let vc1 = HealthRecordsViewController.constructHealthRecordsViewController()
            guard let patient = values.recordFlowDetails?.actioningPatient else { return [vc1] }
            let authenticated = self.currentPatientScenario == .MoreThanOneUnauthUser ? false : true
            let vc2 = UsersListOfRecordsViewController.constructUsersListOfRecordsViewController(patient: patient, authenticated: authenticated, navStyle: .multiUser, hasUpdatedUnauthPendingTest: false)
            guard let record = values.recordFlowDetails?.addedRecord else { return [vc1, vc2] }
            let recordsCount = StorageService.shared.getHeathRecords().detailDataSource(patient: patient).count
            let vc3 = HealthRecordDetailViewController.constructHealthRecordDetailViewController(dataSource: record, authenticatedRecord: false, userNumberHealthRecords: recordsCount, patient: patient)
            return [vc1, vc2, vc3]
        }
    }
    
    private func manuallyDeletedAllOfAnUnauthPatientRecordsForPatientRecordsStack(values: ActionScenarioValues) -> [BaseViewController] {
        guard values.affectedTabs.contains(.records) else { return [] }
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
    
    private func manualLogOutRecordsStack(values: ActionScenarioValues) -> [BaseViewController] {
        // Note - this is a unique case as we need to reset the stack in some cases, but still need to show the same screen
        switch self.currentPatientScenario {
        case .NoUsers:
            let vc1 = FetchHealthRecordsViewController.constructFetchHealthRecordsViewController(hideNavBackButton: true, showSettingsIcon: true, hasHealthRecords: false, completion: {})
            guard values.currentTab == .records else { return [vc1] }
            let vc2 = ProfileAndSettingsViewController.constructProfileAndSettingsViewController()
            return [vc1, vc2]
        case .OneAuthUser, .OneAuthUserAndOneUnauthUser, .OneAuthUserAndMoreThanOneUnauthUser:
            // This isn't possible - after logout, there is no auth user
            return []
        case .OneUnauthUser:
            guard let remainingUnauthPatient = self.getUnathenticatedPatients?.first else { return [] }
            let vc1 = UsersListOfRecordsViewController.constructUsersListOfRecordsViewController(patient: remainingUnauthPatient, authenticated: false, navStyle: .singleUser, hasUpdatedUnauthPendingTest: false)
            guard values.currentTab == .records else { return [vc1] }
            let vc2 = ProfileAndSettingsViewController.constructProfileAndSettingsViewController()
            return [vc1, vc2]
        case .MoreThanOneUnauthUser:
            let vc1 = HealthRecordsViewController.constructHealthRecordsViewController()
            guard values.currentTab == .records else { return [vc1] }
            let vc2 = ProfileAndSettingsViewController.constructProfileAndSettingsViewController()
            return [vc1, vc2]
        }
    }
    
    private func clearAllDataRecordsStack(values: ActionScenarioValues) -> [BaseViewController] {
        let vc1 = FetchHealthRecordsViewController.constructFetchHealthRecordsViewController(hideNavBackButton: true, showSettingsIcon: true, hasHealthRecords: false, completion: {})
        guard values.currentTab == .records else { return [vc1] }
        let vc2 = ProfileAndSettingsViewController.constructProfileAndSettingsViewController()
        let vc3 = SecurityAndDataViewController.constructSecurityAndDataViewController()
        return [vc1, vc2, vc3]
    }
    
}

// MARK: Nav stack setup Health Records
extension RouterWorker {
    private func setupHealthPassNavStackForScenario(scenario: AppUserActionScenarios) -> [BaseViewController] {
        switch scenario {
        case .InitialAppLaunch(let values):
            return initialAppLaunchPassesStack(values: values)
        case .AuthenticatedFetch(let values):
            return authenticatedFetchPassesStack(values: values)
        case .ManualFetch(let values):
            return manualUnauthFetchPassessStack(values: values)
        case .ManuallyDeletedAllOfAnUnauthPatientRecords(let values):
            return manuallyDeletedVaccineCardForPatientPassesStack(values: values)
        case .Logout(let values):
            return manualLogOutPassesStack(values: values)
        case .ClearAllData(let values):
            return clearAllDataPassesStack(values: values)
        }
    }
    
    private func initialAppLaunchPassesStack(values: ActionScenarioValues) -> [BaseViewController] {
        guard values.affectedTabs.contains(.healthPass) else { return [] }
        let vc = HealthPassViewController.constructHealthPassViewController(fedPassStringToOpen: nil)
        return [vc]
    }
    // Patient scenario doesn't matter here, because a patient doesn't necessarily have a vaccine card
    private func authenticatedFetchPassesStack(values: ActionScenarioValues) -> [BaseViewController] {
        switch currentNumberOfVaccineCards {
        case .NoCards, .OneCard:
            let vc = HealthPassViewController.constructHealthPassViewController(fedPassStringToOpen: values.passesFlowDetails?.fedPassStringToOpen)
            return [vc]
        case .MultiplCards:
            let vc1 = HealthPassViewController.constructHealthPassViewController(fedPassStringToOpen: nil)
            let vc2 = CovidVaccineCardsViewController.constructCovidVaccineCardsViewController(recentlyAddedCardId: values.passesFlowDetails?.recentlyAddedCardId, fedPassStringToOpen: values.passesFlowDetails?.fedPassStringToOpen)
            return [vc1, vc2]
        }
    }
    
    private func manualUnauthFetchPassessStack(values: ActionScenarioValues) -> [BaseViewController] {
        switch currentNumberOfVaccineCards {
        case .NoCards, .OneCard:
            let vc = HealthPassViewController.constructHealthPassViewController(fedPassStringToOpen: values.passesFlowDetails?.fedPassStringToOpen)
            return [vc]
        case .MultiplCards:
            if values.passesFlowDetails?.fedPassAddedFromHealthPassVC == true {
                let vc1 = HealthPassViewController.constructHealthPassViewController(fedPassStringToOpen: values.passesFlowDetails?.fedPassStringToOpen)
                return [vc1]
            } else {
                let vc1 = HealthPassViewController.constructHealthPassViewController(fedPassStringToOpen: nil)
                let vc2 = CovidVaccineCardsViewController.constructCovidVaccineCardsViewController(recentlyAddedCardId: values.passesFlowDetails?.recentlyAddedCardId, fedPassStringToOpen: values.passesFlowDetails?.fedPassStringToOpen)
                return [vc1, vc2]
            }
        }
    }
    // Patient scenario doesn't matter here, because a patient doesn't necessarily have a vaccine card
    private func manuallyDeletedVaccineCardForPatientPassesStack(values: ActionScenarioValues) -> [BaseViewController] {
        guard values.affectedTabs.contains(.healthPass) else { return [] }
        switch currentNumberOfVaccineCards {
        case .NoCards, .OneCard:
            let vc = HealthPassViewController.constructHealthPassViewController(fedPassStringToOpen: nil)
            return [vc]
        case .MultiplCards:
            let vc1 = HealthPassViewController.constructHealthPassViewController(fedPassStringToOpen: nil)
            let vc2 = CovidVaccineCardsViewController.constructCovidVaccineCardsViewController(recentlyAddedCardId: nil, fedPassStringToOpen: nil)
            return [vc1, vc2]
        }
    }
    
    private func manualLogOutPassesStack(values: ActionScenarioValues) -> [BaseViewController] {
        // Note - this is a unique case as we need to reset the stack in some cases, but still need to show the same screen
        switch currentNumberOfVaccineCards {
        case .NoCards, .OneCard:
            let vc1 = HealthPassViewController.constructHealthPassViewController(fedPassStringToOpen: nil)
            guard values.currentTab == .healthPass else { return [vc1] }
            let vc2 = ProfileAndSettingsViewController.constructProfileAndSettingsViewController()
            return [vc1, vc2]
        case .MultiplCards:
            let vc1 = HealthPassViewController.constructHealthPassViewController(fedPassStringToOpen: nil)
            let vc2 = CovidVaccineCardsViewController.constructCovidVaccineCardsViewController(recentlyAddedCardId: nil, fedPassStringToOpen: nil)
            guard values.currentTab == .healthPass else { return [vc1, vc2] }
            let vc3 = ProfileAndSettingsViewController.constructProfileAndSettingsViewController()
            return [vc1, vc2, vc3]
        }
    }
    
    private func clearAllDataPassesStack(values: ActionScenarioValues) -> [BaseViewController] {
        let vc1 = HealthPassViewController.constructHealthPassViewController(fedPassStringToOpen: nil)
        guard values.currentTab == .healthPass else { return [vc1] }
        let vc2 = ProfileAndSettingsViewController.constructProfileAndSettingsViewController()
        let vc3 = SecurityAndDataViewController.constructSecurityAndDataViewController()
        return [vc1, vc2, vc3]
    }
    
}
