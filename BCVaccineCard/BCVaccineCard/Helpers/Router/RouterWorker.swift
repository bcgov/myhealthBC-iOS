////
////  RouterWorker.swift
////  BCVaccineCard
//
////  Created by Connor Ogilvie on 2022-04-20.
//
//// Rules are - Use router worker to construct the nav stack
//// Use Storage changes to adjust screen state on a given screen (storage change should not pop or push or adjust nav stack on its own)
//
//import UIKit
//// Note for Developer: CurrentPatientScenarios are for the result after the action
//enum CurrentPatientScenarios {
//    case NoUsers
//    case OneAuthUser
//    
//    static func getCurrentScenario(authCount: Int) -> Self {
//        if authCount == 0 {
//            return .NoUsers
//        } else if authCount == 1 {
//            return .OneAuthUser
//        } else {
//            return .NoUsers
//        }
//    }
//}
//
//enum VaccineCardNumber {
//    case NoCards
//    case OneCard
//    case MultipleCards
//    
//    static func getCurrentNumber(cards: Int) -> Self {
//        if cards == 0 {
//            return .NoCards
//        } else if cards == 1 {
//            return .OneCard
//        } else {
//            return .MultipleCards
//        }
//    }
//}
//
//enum AppUserActionScenarios {
//    case InitialAppLaunch(values: ActionScenarioValues)
//    case LoginSpecialRouting(values: ActionScenarioValues)
//    case TermsOfServiceRejected(values: ActionScenarioValues)
//    case AuthenticatedFetch(values: ActionScenarioValues)
//    case ManualFetch(values: ActionScenarioValues)
//    case ManuallyDeletedAllOfAnUnauthPatientRecords(values: ActionScenarioValues)
//    case Logout(values: ActionScenarioValues)
//    case ClearAllData(values: ActionScenarioValues)
//}
//
//struct ActionScenarioValues {
//    let currentTab: TabBarVCs
//    var affectedTabs: [TabBarVCs] = [.healthPass, .records]
//    var recordFlowDetails: RecordsFlowDetails?
//    var passesFlowDetails: PassesFlowDetails?
//    var loginSourceVC: LoginVCSource?
//    var authenticationStatus: AuthenticationViewController.AuthenticationStatus?
//}
//
//struct CurrentRecordsAndPassesStacks {
//    let recordsStack: [RecordsFlowVCs]
//    let passesStack: [PassesFlowVCs]
//}
//
//enum RecordsFlowVCs {
//    case HealthRecordsViewController
//    case UsersListOfRecordsViewController(patient: Patient?)
//    case HealthRecordDetailViewController(patient: Patient?, dataSource: HealthRecordsDetailDataSource, userNumberHealthRecords: Int)
//    case ProfileAndSettingsViewController
//    case SecurityAndDataViewController
//    
//    enum NonAssociatedVersion {
//        case HealthRecordsViewController
//        case UsersListOfRecordsViewController
//        case HealthRecordDetailViewController
//        case ProfileAndSettingsViewController
//        case SecurityAndDataViewController
//        
//        func getIndexFromArray(array: [RecordsFlowVCs]) -> Int? {
//            return array.map { $0.getNonAssociatedVersion }.firstIndex(of: self)
//        }
//    }
//    
//    var getNonAssociatedVersion: NonAssociatedVersion {
//        switch self {
//        case .HealthRecordsViewController:
//            return .HealthRecordsViewController
//        case .UsersListOfRecordsViewController:
//            return .UsersListOfRecordsViewController
//        case .HealthRecordDetailViewController:
//            return .HealthRecordDetailViewController
//        case .ProfileAndSettingsViewController:
//            return .ProfileAndSettingsViewController
//        case .SecurityAndDataViewController:
//            return .SecurityAndDataViewController
//        }
//    }
//}
//
//enum PassesFlowVCs {
//    case HealthPassViewController(fedPassToOpen: String?)
//    case CovidVaccineCardsViewController(fedPassToOpen: String?, recentlyAddedCardId: String?)
//    case QRRetrievalMethodViewController
//    case ProfileAndSettingsViewController
//    case SecurityAndDataViewController
//    case GatewayFormViewController(rememberDetails: RememberedGatewayDetails, fetchType: GatewayFormViewControllerFetchType, gatewayInProgressDetails: GatewayInProgressDetails?)
//    
//    enum NonAssociatedVersion {
//        case HealthPassViewController
//        case CovidVaccineCardsViewController
//        case QRRetrievalMethodViewController
//        case ProfileAndSettingsViewController
//        case SecurityAndDataViewController
//        case GatewayFormViewController
//        
//        func getIndexFromArray(array: [PassesFlowVCs]) -> Int? {
//            return array.map { $0.getNonAssociatedVersion }.firstIndex(of: self)
//        }
//    }
//    
//    var getNonAssociatedVersion: NonAssociatedVersion {
//        switch self {
//        case .HealthPassViewController:
//            return .HealthPassViewController
//        case .CovidVaccineCardsViewController:
//            return .CovidVaccineCardsViewController
//        case .QRRetrievalMethodViewController:
//            return .QRRetrievalMethodViewController
//        case .ProfileAndSettingsViewController:
//            return .ProfileAndSettingsViewController
//        case .SecurityAndDataViewController:
//            return .SecurityAndDataViewController
//        case .GatewayFormViewController:
//            return .GatewayFormViewController
//        }
//    }
//}
//
//struct RecordsFlowDetails {
//    let currentStack: [RecordsFlowVCs]
//    var actioningPatient: Patient? = nil
//    var addedRecord: HealthRecordsDetailDataSource? = nil
//}
//
//struct PassesFlowDetails {
//    let currentStack: [PassesFlowVCs]
//    var recentlyAddedCardId: String? = nil
//    var fedPassStringToOpen: String? = nil
//    var fedPassAddedFromHealthPassVC: Bool? = nil
//}
//
//protocol RouterWorkerDelegate: AnyObject  {
//    func recordsActionScenario(viewControllerStack: [BaseViewController], goToTab: Bool, delayInSeconds: Double)
//    func passesActionScenario(viewControllerStack: [BaseViewController], goToTab: Bool, delayInSeconds: Double)
//}
//
//struct NavStacks {
//    let recordsStack: [BaseViewController]
//    let passesStack: [BaseViewController]
//}
//
//class RouterWorker: NSObject {
//    
//    weak private var delegate: RouterWorkerDelegate?
//    
//    private var getAuthenticatedPatient: Patient? {
//        return StorageService.shared.fetchAuthenticatedPatient()
//    }
//    
//    private var currentPatientScenario: CurrentPatientScenarios {
//        let authPatientCount = self.getAuthenticatedPatient != nil ? 1 : 0
//        return CurrentPatientScenarios.getCurrentScenario(authCount: authPatientCount)
//    }
//    
//    // Note: We really don't need this anymore, however, leaving it for when we potentially have to support dependants of an auth user
//    private var userRecordsNavStyle: UsersListOfRecordsViewController.NavStyle {
//        let authPatientCount = self.getAuthenticatedPatient != nil ? 1 : 0
//        return authPatientCount > 1 ? .multiUser : .singleUser
//    }
//    
//    private var currentNumberOfVaccineCards: VaccineCardNumber {
//        let count = StorageService.shared.fetchVaccineCards().count
//        return VaccineCardNumber.getCurrentNumber(cards: count)
//    }
//    
//    init(delegateOwner: UIViewController) {
//        self.delegate = delegateOwner as? RouterWorkerDelegate
//    }
//    
//    public func routingAction(scenario: AppUserActionScenarios, goToTab: TabBarVCs? = nil, delayInSeconds: Double = 0.0) {
//        let stack = setupRecordsAndPassesNavStacks(scenario: scenario)
//        self.delegate?.recordsActionScenario(viewControllerStack: stack.recordsStack, goToTab: goToTab == .records, delayInSeconds: delayInSeconds)
//        self.delegate?.passesActionScenario(viewControllerStack: stack.passesStack, goToTab: goToTab == .healthPass, delayInSeconds: delayInSeconds)
//    }
//}
//
//// MARK: Nav stack setup for both records and passes tab
//extension RouterWorker {
//    private func setupRecordsAndPassesNavStacks(scenario: AppUserActionScenarios) -> NavStacks {
//        let recordsStack: [BaseViewController]
//        let passesStack: [BaseViewController]
//        switch scenario {
//        case .InitialAppLaunch(let values):
//            recordsStack = initialLaunchRecordsStacks(values: values)
//            passesStack = initialLaunchPassesStack(values: values)
//        case .LoginSpecialRouting(let values):
//            recordsStack = loginSpecialRoutingRecordsStack(values: values)
//            passesStack = loginSpecialRoutingPassesStack(values: values)
//        case .TermsOfServiceRejected(let values):
//            recordsStack = termsOfServiceRejectedRecordsStack(values: values)
//            passesStack = termsOfServiceRejectedPassesStack(values: values)
//        case .AuthenticatedFetch(let values):
//            recordsStack = authFetchRecordsStack(values: values)
//            passesStack = authFetchPassesStack(values: values)
//        case .ManualFetch(let values):
//            recordsStack = manualFetchRecordsStack(values: values)
//            passesStack = manualFetchPassesStack(values: values)
//        case .ManuallyDeletedAllOfAnUnauthPatientRecords(let values):
//            recordsStack = manualDeleteRecordsStack(values: values)
//            passesStack = manualDeletePassesStack(values: values)
//        case .Logout(let values):
//            recordsStack = logoutRecordsStack(values: values)
//            passesStack = logoutPassesStack(values: values)
//        case .ClearAllData(let values):
//            recordsStack = clearAllDataRecordsStack(values: values)
//            passesStack = clearAllDataPassesStack(values: values)
//        }
//        return NavStacks(recordsStack: recordsStack, passesStack: passesStack)
//    }
//    
//    private func initialLaunchRecordsStacks(values: ActionScenarioValues) -> [BaseViewController] {
//        guard values.affectedTabs.contains(.records) else { return [] }
//        switch self.currentPatientScenario {
//        case .NoUsers:
//            let vc = HealthRecordsViewController.constructHealthRecordsViewController()
//            return [vc]
//        case .OneAuthUser:
//            guard let patient = self.getAuthenticatedPatient else {
//                let vc = HealthRecordsViewController.constructHealthRecordsViewController()
//                return [vc]
//            }
//            let vc = UsersListOfRecordsViewController.constructUsersListOfRecordsViewController(patient: patient, authenticated: true, navStyle: .singleUser, hasUpdatedUnauthPendingTest: false)
//            return [vc]
//        }
//    }
//    
//    private func initialLaunchPassesStack(values: ActionScenarioValues) -> [BaseViewController] {
//        guard values.affectedTabs.contains(.healthPass) else { return [] }
//        let vc = HealthPassViewController.constructHealthPassViewController(fedPassStringToOpen: nil)
//        return [vc]
//    }
//    
//    private func loginSpecialRoutingRecordsStack(values: ActionScenarioValues) -> [BaseViewController] {
//        guard let authenticationStatus = values.authenticationStatus else { return [] }
//        switch authenticationStatus {
//        case .Completed:
//            let vc1 = UsersListOfRecordsViewController.constructUsersListOfRecordsViewController(patient: nil, authenticated: true, navStyle: .singleUser, hasUpdatedUnauthPendingTest: true)
//            guard let profileScreen = values.recordFlowDetails?.currentStack.last?.getNonAssociatedVersion, profileScreen == RecordsFlowVCs.NonAssociatedVersion.ProfileAndSettingsViewController, values.currentTab == TabBarVCs.records else { return [vc1] }
//            let vc2 = ProfileAndSettingsViewController.constructProfileAndSettingsViewController()
//            return [vc1, vc2]
//        case .Cancelled:
//            return []
//        case .Failed:
//            let vc = HealthRecordsViewController.constructHealthRecordsViewController()
//            return [vc]
//        }
//    }
//    
//    // Note - we don't need to do anything here
//    private func loginSpecialRoutingPassesStack(values: ActionScenarioValues) -> [BaseViewController] {
//        return []
//    }
//    
//    private func termsOfServiceRejectedRecordsStack(values: ActionScenarioValues) -> [BaseViewController] {
//        // Terms of service have been rejected, so records tab should be reset to default
//        let vc1 = HealthRecordsViewController.constructHealthRecordsViewController()
//        guard let profileScreen = values.recordFlowDetails?.currentStack.last?.getNonAssociatedVersion, profileScreen == RecordsFlowVCs.NonAssociatedVersion.ProfileAndSettingsViewController, values.currentTab == TabBarVCs.records else { return [vc1] }
//        let vc2 = ProfileAndSettingsViewController.constructProfileAndSettingsViewController()
//        return [vc1, vc2]
//    }
//    
//    private func termsOfServiceRejectedPassesStack(values: ActionScenarioValues) -> [BaseViewController] {
//        // Shouldn't need to do anything here
//        return []
//    }
//    
//    private func authFetchRecordsStack(values: ActionScenarioValues) -> [BaseViewController] {
//        if values.currentTab == .records {
//            switch self.currentPatientScenario {
//            case .NoUsers:
//                // Not possible here - after an authFetch, there has to be at least one Auth user, so do nothing
//                return []
//            case .OneAuthUser:
//                // Stack should be UsersListOfRecordsViewController (after fetch is completed)
//                // Note - hasUpdatedUnauthPendingTest is irrelevant here
//                guard let patient = values.recordFlowDetails?.actioningPatient else { return [] }
//                let vc = UsersListOfRecordsViewController.constructUsersListOfRecordsViewController(patient: patient, authenticated: true, navStyle: .singleUser, hasUpdatedUnauthPendingTest: true)
//                return [vc]
//            }
//        }
//        else {
//            return self.resetRecordsTab()
//        }
//        
//    }
//    
//    private func authFetchPassesStack(values: ActionScenarioValues) -> [BaseViewController] {
//        if values.currentTab == .healthPass {
//            switch currentNumberOfVaccineCards {
//            case .NoCards, .OneCard:
//                let vc = HealthPassViewController.constructHealthPassViewController(fedPassStringToOpen: values.passesFlowDetails?.fedPassStringToOpen)
//                return [vc]
//            case .MultipleCards:
//                let vc1 = HealthPassViewController.constructHealthPassViewController(fedPassStringToOpen: nil)
//                let vc2 = CovidVaccineCardsViewController.constructCovidVaccineCardsViewController(recentlyAddedCardId: values.passesFlowDetails?.recentlyAddedCardId, fedPassStringToOpen: values.passesFlowDetails?.fedPassStringToOpen)
//                return [vc1, vc2]
//            }
//        } else {
//            return self.resetPassesTab()
//        }
//    }
//    
//    private func manualFetchRecordsStack(values: ActionScenarioValues) -> [BaseViewController] {
//        if values.currentTab == .records {
//            switch self.currentPatientScenario {
//            case .NoUsers, .OneAuthUser:
//                // Not possible here - manual fetch is only for vaccine cards, won't show up in records tab
//                return []
//            }
//        }
//        else {
////            return self.resetRecordsTab()
//            return []
//        }
//    }
//    
//    private func manualFetchPassesStack(values: ActionScenarioValues) -> [BaseViewController] {
//        if values.currentTab == .healthPass {
//            switch currentNumberOfVaccineCards {
//            case .NoCards, .OneCard:
//                let vc = HealthPassViewController.constructHealthPassViewController(fedPassStringToOpen: values.passesFlowDetails?.fedPassStringToOpen)
//                return [vc]
//            case .MultipleCards:
//                if values.passesFlowDetails?.fedPassAddedFromHealthPassVC == true {
//                    let vc1 = HealthPassViewController.constructHealthPassViewController(fedPassStringToOpen: values.passesFlowDetails?.fedPassStringToOpen)
//                    return [vc1]
//                } else {
//                    let vc1 = HealthPassViewController.constructHealthPassViewController(fedPassStringToOpen: nil)
//                    let vc2 = CovidVaccineCardsViewController.constructCovidVaccineCardsViewController(recentlyAddedCardId: values.passesFlowDetails?.recentlyAddedCardId, fedPassStringToOpen: values.passesFlowDetails?.fedPassStringToOpen)
//                    return [vc1, vc2]
//                }
//            }
//        } else {
//            return self.resetPassesTab()
//        }
//    }
//    
//    private func manualDeleteRecordsStack(values: ActionScenarioValues) -> [BaseViewController] {
//        if values.currentTab == .records {
//            guard values.affectedTabs.contains(.records) else { return [] }
//            switch self.currentPatientScenario {
//            case .NoUsers, .OneAuthUser:
//                // Not possible here - manual delete is only for vaccine cards, won't show up in records tab
//                return []
//            }
//        }
//        else {
////            return self.resetRecordsTab()
//            return []
//        }
//    }
//    
//    private func manualDeletePassesStack(values: ActionScenarioValues) -> [BaseViewController] {
//        if values.currentTab == .healthPass {
//            guard values.affectedTabs.contains(.healthPass) else { return [] }
//            switch currentNumberOfVaccineCards {
//            case .NoCards, .OneCard:
//                let vc = HealthPassViewController.constructHealthPassViewController(fedPassStringToOpen: nil)
//                return [vc]
//            case .MultipleCards:
//                let vc1 = HealthPassViewController.constructHealthPassViewController(fedPassStringToOpen: nil)
//                let vc2 = CovidVaccineCardsViewController.constructCovidVaccineCardsViewController(recentlyAddedCardId: nil, fedPassStringToOpen: nil)
//                return [vc1, vc2]
//            }
//        } else {
//            return self.resetPassesTab()
//        }
//    }
//    
//    private func logoutRecordsStack(values: ActionScenarioValues) -> [BaseViewController] {
//        if values.currentTab == .records {
//            switch self.currentPatientScenario {
//            case .NoUsers:
//                let vc1 = HealthRecordsViewController.constructHealthRecordsViewController()
//                guard values.currentTab == .records else { return [vc1] }
//                let vc2 = ProfileAndSettingsViewController.constructProfileAndSettingsViewController()
//                return [vc1, vc2]
//            case .OneAuthUser:
//                // This isn't possible - after logout, there is no auth user
//                return []
//            }
//        } else {
//            return self.resetRecordsTab()
//        }
//    }
//    
//    private func logoutPassesStack(values: ActionScenarioValues) -> [BaseViewController] {
//        if values.currentTab == .healthPass {
//            switch currentNumberOfVaccineCards {
//            case .NoCards, .OneCard:
//                let vc1 = HealthPassViewController.constructHealthPassViewController(fedPassStringToOpen: nil)
//                guard values.currentTab == .healthPass else { return [vc1] }
//                let vc2 = ProfileAndSettingsViewController.constructProfileAndSettingsViewController()
//                return [vc1, vc2]
//            case .MultipleCards:
//                let vc1 = HealthPassViewController.constructHealthPassViewController(fedPassStringToOpen: nil)
//                let vc2 = CovidVaccineCardsViewController.constructCovidVaccineCardsViewController(recentlyAddedCardId: nil, fedPassStringToOpen: nil)
//                guard values.currentTab == .healthPass else { return [vc1, vc2] }
//                let vc3 = ProfileAndSettingsViewController.constructProfileAndSettingsViewController()
//                return [vc1, vc2, vc3]
//            }
//        } else {
//            return self.resetPassesTab()
//        }
//    }
//    
//    private func clearAllDataRecordsStack(values: ActionScenarioValues) -> [BaseViewController] {
//        if values.currentTab == .records {
//            let vc1 = HealthRecordsViewController.constructHealthRecordsViewController()
//            guard values.currentTab == .records else { return [vc1] }
//            let vc2 = ProfileAndSettingsViewController.constructProfileAndSettingsViewController()
//            let vc3 = SecurityAndDataViewController.constructSecurityAndDataViewController()
//            return [vc1, vc2, vc3]
//        } else {
//            return self.resetRecordsTab()
//        }
//    }
//    
//    private func clearAllDataPassesStack(values: ActionScenarioValues) -> [BaseViewController] {
//        if values.currentTab == .healthPass {
//            let vc1 = HealthPassViewController.constructHealthPassViewController(fedPassStringToOpen: nil)
//            guard values.currentTab == .healthPass else { return [vc1] }
//            let vc2 = ProfileAndSettingsViewController.constructProfileAndSettingsViewController()
//            let vc3 = SecurityAndDataViewController.constructSecurityAndDataViewController()
//            return [vc1, vc2, vc3]
//        } else {
//            return self.resetPassesTab()
//        }
//    }
//}
//
//// MARK: Temporary for resetting each tab when tab is not selected during action
//extension RouterWorker {
//    private func resetRecordsTab() -> [BaseViewController] {
//        switch self.currentPatientScenario {
//        case .NoUsers:
//            let vc = HealthRecordsViewController.constructHealthRecordsViewController()
//            return [vc]
//        case .OneAuthUser:
//            guard let patient = self.getAuthenticatedPatient else { return [] }
//            let vc = UsersListOfRecordsViewController.constructUsersListOfRecordsViewController(patient: patient, authenticated: true, navStyle: .singleUser, hasUpdatedUnauthPendingTest: false)
//            return [vc]
//        }
//    }
//    
//    private func resetPassesTab() -> [BaseViewController] {
//        return [HealthPassViewController.constructHealthPassViewController(fedPassStringToOpen: nil)]
//    }
//}
//
//
//
//
//
//
//
//
//
//
//
//// FIXME: Finish this then replace with the temp tab resets
//// MARK: Setting up stack from current view controllers - finish this later
//extension RouterWorker {
//    
//    private func constructNewRecordsStack(newStack: [RecordsFlowVCs]) -> [BaseViewController] {
//        var newVCStack: [BaseViewController] = []
//        newStack.forEach { stack in
//            let vc: BaseViewController?
//            switch stack {
//            case .HealthRecordsViewController:
//                vc = HealthRecordsViewController.constructHealthRecordsViewController()
//            case .UsersListOfRecordsViewController(patient: let patient):
//                guard let patient = patient else { return }
//                vc = UsersListOfRecordsViewController.constructUsersListOfRecordsViewController(patient: patient, authenticated: patient.authenticated, navStyle: self.userRecordsNavStyle, hasUpdatedUnauthPendingTest: false)
//            case .HealthRecordDetailViewController(patient: let patient, dataSource: let dataSource, userNumberHealthRecords: let userNumberHealthRecords):
//                vc = HealthRecordDetailViewController.constructHealthRecordDetailViewController(dataSource: dataSource, authenticatedRecord: dataSource.isAuthenticated, userNumberHealthRecords: userNumberHealthRecords, patient: patient)
//            case .ProfileAndSettingsViewController:
//                vc = ProfileAndSettingsViewController.constructProfileAndSettingsViewController()
//            case .SecurityAndDataViewController:
//                vc = SecurityAndDataViewController.constructSecurityAndDataViewController()
//            }
//            if let vc = vc {
//                newVCStack.append(vc)
//            }
//        }
//        return newVCStack
//    }
//    // TODO: Once this is finished, create something similar for passes stack
//    // Note: Use this if user is not currently on records tab
//    private func modifyRecordsStackIfNecessary(currentPatientScenarioAfterAction scenario: CurrentPatientScenarios, currentRecordsStack: [RecordsFlowVCs], relevantPatient: Patient) -> [RecordsFlowVCs] {
//        switch scenario {
//        case .NoUsers:
//            // Check if currentRecordsStack contains healthRecordsVC or userListOfRecordsVC or recordsDetailVC - if so, then remove those from the stack. Make sure fetchVC is the base VC here
//            var recordsStack = currentRecordsStack
//            if let index = RecordsFlowVCs.NonAssociatedVersion.UsersListOfRecordsViewController.getIndexFromArray(array: recordsStack) {
//                recordsStack.remove(at: index)
//            }
//            if let index = RecordsFlowVCs.NonAssociatedVersion.HealthRecordDetailViewController.getIndexFromArray(array: recordsStack) {
//                recordsStack.remove(at: index)
//            }
//            if let index = RecordsFlowVCs.NonAssociatedVersion.HealthRecordsViewController.getIndexFromArray(array: recordsStack) {
//                let healthRecordsVC = recordsStack.remove(at: index)
//                recordsStack.insert(healthRecordsVC, at: 0)
//            } else {
//                let healthRecordsVC = RecordsFlowVCs.HealthRecordsViewController
//                recordsStack.insert(healthRecordsVC, at: 0)
//            }
//            return recordsStack
////        case .OneAuthUser:
////            <#code#>
//        default: return []
//        }
//    }
//    
//    private func constructNewPassesStack(newStack: [PassesFlowVCs]) -> [BaseViewController] {
//        var newVCStack: [BaseViewController] = []
//        newStack.forEach { stack in
//            let vc: BaseViewController?
//            switch stack {
//            case .HealthPassViewController(fedPassToOpen: let fedPassStringToOpen):
//                vc = HealthPassViewController.constructHealthPassViewController(fedPassStringToOpen: fedPassStringToOpen)
//            case .CovidVaccineCardsViewController(fedPassToOpen: let fedPassStringToOpen, recentlyAddedCardId: let recentlyAddedCardId):
//                vc = CovidVaccineCardsViewController.constructCovidVaccineCardsViewController(recentlyAddedCardId: recentlyAddedCardId, fedPassStringToOpen: fedPassStringToOpen)
//            case .QRRetrievalMethodViewController:
//                vc = QRRetrievalMethodViewController.constructQRRetrievalMethodViewController()
//            case .ProfileAndSettingsViewController:
//                vc = ProfileAndSettingsViewController.constructProfileAndSettingsViewController()
//            case .SecurityAndDataViewController:
//                vc = SecurityAndDataViewController.constructSecurityAndDataViewController()
//            case .GatewayFormViewController(rememberDetails: let rememberDetails, fetchType: let fetchType, gatewayInProgressDetails: let currentProgress):
//                vc = GatewayFormViewController.constructGatewayFormViewController(rememberDetails: rememberDetails, fetchType: fetchType, currentProgress: currentProgress)
//            }
//            if let vc = vc {
//                newVCStack.append(vc)
//            }
//        }
//        return newVCStack
//    }
//}
