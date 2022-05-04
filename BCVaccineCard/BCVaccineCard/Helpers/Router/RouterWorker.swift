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
    var loginSourceVC: LoginVCSource?
}

struct CurrentRecordsAndPassesStacks {
    let recordsStack: [RecordsFlowVCs]
    let passesStack: [PassesFlowVCs]
}

enum RecordsFlowVCs {
    case HealthRecordsViewController
    case UsersListOfRecordsViewController(patient: Patient?)
    case FetchHealthRecordsViewController
    case HealthRecordDetailViewController(patient: Patient?, dataSource: HealthRecordsDetailDataSource, userNumberHealthRecords: Int)
    case ProfileAndSettingsViewController
    case SecurityAndDataViewController
    case GatewayFormViewController(rememberDetails: RememberedGatewayDetails, fetchType: GatewayFormViewControllerFetchType, gatewayInProgressDetails: GatewayInProgressDetails?)
    
    enum NonAssociatedVersion {
        case HealthRecordsViewController
        case UsersListOfRecordsViewController
        case FetchHealthRecordsViewController
        case HealthRecordDetailViewController
        case ProfileAndSettingsViewController
        case SecurityAndDataViewController
        case GatewayFormViewController
        
        func getIndexFromArray(array: [RecordsFlowVCs]) -> Int? {
            return array.map { $0.getNonAssociatedVersion }.firstIndex(of: self)
        }
    }
    
    private var getNonAssociatedVersion: NonAssociatedVersion {
        switch self {
        case .HealthRecordsViewController:
            return .HealthRecordsViewController
        case .UsersListOfRecordsViewController:
            return .UsersListOfRecordsViewController
        case .FetchHealthRecordsViewController:
            return .FetchHealthRecordsViewController
        case .HealthRecordDetailViewController:
            return .HealthRecordDetailViewController
        case .ProfileAndSettingsViewController:
            return .ProfileAndSettingsViewController
        case .SecurityAndDataViewController:
            return .SecurityAndDataViewController
        case .GatewayFormViewController:
            return .GatewayFormViewController
        }
    }
}

enum PassesFlowVCs {
    case HealthPassViewController(fedPassToOpen: String?)
    case CovidVaccineCardsViewController(fedPassToOpen: String?, recentlyAddedCardId: String?)
    case QRRetrievalMethodViewController
    case ProfileAndSettingsViewController
    case SecurityAndDataViewController
    case GatewayFormViewController(rememberDetails: RememberedGatewayDetails, fetchType: GatewayFormViewControllerFetchType, gatewayInProgressDetails: GatewayInProgressDetails?)
    
    enum NonAssociatedVersion {
        case HealthPassViewController
        case CovidVaccineCardsViewController
        case QRRetrievalMethodViewController
        case ProfileAndSettingsViewController
        case SecurityAndDataViewController
        case GatewayFormViewController
        
        func getIndexFromArray(array: [PassesFlowVCs]) -> Int? {
            return array.map { $0.getNonAssociatedVersion }.firstIndex(of: self)
        }
    }
    
    private var getNonAssociatedVersion: NonAssociatedVersion {
        switch self {
        case .HealthPassViewController:
            return .HealthPassViewController
        case .CovidVaccineCardsViewController:
            return .CovidVaccineCardsViewController
        case .QRRetrievalMethodViewController:
            return .QRRetrievalMethodViewController
        case .ProfileAndSettingsViewController:
            return .ProfileAndSettingsViewController
        case .SecurityAndDataViewController:
            return .SecurityAndDataViewController
        case .GatewayFormViewController:
            return .GatewayFormViewController
        }
    }
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

struct NavStacks {
    let recordsStack: [BaseViewController]
    let passesStack: [BaseViewController]
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
    
    private var userRecordsNavStyle: UsersListOfRecordsViewController.NavStyle {
        let authPatientCount = StorageService.shared.fetchAuthenticatedPatient() != nil ? 1 : 0
        let unauthPatientsCount = StorageService.shared.fetchUnauthenticatedPatients()?.count ?? 0
        return authPatientCount + unauthPatientsCount > 1 ? .multiUser : .singleUser
    }
    
    private var currentNumberOfVaccineCards: VaccineCardNumber {
        let count = StorageService.shared.fetchVaccineCards().count
        return VaccineCardNumber.getCurrentNumber(cards: count)
    }
    
    init(delegateOwner: UIViewController) {
        self.delegate = delegateOwner as? RouterWorkerDelegate
    }
    
