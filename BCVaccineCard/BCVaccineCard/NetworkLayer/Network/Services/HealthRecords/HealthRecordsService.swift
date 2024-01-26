//
//  HealthRecordsService.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2022-10-24.
//

import UIKit

struct HealthRecordsService {
    
    let network: Network
    let authManager: AuthManager
    let configService: MobileConfigService
    
    private var endpoints: UrlAccessor {
        return UrlAccessor()
    }
    
    public func fetchAndStore(for patient: Patient, protectiveWord: String?, completion: @escaping ([HealthRecord],_ hadFailures: Bool)->Void) {
        
        let dispatchGroup = DispatchGroup()
        var records: [HealthRecord] = []
    
        network.addLoader(message: .SyncingRecords, caller: .HealthRecordsService_fetchAndStore)
        Logger.log(string: "fetching patient records for \(patient.name)", type: .Network)
        let typesToFetch = patient.isDependent() ? EnabledTypes.convertToHealthRecordType(types: Defaults.enabledTypes?.dependentDatasets ?? []) : EnabledTypes.convertToHealthRecordType(types: Defaults.enabledTypes?.datasets ?? [])
        if patient.isDependent(), let dependent = patient.dependencyInfo {
            StorageService.shared.deleteHealthRecordsForDependent(dependent: dependent)
        }
        var hadFailures = false
        for recordType in typesToFetch {
            dispatchGroup.enter()
            switch recordType {
            case .CovidTest:
                let covidTestsService = CovidTestsService(network: network, authManager: authManager, configService: configService)
                
                covidTestsService.fetchAndStore(for: patient) { result in
                    guard let result = result else {
                        hadFailures = true
                        dispatchGroup.leave()
                        return
                    }
                    
                    let uwreapped = result.map({HealthRecord(type: .CovidTest($0))})
                    records.append(contentsOf: uwreapped)
                    dispatchGroup.leave()
                    
                }
            case .VaccineCard:
                let vaccineCardService = VaccineCardService(network: network, authManager: authManager, configService: configService)
                vaccineCardService.fetchAndStore(for: patient) { result in
                    guard let result = result else {
                        hadFailures = true
                        dispatchGroup.leave()
                        return
                    }
                    let covidRec = HealthRecord(type: .CovidImmunization(result))
                    records.append(covidRec)
                    dispatchGroup.leave()
                }
            case .Prescription:
                let medicationService = MedicationService(network: network, authManager: authManager, configService: configService)
                medicationService.fetchAndStore(for: patient, protectiveWord: protectiveWord) { result, error in
                    guard let result = result else {
                        hadFailures = true
                        dispatchGroup.leave()
                        return
                    }
                    let uwreapped = result.map({HealthRecord(type: .Medication($0))})
                    records.append(contentsOf: uwreapped)
                    dispatchGroup.leave()
                }
            case .LaboratoryOrder:
                let labOrderService = LabOrderService(network: network, authManager: authManager, configService: configService)
                labOrderService.fetchAndStore(for: patient) { result in
                    guard let result = result else {
                        hadFailures = true
                        dispatchGroup.leave()
                        return
                    }
                    let uwreapped = result.map({HealthRecord(type: .LaboratoryOrder($0))})
                    records.append(contentsOf: uwreapped)
                    dispatchGroup.leave()
                }
            case .Immunization:
                let immunizationsService = ImmnunizationsService(network: network, authManager: authManager, configService: configService)
                immunizationsService.fetchAndStore(for: patient) { result in
                    guard let result = result else {
                        hadFailures = true
                        dispatchGroup.leave()
                        return
                    }
                    let uwreapped = result.map({HealthRecord(type: .Immunization($0))})
                    records.append(contentsOf: uwreapped)
                    dispatchGroup.leave()
                }
            case .Recommendation:
                dispatchGroup.leave()
            case .HealthVisit:
                let service = HealthVisitsService(network: network, authManager: authManager, configService: configService)
                service.fetchAndStore(for: patient) { result in
                    guard let result = result else {
                        hadFailures = true
                        dispatchGroup.leave()
                        return
                    }
                    let unwrapped = result.map({HealthRecord(type: .HealthVisit($0))})
                    records.append(contentsOf: unwrapped)
                    dispatchGroup.leave()
                }
            case .SpecialAuthorityDrug:
                let service = SpecialAuthorityDrugService(network: network, authManager: authManager, configService: configService)
                service.fetchAndStore(for: patient) { result in
                    guard let result = result else {
                        hadFailures = true
                        dispatchGroup.leave()
                        return
                    }
                    let unwrapped = result.map({HealthRecord(type: .SpecialAuthorityDrug($0))})
                    records.append(contentsOf: unwrapped)
                    dispatchGroup.leave()
                }
            case .HospitalVisit:
                let hospitalVisitService = HospitalVisitsService(network: network, authManager: authManager, configService: configService)
                hospitalVisitService.fetchAndStore(for: patient) { result in
                    guard let result = result else {
                        hadFailures = true
                        dispatchGroup.leave()
                        return
                    }
                    let uwreapped = result.map({HealthRecord(type: .HospitalVisit($0))})
                    records.append(contentsOf: uwreapped)
                    dispatchGroup.leave()
                }
            case .ClinicalDocument:
                let clinicalDocumentsService = ClinicalDocumentService(network: network, authManager: authManager, configService: configService)
                clinicalDocumentsService.fetchAndStore(for: patient) { result in
                    guard let result = result else {
                        hadFailures = true
                        dispatchGroup.leave()
                        return
                    }
                    let uwreapped = result.map({HealthRecord(type: .ClinicalDocument($0))})
                    records.append(contentsOf: uwreapped)
                    dispatchGroup.leave()
                }
            case .DiagnosticImaging:
                // Note: Shouldn't get here, as diagnostic imaging comes from patient service
                dispatchGroup.leave()
            case .CancerScreening:
                // Note: Shouldn't get here, as cancer screening comes from patient service
                dispatchGroup.leave()
                
            case .Notes:
                let notesService = NotesService(network: network, authManager: authManager, configService: configService)
                notesService.fetchAndStore(for: patient) { result in
                    guard let result = result else {
                        hadFailures = true
                        
                        return
                    }
                    let unwrapped = result.map { HealthRecord(type: .Note($0)) }
                    records.append(contentsOf: unwrapped)
                    dispatchGroup.leave()
                }
            }
        }
        dispatchGroup.notify(queue: .main) {
            Logger.log(string: "Fetched patient records for \(patient.name)", type: .Network)
            network.removeLoader(caller: .HealthRecordsService_fetchAndStore)
            return completion(records, hadFailures)
        }
    }
    
    public func fetchAndStore(for dependent: Dependent, completion: @escaping ([HealthRecord], _ hadfailures: Bool)->Void) {
        guard let patient = dependent.info else {return completion([], false)}
        // TODO: Test this out
        MobileConfigService(network: network).fetchConfig(forceNetworkRefetch: true) { config in
            guard let config = config, config.online else {
                return completion([], true)
            }
            self.fetchAndStore(for: patient,
                          protectiveWord: nil,
                          completion: completion)
        }
        
    }
}

