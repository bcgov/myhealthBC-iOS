//
//  ManageHomeScreenViewModel.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2023-07-26.
//

import Foundation

extension ManageHomeScreenViewController {
    struct ViewModel {
        var dataSource: [DataSource]
        var patientService: PatientService
        var originalHealthRecordString: String?
        var organDonorLinkEnabledInitially: Bool = false
        
        init() {
            self.dataSource = []
            self.patientService = PatientService(network: AFNetwork(), authManager: AuthManager(), configService: MobileConfigService(network: AFNetwork()))
        }
        
        mutating func createDataSourceForManageScreen() {

            var storedQuickLinks: [QuickLinksPreferences]
            guard let phn = StorageService.shared.fetchAuthenticatedPatient()?.phn else {
                storedQuickLinks = QuickLinksPreferences.constructEmptyPreferences()
                return 
            }
            storedQuickLinks = Defaults.getStoredPreferencesFor(phn: phn)
            if storedQuickLinks.isEmpty {
                storedQuickLinks = QuickLinksPreferences.constructEmptyPreferences()
            }
            var ds: [DataSource] = []
            ds.append(DataSource.introText)
            
            var recordsOrder: [QuickLinksPreferences.QuickLinksNames] = []
            
            if Defaults.enabledTypes?.contains(dataset: .Note) == true && HealthRecordConstants.notesEnabled == true {
                recordsOrder.append(.MyNotes)
            }
            
            recordsOrder.append(contentsOf: [
                .Immunizations,
                .Medications,
                .LabResults,
                .COVID19Tests,
                .SpecialAuthority,
                .HospitalVisits,
                .HealthVisits,
                .ClinicalDocuments,
                .ImagingReports,
                .BCCancerScreening
            ])
            
            let healthRecords = constructSectionTypes(storedPreferences: storedQuickLinks, for: .HealthRecord, order: recordsOrder)
            ds.append(DataSource.healthRecord(types: healthRecords))
            
            let serviceOrder: [QuickLinksPreferences.QuickLinksNames] = [
                .OrganDonor
            ]
            let serviceRecords = constructSectionTypes(storedPreferences: storedQuickLinks, for: .Service, order: serviceOrder)
            ds.append(DataSource.service(types: serviceRecords))
            
            self.dataSource = ds
        }
        
        func convertDataSourceToPreferencesAndSave(for phn: String, completion: @escaping() -> Void) {
            var updatedPreferences: [QuickLinksPreferences] = []
            for type in self.dataSource {
                switch type {
                case .introText:
                    break
                case .healthRecord(types: let types), .service(types: let types):
                    updatedPreferences.append(contentsOf: types)
                }
            }
            Defaults.updateStoredPreferences(phn: phn, newPreferences: updatedPreferences)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                completion()
            }
        }
        
        private func constructSectionTypes(storedPreferences: [QuickLinksPreferences],
                                           for type: QuickLinksPreferences.QuickLinksNames.Section,
                                           order: [QuickLinksPreferences.QuickLinksNames]) -> [QuickLinksPreferences] {
            let toggleEnabledFeatures: [QuickLinksPreferences.QuickLinksNames]
            switch type {
            case .HealthRecord:
                toggleEnabledFeatures = QuickLinksPreferences.convertFeatureToggleToQuickLinksPreferences(for: .HealthRecord)
            case .Service:
                toggleEnabledFeatures = QuickLinksPreferences.convertFeatureToggleToQuickLinksPreferences(for: .Service)
            }
            var adjustedPreferences = storedPreferences.filter { $0.name.getSection == type }
            let ds: [QuickLinksPreferences] = order.map { name in
                if let index = adjustedPreferences.firstIndex(where: { $0.name == name }) {
                    let isFeatureToggleEnabled = QuickLinksPreferences.isFeatureEnabled(feature: name, enabledTypes: toggleEnabledFeatures)
                    adjustedPreferences[index].includedInFeatureToggle = isFeatureToggleEnabled
                    return adjustedPreferences[index]
                } else {
                    // Should never get here because all records are stored, but we should find a better way to satisfy this constraint
                    return QuickLinksPreferences(name: name, enabled: false, includedInFeatureToggle: QuickLinksPreferences.isFeatureEnabled(feature: name, enabledTypes: toggleEnabledFeatures))
                }
            }
            return ds
        }
        
        
    }
    
    enum DataSource {
        case introText
        case healthRecord(types: [QuickLinksPreferences])
        case service(types: [QuickLinksPreferences])
        
        var getSectionTitle: String? {
            switch self {
            case .introText: return nil
            case .healthRecord: return QuickLinksPreferences.QuickLinksNames.Section.HealthRecord.rawValue
            case .service: return QuickLinksPreferences.QuickLinksNames.Section.Service.rawValue
            }
        }
        
        func constructNewTypesOnEnabled(enabled: Bool, indexPath: IndexPath) -> [QuickLinksPreferences]? {
            switch self {
            case .introText: return nil
            case .healthRecord(types: let types), .service(types: let types):
                var newTypes = types
                newTypes[indexPath.row].enabled = enabled
                newTypes[indexPath.row].addedDate = Date()
                return newTypes
            }
        }
    }
    
}


        