    public func routingAction(scenario: AppUserActionScenarios) {
//        let recordsStack = setupHealthRecordsNavStackForScenario(scenario: scenario)
        let stack = setupRecordsAndPassesNavStacks(scenario: scenario)
        self.delegate?.recordsActionScenario(viewControllerStack: stack.recordsStack)
//        let passesStack = setupHealthPassNavStackForScenario(scenario: scenario)
        self.delegate?.passesActionScenario(viewControllerStack: stack.passesStack)
    }
}

// MARK: Nav stack setup for both records and passes tab
extension RouterWorker {
    private func setupRecordsAndPassesNavStacks(scenario: AppUserActionScenarios) -> NavStacks {
        let recordsStack: [BaseViewController]
        let passesStack: [BaseViewController]
        switch scenario {
        case .InitialAppLaunch(let values):
            recordsStack = initialLaunchRecordsStacks(values: values)
            passesStack = initialLaunchPassesStack(values: values)
        case .AuthenticatedFetch(let values):
            recordsStack = authFetchRecordsStack(values: values)
            passesStack = authFetchPassesStack(values: values)
        case .ManualFetch(let values):
            recordsStack = manualFetchRecordsStack(values: values)
            passesStack = manualFetchPassesStack(values: values)
        case .ManuallyDeletedAllOfAnUnauthPatientRecords(let values):
            recordsStack = manualDeleteRecordsStack(values: values)
            passesStack = manualDeletePassesStack(values: values)
        case .Logout(let values):
            recordsStack = logoutRecordsStack(values: values)
            passesStack = logoutPassesStack(values: values)
        case .ClearAllData(let values):
            recordsStack = clearAllDataRecordsStack(values: values)
            passesStack = clearAllDataPassesStack(values: values)
        }
        return NavStacks(recordsStack: recordsStack, passesStack: passesStack)
    }
    
    private func initialLaunchRecordsStacks(values: ActionScenarioValues) -> [BaseViewController] {
        guard values.affectedTabs.contains(.records) else { return [] }
        switch self.currentPatientScenario {
        case .NoUsers:
            let vc = FetchHealthRecordsViewController.constructFetchHealthRecordsViewController(hasHealthRecords: false)
            return [vc]
        case .OneAuthUser:
            guard let patient = self.getAuthenticatedPatient else {
                let vc = FetchHealthRecordsViewController.constructFetchHealthRecordsViewController(hasHealthRecords: false)
                return [vc]
            }
            let vc = UsersListOfRecordsViewController.constructUsersListOfRecordsViewController(patient: patient, authenticated: true, navStyle: .singleUser, hasUpdatedUnauthPendingTest: false)
            return [vc]
        case .OneUnauthUser:
            guard let patient = self.getUnathenticatedPatients?.first else {
                let vc = FetchHealthRecordsViewController.constructFetchHealthRecordsViewController(hasHealthRecords: false)
                return [vc]
            }
            let vc = UsersListOfRecordsViewController.constructUsersListOfRecordsViewController(patient: patient, authenticated: false, navStyle: .singleUser, hasUpdatedUnauthPendingTest: false)
            return [vc]
        case .MoreThanOneUnauthUser, .OneAuthUserAndOneUnauthUser, .OneAuthUserAndMoreThanOneUnauthUser:
            let vc = HealthRecordsViewController.constructHealthRecordsViewController()
            return [vc]
        }
    }
    
    private func initialLaunchPassesStack(values: ActionScenarioValues) -> [BaseViewController] {
        guard values.affectedTabs.contains(.healthPass) else { return [] }
        let vc = HealthPassViewController.constructHealthPassViewController(fedPassStringToOpen: nil)
        return [vc]
    }
    
