//
//  ScreenStateManager.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2022-04-25.
//

// Note: Screen state events:
// SessionExpiredWhileAppOpen
// InitialProtectedMedicalRecordsFetch
// SessionExpiredAuthenticatedFetch

// Need to find a way to update screen state at the appropriate time (IE, after a full medical fetch is completed, and not every time a record is added - as a user with 1000 records will reload their table view 1000 times, which will block the UI) - or maybe we reload after adding an entire record type

// Events should be:
// 1 - Manually deleted record
// 2 - Authenticated Fetch completed (manual or session refetch or background fetch)
// 3 - Session expired while user is in app
// 4 - InitialProtectedMedicalRecordsFetch
// 5 - User authenticates

import UIKit

// Just putting this here for now so that I have a reference somewhere for what my though process was...

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
