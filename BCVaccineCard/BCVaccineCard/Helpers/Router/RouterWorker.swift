//
//  RouterWorker.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2022-04-20.
//

import Foundation
// TODO: For Connor - continue with this approach and refactor app to use this methodology from TabBar controller so that all customized routing is done from one location
enum HealthRecordsStackActionScenarios {
    case AuthenticatedFetch(authUser: Patient?, unauthUsers: [Patient]?, actioningPatient: Patient)
    case ManualFetch(authUser: Patient?, unauthUsers: [Patient]?, actioningPatient: Patient)
    case DeletedAllOfThisPatientsRecords(authUser: Patient?, unauthUsers: [Patient]?, actioningPatient: Patient)
    case Logout(authUser: Patient?, unauthUsers: [Patient]?, actioningPatient: Patient)
    case SessionExpired(authUser: Patient?, unauthUsers: [Patient]?, actioningPatient: Patient)
    case InitialProtectedMedicalRecordsFetch(authUser: Patient?, unauthUsers: [Patient]?, actioningPatient: Patient)
}

protocol HealthRecordsRouterProtocol: AnyObject  {
    func recordsChanged(scenario: HealthRecordsStackActionScenarios)
}

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