    private func authFetchRecordsStack(values: ActionScenarioValues) -> [BaseViewController] {
        if values.currentTab == .records {
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
        else {
            return self.resetRecordsTab()
        }
        
    }
    
    private func authFetchPassesStack(values: ActionScenarioValues) -> [BaseViewController] {
        if values.currentTab == .healthPass {
            switch currentNumberOfVaccineCards {
            case .NoCards, .OneCard:
                let vc = HealthPassViewController.constructHealthPassViewController(fedPassStringToOpen: values.passesFlowDetails?.fedPassStringToOpen)
                return [vc]
            case .MultiplCards:
                let vc1 = HealthPassViewController.constructHealthPassViewController(fedPassStringToOpen: nil)
                let vc2 = CovidVaccineCardsViewController.constructCovidVaccineCardsViewController(recentlyAddedCardId: values.passesFlowDetails?.recentlyAddedCardId, fedPassStringToOpen: values.passesFlowDetails?.fedPassStringToOpen)
                return [vc1, vc2]
            }
        } else {
            return self.resetPassesTab()
        }
    }
    
    private func manualFetchRecordsStack(values: ActionScenarioValues) -> [BaseViewController] {
        if values.currentTab == .records {
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
        } else {
            return self.resetRecordsTab()
        }
    }
    
    private func manualFetchPassesStack(values: ActionScenarioValues) -> [BaseViewController] {
        if values.currentTab == .healthPass {
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
        } else {
            return self.resetPassesTab()
        }
    }
    
    private func manualDeleteRecordsStack(values: ActionScenarioValues) -> [BaseViewController] {
        if values.currentTab == .records {
            guard values.affectedTabs.contains(.records) else { return [] }
            switch self.currentPatientScenario {
            case .NoUsers:
                // In this case, show initial fetch screen - stack should be FetchHealthRecordsViewController
                let vc = FetchHealthRecordsViewController.constructFetchHealthRecordsViewController(hasHealthRecords: false)
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
        } else {
            return self.resetRecordsTab()
        }
    }
    
    private func manualDeletePassesStack(values: ActionScenarioValues) -> [BaseViewController] {
        if values.currentTab == .healthPass {
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
        } else {
            return self.resetPassesTab()
        }
    }
    
    private func logoutRecordsStack(values: ActionScenarioValues) -> [BaseViewController] {
        if values.currentTab == .records {
            switch self.currentPatientScenario {
            case .NoUsers:
                let vc1 = FetchHealthRecordsViewController.constructFetchHealthRecordsViewController(hasHealthRecords: false)
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
        } else {
            return self.resetRecordsTab()
        }
    }
    
    private func logoutPassesStack(values: ActionScenarioValues) -> [BaseViewController] {
        if values.currentTab == .healthPass {
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
        } else {
            return self.resetPassesTab()
        }
    }
    
    private func clearAllDataRecordsStack(values: ActionScenarioValues) -> [BaseViewController] {
        if values.currentTab == .records {
            let vc1 = FetchHealthRecordsViewController.constructFetchHealthRecordsViewController(hasHealthRecords: false)
            guard values.currentTab == .records else { return [vc1] }
            let vc2 = ProfileAndSettingsViewController.constructProfileAndSettingsViewController()
            let vc3 = SecurityAndDataViewController.constructSecurityAndDataViewController()
            return [vc1, vc2, vc3]
        } else {
            return self.resetRecordsTab()
        }
    }
    
    private func clearAllDataPassesStack(values: ActionScenarioValues) -> [BaseViewController] {
        if values.currentTab == .healthPass {
            let vc1 = HealthPassViewController.constructHealthPassViewController(fedPassStringToOpen: nil)
            guard values.currentTab == .healthPass else { return [vc1] }
            let vc2 = ProfileAndSettingsViewController.constructProfileAndSettingsViewController()
            let vc3 = SecurityAndDataViewController.constructSecurityAndDataViewController()
            return [vc1, vc2, vc3]
        } else {
            return self.resetPassesTab()
        }
    }
}

// MARK: Temporary for resetting each tab when tab is not selected during action
extension RouterWorker {
    private func resetRecordsTab() -> [BaseViewController] {
        switch self.currentPatientScenario {
        case .NoUsers:
            let vc = FetchHealthRecordsViewController.constructFetchHealthRecordsViewController(hasHealthRecords: false)
            return [vc]
        case .OneAuthUser:
            guard let patient = self.getAuthenticatedPatient else { return [] }
            let vc = UsersListOfRecordsViewController.constructUsersListOfRecordsViewController(patient: patient, authenticated: true, navStyle: .singleUser, hasUpdatedUnauthPendingTest: false)
            return [vc]
        case .OneUnauthUser:
            guard let patient = self.getUnathenticatedPatients?.first else { return [] }
            let vc = UsersListOfRecordsViewController.constructUsersListOfRecordsViewController(patient: patient, authenticated: false, navStyle: .singleUser, hasUpdatedUnauthPendingTest: false)
            return [vc]
        case .MoreThanOneUnauthUser, .OneAuthUserAndOneUnauthUser, .OneAuthUserAndMoreThanOneUnauthUser:
            let vc = HealthRecordsViewController.constructHealthRecordsViewController()
            return [vc]
        }
        
    }
    
    private func resetPassesTab() -> [BaseViewController] {
        return [HealthPassViewController.constructHealthPassViewController(fedPassStringToOpen: nil)]
    }
}











// FIXME: Finish this then replace with the temp tab resets
// MARK: Setting up stack from current view controllers - finish this later
extension RouterWorker {
    
    private func constructNewRecordsStack(newStack: [RecordsFlowVCs]) -> [BaseViewController] {
        var newVCStack: [BaseViewController] = []
        newStack.forEach { stack in
            let vc: BaseViewController?
            switch stack {
            case .HealthRecordsViewController:
                vc = HealthRecordsViewController.constructHealthRecordsViewController()
            case .UsersListOfRecordsViewController(patient: let patient):
                guard let patient = patient else { return }
                vc = UsersListOfRecordsViewController.constructUsersListOfRecordsViewController(patient: patient, authenticated: patient.authenticated, navStyle: self.userRecordsNavStyle, hasUpdatedUnauthPendingTest: false)
            case .FetchHealthRecordsViewController:
                let hasRecords = !(StorageService.shared.getHeathRecords().isEmpty)
                vc = FetchHealthRecordsViewController.constructFetchHealthRecordsViewController(hasHealthRecords: hasRecords)
            case .HealthRecordDetailViewController(patient: let patient, dataSource: let dataSource, userNumberHealthRecords: let userNumberHealthRecords):
                vc = HealthRecordDetailViewController.constructHealthRecordDetailViewController(dataSource: dataSource, authenticatedRecord: dataSource.isAuthenticated, userNumberHealthRecords: userNumberHealthRecords, patient: patient)
            case .ProfileAndSettingsViewController:
                vc = ProfileAndSettingsViewController.constructProfileAndSettingsViewController()
            case .SecurityAndDataViewController:
                vc = SecurityAndDataViewController.constructSecurityAndDataViewController()
            case .GatewayFormViewController(rememberDetails: let rememberDetails, fetchType: let fetchType, gatewayInProgressDetails: let currentProgress):
                vc = GatewayFormViewController.constructGatewayFormViewController(rememberDetails: rememberDetails, fetchType: fetchType, currentProgress: currentProgress)
            }
            if let vc = vc {
                newVCStack.append(vc)
            }
        }
        return newVCStack
    }
    // TODO: Once this is finished, create something similar for passes stack
    // Note: Use this if user is not currently on records tab
    private func modifyRecordsStackIfNecessary(currentPatientScenarioAfterAction scenario: CurrentPatientScenarios, currentRecordsStack: [RecordsFlowVCs], relevantPatient: Patient) -> [RecordsFlowVCs] {
        switch scenario {
        case .NoUsers:
            // Check if currentRecordsStack contains healthRecordsVC or userListOfRecordsVC or recordsDetailVC - if so, then remove those from the stack. Make sure fetchVC is the base VC here
            var recordsStack = currentRecordsStack
            if let index = RecordsFlowVCs.NonAssociatedVersion.HealthRecordsViewController.getIndexFromArray(array: recordsStack) {
                recordsStack.remove(at: index)
            }
            if let index = RecordsFlowVCs.NonAssociatedVersion.UsersListOfRecordsViewController.getIndexFromArray(array: recordsStack) {
                recordsStack.remove(at: index)
            }
            if let index = RecordsFlowVCs.NonAssociatedVersion.HealthRecordDetailViewController.getIndexFromArray(array: recordsStack) {
                recordsStack.remove(at: index)
            }
            if let index = RecordsFlowVCs.NonAssociatedVersion.FetchHealthRecordsViewController.getIndexFromArray(array: recordsStack) {
                let fetchVC = recordsStack.remove(at: index)
                recordsStack.insert(fetchVC, at: 0)
            } else {
                let fetchVC = RecordsFlowVCs.FetchHealthRecordsViewController
                recordsStack.insert(fetchVC, at: 0)
            }
            return recordsStack
//        case .OneAuthUser:
//            <#code#>
//        case .OneUnauthUser:
//            <#code#>
//        case .MoreThanOneUnauthUser:
//            <#code#>
//        case .OneAuthUserAndOneUnauthUser:
//            <#code#>
//        case .OneAuthUserAndMoreThanOneUnauthUser:
//            <#code#>
        default: return []
        }
    }
    
    private func constructNewPassesStack(newStack: [PassesFlowVCs]) -> [BaseViewController] {
        var newVCStack: [BaseViewController] = []
        newStack.forEach { stack in
            let vc: BaseViewController?
            switch stack {
            case .HealthPassViewController(fedPassToOpen: let fedPassStringToOpen):
                vc = HealthPassViewController.constructHealthPassViewController(fedPassStringToOpen: fedPassStringToOpen)
            case .CovidVaccineCardsViewController(fedPassToOpen: let fedPassStringToOpen, recentlyAddedCardId: let recentlyAddedCardId):
                vc = CovidVaccineCardsViewController.constructCovidVaccineCardsViewController(recentlyAddedCardId: recentlyAddedCardId, fedPassStringToOpen: fedPassStringToOpen)
            case .QRRetrievalMethodViewController:
                vc = QRRetrievalMethodViewController.constructQRRetrievalMethodViewController()
            case .ProfileAndSettingsViewController:
                vc = ProfileAndSettingsViewController.constructProfileAndSettingsViewController()
            case .SecurityAndDataViewController:
                vc = SecurityAndDataViewController.constructSecurityAndDataViewController()
            case .GatewayFormViewController(rememberDetails: let rememberDetails, fetchType: let fetchType, gatewayInProgressDetails: let currentProgress):
                vc = GatewayFormViewController.constructGatewayFormViewController(rememberDetails: rememberDetails, fetchType: fetchType, currentProgress: currentProgress)
            }
            if let vc = vc {
                newVCStack.append(vc)
            }
        }
        return newVCStack
    }
}


























// TODO: Delete the commented code below once the above code has been tested



// MARK: Nav stack setup Health Records
extension RouterWorker {
//    private func setupHealthRecordsNavStackForScenario(scenario: AppUserActionScenarios) -> [BaseViewController] {
//        switch scenario {
//        case .InitialAppLaunch(let values):
//            return initialAppLaunchRecordsStack(values: values)
//        case .AuthenticatedFetch(let values):
//            return authenticatedFetchRecordsStack(values: values)
//        case .ManualFetch(let values):
//            return manualUnauthFetchRecordsStack(values: values)
//        case .ManuallyDeletedAllOfAnUnauthPatientRecords(let values):
//            return manuallyDeletedAllOfAnUnauthPatientRecordsForPatientRecordsStack(values: values)
//        case .Logout(let values):
//            return manualLogOutRecordsStack(values: values)
//        case .ClearAllData(let values):
//            return self.clearAllDataRecordsStack(values: values)
//        }
//    }
    
//    private func initialAppLaunchRecordsStack(values: ActionScenarioValues) -> [BaseViewController] {
//        guard values.affectedTabs.contains(.records) else { return [] }
//        switch self.currentPatientScenario {
//        case .NoUsers:
//            let vc = FetchHealthRecordsViewController.constructFetchHealthRecordsViewController(hideNavBackButton: true, showSettingsIcon: true, hasHealthRecords: false, completion: {})
//            return [vc]
//        case .OneAuthUser:
//            guard let patient = self.getAuthenticatedPatient else {
//                let vc = FetchHealthRecordsViewController.constructFetchHealthRecordsViewController(hideNavBackButton: true, showSettingsIcon: true, hasHealthRecords: false, completion: {})
//                return [vc]
//            }
//            let vc = UsersListOfRecordsViewController.constructUsersListOfRecordsViewController(patient: patient, authenticated: true, navStyle: .singleUser, hasUpdatedUnauthPendingTest: false)
//            return [vc]
//        case .OneUnauthUser:
//            guard let patient = self.getUnathenticatedPatients?.first else {
//                let vc = FetchHealthRecordsViewController.constructFetchHealthRecordsViewController(hideNavBackButton: true, showSettingsIcon: true, hasHealthRecords: false, completion: {})
//                return [vc]
//            }
//            let vc = UsersListOfRecordsViewController.constructUsersListOfRecordsViewController(patient: patient, authenticated: false, navStyle: .singleUser, hasUpdatedUnauthPendingTest: false)
//            return [vc]
//        case .MoreThanOneUnauthUser, .OneAuthUserAndOneUnauthUser, .OneAuthUserAndMoreThanOneUnauthUser:
//            let vc = HealthRecordsViewController.constructHealthRecordsViewController()
//            return [vc]
//        }
//    }
    
//    private func authenticatedFetchRecordsStack(values: ActionScenarioValues) -> [BaseViewController] {
//        switch self.currentPatientScenario {
//        case .NoUsers, .OneUnauthUser, .MoreThanOneUnauthUser:
//            // Not possible here - after an authFetch, there has to be at least one Auth user, so do nothing
//            return []
//        case .OneAuthUser:
//            // Stack should be UsersListOfRecordsViewController (after fetch is completed)
//            // Note - hasUpdatedUnauthPendingTest is irrelevant here
//            guard let patient = values.recordFlowDetails?.actioningPatient else { return [] }
//            let vc = UsersListOfRecordsViewController.constructUsersListOfRecordsViewController(patient: patient, authenticated: true, navStyle: .singleUser, hasUpdatedUnauthPendingTest: true)
//            return [vc]
//        case .OneAuthUserAndOneUnauthUser, .OneAuthUserAndMoreThanOneUnauthUser:
//            // Stack should be HealthRecordsViewController, then UsersListOfRecordsViewController (after fetch is completed)
//            // Note - setting hasUpdatedUnauthPendingTest to false just in case unauth user has to check for background update for pending covid test
//            let vc1 = HealthRecordsViewController.constructHealthRecordsViewController()
//            guard let patient = values.recordFlowDetails?.actioningPatient else { return [vc1] }
//            let vc2 = UsersListOfRecordsViewController.constructUsersListOfRecordsViewController(patient: patient, authenticated: true, navStyle: .multiUser, hasUpdatedUnauthPendingTest: false)
//            return [vc1, vc2]
//        }
//    }
    
//    private func manualUnauthFetchRecordsStack(values: ActionScenarioValues) -> [BaseViewController] {
//        switch self.currentPatientScenario {
//        case .NoUsers, .OneAuthUser:
//            // Not possible here - after a successful manual fetch, there has to be at least 1 unauth patient
//            return []
//        case .OneUnauthUser:
//            // Stack should be UsersListOfRecordsViewController, then HealthRecordDetailViewController
//            guard let patient = values.recordFlowDetails?.actioningPatient else { return [] }
//            let vc1 = UsersListOfRecordsViewController.constructUsersListOfRecordsViewController(patient: patient, authenticated: false, navStyle: .singleUser, hasUpdatedUnauthPendingTest: false)
//            let recordsCount = StorageService.shared.getHeathRecords().detailDataSource(patient: patient).count
//            guard let record = values.recordFlowDetails?.addedRecord else { return [vc1] }
//            let vc2 = HealthRecordDetailViewController.constructHealthRecordDetailViewController(dataSource: record, authenticatedRecord: false, userNumberHealthRecords: recordsCount, patient: patient)
//            return [vc1, vc2]
//        case .MoreThanOneUnauthUser, .OneAuthUserAndOneUnauthUser, .OneAuthUserAndMoreThanOneUnauthUser:
//            // Stack should be HealthRecordsViewController, UsersListOfRecordsViewController, then HealthRecordDetailViewController
//            let vc1 = HealthRecordsViewController.constructHealthRecordsViewController()
//            guard let patient = values.recordFlowDetails?.actioningPatient else { return [vc1] }
//            let authenticated = self.currentPatientScenario == .MoreThanOneUnauthUser ? false : true
//            let vc2 = UsersListOfRecordsViewController.constructUsersListOfRecordsViewController(patient: patient, authenticated: authenticated, navStyle: .multiUser, hasUpdatedUnauthPendingTest: false)
//            guard let record = values.recordFlowDetails?.addedRecord else { return [vc1, vc2] }
//            let recordsCount = StorageService.shared.getHeathRecords().detailDataSource(patient: patient).count
//            let vc3 = HealthRecordDetailViewController.constructHealthRecordDetailViewController(dataSource: record, authenticatedRecord: false, userNumberHealthRecords: recordsCount, patient: patient)
//            return [vc1, vc2, vc3]
//        }
//    }
    
//    private func manuallyDeletedAllOfAnUnauthPatientRecordsForPatientRecordsStack(values: ActionScenarioValues) -> [BaseViewController] {
//        guard values.affectedTabs.contains(.records) else { return [] }
//        switch self.currentPatientScenario {
//        case .NoUsers:
//            // In this case, show initial fetch screen - stack should be FetchHealthRecordsViewController
//            let vc = FetchHealthRecordsViewController.constructFetchHealthRecordsViewController(hasHealthRecords: false)
//            return [vc]
//        case .OneAuthUser:
//            // This means that we have removed the only other unauth user and should show the auth user records by default UsersListOfRecordsViewController
//            // Note - hasUpdatedUnauthPendingTest doesnt matter here
//            guard let remainingAuthPatient = self.getAuthenticatedPatient else { return [] }
//            let vc = UsersListOfRecordsViewController.constructUsersListOfRecordsViewController(patient: remainingAuthPatient, authenticated: true, navStyle: .singleUser, hasUpdatedUnauthPendingTest: false)
//            return [vc]
//        case .OneUnauthUser:
//            // This means that we have removed an unauth user and should show the remaining unauth user records by default UsersListOfRecordsViewController
//            // Note - hasUpdatedUnauthPendingTest should be false here, to make sure that pending covid test result can be fetched in the background, just in case an update is required
//            guard let remainingUnauthPatient = self.getUnathenticatedPatients?.first else { return [] }
//            let vc = UsersListOfRecordsViewController.constructUsersListOfRecordsViewController(patient: remainingUnauthPatient, authenticated: false, navStyle: .singleUser, hasUpdatedUnauthPendingTest: false)
//            return [vc]
//        case .MoreThanOneUnauthUser, .OneAuthUserAndOneUnauthUser, .OneAuthUserAndMoreThanOneUnauthUser:
//            // In this case, just show the health records home screen with a list of folders
//            let vc = HealthRecordsViewController.constructHealthRecordsViewController()
//            return [vc]
//        }
//    }
    
//    private func manualLogOutRecordsStack(values: ActionScenarioValues) -> [BaseViewController] {
//        // Note - this is a unique case as we need to reset the stack in some cases, but still need to show the same screen
//        switch self.currentPatientScenario {
//        case .NoUsers:
//            let vc1 = FetchHealthRecordsViewController.constructFetchHealthRecordsViewController(hasHealthRecords: false)
//            guard values.currentTab == .records else { return [vc1] }
//            let vc2 = ProfileAndSettingsViewController.constructProfileAndSettingsViewController()
//            return [vc1, vc2]
//        case .OneAuthUser, .OneAuthUserAndOneUnauthUser, .OneAuthUserAndMoreThanOneUnauthUser:
//            // This isn't possible - after logout, there is no auth user
//            return []
//        case .OneUnauthUser:
//            guard let remainingUnauthPatient = self.getUnathenticatedPatients?.first else { return [] }
//            let vc1 = UsersListOfRecordsViewController.constructUsersListOfRecordsViewController(patient: remainingUnauthPatient, authenticated: false, navStyle: .singleUser, hasUpdatedUnauthPendingTest: false)
//            guard values.currentTab == .records else { return [vc1] }
//            let vc2 = ProfileAndSettingsViewController.constructProfileAndSettingsViewController()
//            return [vc1, vc2]
//        case .MoreThanOneUnauthUser:
//            let vc1 = HealthRecordsViewController.constructHealthRecordsViewController()
//            guard values.currentTab == .records else { return [vc1] }
//            let vc2 = ProfileAndSettingsViewController.constructProfileAndSettingsViewController()
//            return [vc1, vc2]
//        }
//    }
    
//    private func clearAllDataRecordsStack(values: ActionScenarioValues) -> [BaseViewController] {
//        let vc1 = FetchHealthRecordsViewController.constructFetchHealthRecordsViewController(hasHealthRecords: false)
//        guard values.currentTab == .records else { return [vc1] }
//        let vc2 = ProfileAndSettingsViewController.constructProfileAndSettingsViewController()
//        let vc3 = SecurityAndDataViewController.constructSecurityAndDataViewController()
//        return [vc1, vc2, vc3]
//    }
    
}

// MARK: Nav stack setup Health Passes
extension RouterWorker {
//    private func setupHealthPassNavStackForScenario(scenario: AppUserActionScenarios) -> [BaseViewController] {
//        switch scenario {
//        case .InitialAppLaunch(let values):
//            return initialAppLaunchPassesStack(values: values)
//        case .AuthenticatedFetch(let values):
//            return authenticatedFetchPassesStack(values: values)
//        case .ManualFetch(let values):
//            return manualUnauthFetchPassessStack(values: values)
//        case .ManuallyDeletedAllOfAnUnauthPatientRecords(let values):
//            return manuallyDeletedVaccineCardForPatientPassesStack(values: values)
//        case .Logout(let values):
//            return manualLogOutPassesStack(values: values)
//        case .ClearAllData(let values):
//            return clearAllDataPassesStack(values: values)
//        }
//    }
    
//    private func initialAppLaunchPassesStack(values: ActionScenarioValues) -> [BaseViewController] {
//        guard values.affectedTabs.contains(.healthPass) else { return [] }
//        let vc = HealthPassViewController.constructHealthPassViewController(fedPassStringToOpen: nil)
//        return [vc]
//    }
    // Patient scenario doesn't matter here, because a patient doesn't necessarily have a vaccine card
//    private func authenticatedFetchPassesStack(values: ActionScenarioValues) -> [BaseViewController] {
//        switch currentNumberOfVaccineCards {
//        case .NoCards, .OneCard:
//            let vc = HealthPassViewController.constructHealthPassViewController(fedPassStringToOpen: values.passesFlowDetails?.fedPassStringToOpen)
//            return [vc]
//        case .MultiplCards:
//            let vc1 = HealthPassViewController.constructHealthPassViewController(fedPassStringToOpen: nil)
//            let vc2 = CovidVaccineCardsViewController.constructCovidVaccineCardsViewController(recentlyAddedCardId: values.passesFlowDetails?.recentlyAddedCardId, fedPassStringToOpen: values.passesFlowDetails?.fedPassStringToOpen)
//            return [vc1, vc2]
//        }
//    }
    
//    private func manualUnauthFetchPassessStack(values: ActionScenarioValues) -> [BaseViewController] {
//        switch currentNumberOfVaccineCards {
//        case .NoCards, .OneCard:
//            let vc = HealthPassViewController.constructHealthPassViewController(fedPassStringToOpen: values.passesFlowDetails?.fedPassStringToOpen)
//            return [vc]
//        case .MultiplCards:
//            if values.passesFlowDetails?.fedPassAddedFromHealthPassVC == true {
//                let vc1 = HealthPassViewController.constructHealthPassViewController(fedPassStringToOpen: values.passesFlowDetails?.fedPassStringToOpen)
//                return [vc1]
//            } else {
//                let vc1 = HealthPassViewController.constructHealthPassViewController(fedPassStringToOpen: nil)
//                let vc2 = CovidVaccineCardsViewController.constructCovidVaccineCardsViewController(recentlyAddedCardId: values.passesFlowDetails?.recentlyAddedCardId, fedPassStringToOpen: values.passesFlowDetails?.fedPassStringToOpen)
//                return [vc1, vc2]
//            }
//        }
//    }
    // Patient scenario doesn't matter here, because a patient doesn't necessarily have a vaccine card
//    private func manuallyDeletedVaccineCardForPatientPassesStack(values: ActionScenarioValues) -> [BaseViewController] {
//        guard values.affectedTabs.contains(.healthPass) else { return [] }
//        switch currentNumberOfVaccineCards {
//        case .NoCards, .OneCard:
//            let vc = HealthPassViewController.constructHealthPassViewController(fedPassStringToOpen: nil)
//            return [vc]
//        case .MultiplCards:
//            let vc1 = HealthPassViewController.constructHealthPassViewController(fedPassStringToOpen: nil)
//            let vc2 = CovidVaccineCardsViewController.constructCovidVaccineCardsViewController(recentlyAddedCardId: nil, fedPassStringToOpen: nil)
//            return [vc1, vc2]
//        }
//    }
    
//    private func manualLogOutPassesStack(values: ActionScenarioValues) -> [BaseViewController] {
//        // Note - this is a unique case as we need to reset the stack in some cases, but still need to show the same screen
//        switch currentNumberOfVaccineCards {
//        case .NoCards, .OneCard:
//            let vc1 = HealthPassViewController.constructHealthPassViewController(fedPassStringToOpen: nil)
//            guard values.currentTab == .healthPass else { return [vc1] }
//            let vc2 = ProfileAndSettingsViewController.constructProfileAndSettingsViewController()
//            return [vc1, vc2]
//        case .MultiplCards:
//            let vc1 = HealthPassViewController.constructHealthPassViewController(fedPassStringToOpen: nil)
//            let vc2 = CovidVaccineCardsViewController.constructCovidVaccineCardsViewController(recentlyAddedCardId: nil, fedPassStringToOpen: nil)
//            guard values.currentTab == .healthPass else { return [vc1, vc2] }
//            let vc3 = ProfileAndSettingsViewController.constructProfileAndSettingsViewController()
//            return [vc1, vc2, vc3]
//        }
//    }
    
//    private func clearAllDataPassesStack(values: ActionScenarioValues) -> [BaseViewController] {
//        let vc1 = HealthPassViewController.constructHealthPassViewController(fedPassStringToOpen: nil)
//        guard values.currentTab == .healthPass else { return [vc1] }
//        let vc2 = ProfileAndSettingsViewController.constructProfileAndSettingsViewController()
//        let vc3 = SecurityAndDataViewController.constructSecurityAndDataViewController()
//        return [vc1, vc2, vc3]
//    }
    
}

// Essentially, here are the scenarios:
// 1: Action from passes tab:
/// - Passes tab will update accordingly, correct screen will show (and underlying stack)
/// - Records tab will retain same presented screen, but stack will be updated accordingly - exception is logging out, clearing data, and deleting vaccine card (if vaccine card is last record remaining of an unauth patient, and user is on his detailed record or that user list of records screen)
// 2: Action from records tab:
/// - Records tab will update accordingly, correct screen will show (and underlying stack)
/// - Passes tab will retain same presented screen, but stack will be updated accordingly - exception is logging out, clearing data, and deleting record (if record is vaccine pass)
