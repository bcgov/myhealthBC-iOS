//
//  Patient+CoreDataProperties.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2023-05-23.
//
//

import Foundation
import CoreData


extension Patient {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Patient> {
        return NSFetchRequest<Patient>(entityName: "Patient")
    }

    @NSManaged public var authenticated: Bool
    @NSManaged public var authManagerDisplayName: String?
    @NSManaged public var birthday: Date?
    @NSManaged public var email: String?
    @NSManaged public var emailVerified: Bool
    @NSManaged public var firstName: String?
    @NSManaged public var gender: String?
    @NSManaged public var hdid: String?
    @NSManaged public var lastName: String?
    @NSManaged public var name: String?
    @NSManaged public var phn: String?
    @NSManaged public var phone: String?
    @NSManaged public var phoneVerified: Bool
    @NSManaged public var clinicalDocuments: NSSet?
    @NSManaged public var covidTestResults: NSSet?
    @NSManaged public var dependencyInfo: Dependent?
    @NSManaged public var dependents: NSSet?
    @NSManaged public var diagnosticImaging: NSSet?
    @NSManaged public var healthVisits: NSSet?
    @NSManaged public var hospitalVisits: NSSet?
    @NSManaged public var immunizations: NSSet?
    @NSManaged public var laboratoryOrders: NSSet?
    @NSManaged public var organDonorStatus: OrganDonorStatus?
    @NSManaged public var physicalAddress: Address?
    @NSManaged public var postalAddress: Address?
    @NSManaged public var prescriptions: NSSet?
    @NSManaged public var recommendations: NSSet?
    @NSManaged public var specialAuthorityDrugs: NSSet?
    @NSManaged public var vaccineCard: NSSet?

}

// MARK: Generated accessors for clinicalDocuments
extension Patient {

    @objc(addClinicalDocumentsObject:)
    @NSManaged public func addToClinicalDocuments(_ value: ClinicalDocument)

    @objc(removeClinicalDocumentsObject:)
    @NSManaged public func removeFromClinicalDocuments(_ value: ClinicalDocument)

    @objc(addClinicalDocuments:)
    @NSManaged public func addToClinicalDocuments(_ values: NSSet)

    @objc(removeClinicalDocuments:)
    @NSManaged public func removeFromClinicalDocuments(_ values: NSSet)

}

// MARK: Generated accessors for covidTestResults
extension Patient {

    @objc(addCovidTestResultsObject:)
    @NSManaged public func addToCovidTestResults(_ value: CovidLabTestResult)

    @objc(removeCovidTestResultsObject:)
    @NSManaged public func removeFromCovidTestResults(_ value: CovidLabTestResult)

    @objc(addCovidTestResults:)
    @NSManaged public func addToCovidTestResults(_ values: NSSet)

    @objc(removeCovidTestResults:)
    @NSManaged public func removeFromCovidTestResults(_ values: NSSet)

}

// MARK: Generated accessors for dependents
extension Patient {

    @objc(addDependentsObject:)
    @NSManaged public func addToDependents(_ value: Dependent)

    @objc(removeDependentsObject:)
    @NSManaged public func removeFromDependents(_ value: Dependent)

    @objc(addDependents:)
    @NSManaged public func addToDependents(_ values: NSSet)

    @objc(removeDependents:)
    @NSManaged public func removeFromDependents(_ values: NSSet)

}

// MARK: Generated accessors for diagnosticImaging
extension Patient {

    @objc(addDiagnosticImagingObject:)
    @NSManaged public func addToDiagnosticImaging(_ value: DiagnosticImaging)

    @objc(removeDiagnosticImagingObject:)
    @NSManaged public func removeFromDiagnosticImaging(_ value: DiagnosticImaging)

    @objc(addDiagnosticImaging:)
    @NSManaged public func addToDiagnosticImaging(_ values: NSSet)

    @objc(removeDiagnosticImaging:)
    @NSManaged public func removeFromDiagnosticImaging(_ values: NSSet)

}

// MARK: Generated accessors for healthVisits
extension Patient {

    @objc(addHealthVisitsObject:)
    @NSManaged public func addToHealthVisits(_ value: HealthVisit)

    @objc(removeHealthVisitsObject:)
    @NSManaged public func removeFromHealthVisits(_ value: HealthVisit)

    @objc(addHealthVisits:)
    @NSManaged public func addToHealthVisits(_ values: NSSet)

    @objc(removeHealthVisits:)
    @NSManaged public func removeFromHealthVisits(_ values: NSSet)

}

// MARK: Generated accessors for hospitalVisits
extension Patient {

    @objc(addHospitalVisitsObject:)
    @NSManaged public func addToHospitalVisits(_ value: HospitalVisit)

    @objc(removeHospitalVisitsObject:)
    @NSManaged public func removeFromHospitalVisits(_ value: HospitalVisit)

    @objc(addHospitalVisits:)
    @NSManaged public func addToHospitalVisits(_ values: NSSet)

    @objc(removeHospitalVisits:)
    @NSManaged public func removeFromHospitalVisits(_ values: NSSet)

}

// MARK: Generated accessors for immunizations
extension Patient {

    @objc(addImmunizationsObject:)
    @NSManaged public func addToImmunizations(_ value: Immunization)

    @objc(removeImmunizationsObject:)
    @NSManaged public func removeFromImmunizations(_ value: Immunization)

    @objc(addImmunizations:)
    @NSManaged public func addToImmunizations(_ values: NSSet)

    @objc(removeImmunizations:)
    @NSManaged public func removeFromImmunizations(_ values: NSSet)

}

// MARK: Generated accessors for laboratoryOrders
extension Patient {

    @objc(addLaboratoryOrdersObject:)
    @NSManaged public func addToLaboratoryOrders(_ value: LaboratoryOrder)

    @objc(removeLaboratoryOrdersObject:)
    @NSManaged public func removeFromLaboratoryOrders(_ value: LaboratoryOrder)

    @objc(addLaboratoryOrders:)
    @NSManaged public func addToLaboratoryOrders(_ values: NSSet)

    @objc(removeLaboratoryOrders:)
    @NSManaged public func removeFromLaboratoryOrders(_ values: NSSet)

}

// MARK: Generated accessors for prescriptions
extension Patient {

    @objc(addPrescriptionsObject:)
    @NSManaged public func addToPrescriptions(_ value: Perscription)

    @objc(removePrescriptionsObject:)
    @NSManaged public func removeFromPrescriptions(_ value: Perscription)

    @objc(addPrescriptions:)
    @NSManaged public func addToPrescriptions(_ values: NSSet)

    @objc(removePrescriptions:)
    @NSManaged public func removeFromPrescriptions(_ values: NSSet)

}

// MARK: Generated accessors for recommendations
extension Patient {

    @objc(addRecommendationsObject:)
    @NSManaged public func addToRecommendations(_ value: ImmunizationRecommendation)

    @objc(removeRecommendationsObject:)
    @NSManaged public func removeFromRecommendations(_ value: ImmunizationRecommendation)

    @objc(addRecommendations:)
    @NSManaged public func addToRecommendations(_ values: NSSet)

    @objc(removeRecommendations:)
    @NSManaged public func removeFromRecommendations(_ values: NSSet)

}

// MARK: Generated accessors for specialAuthorityDrugs
extension Patient {

    @objc(addSpecialAuthorityDrugsObject:)
    @NSManaged public func addToSpecialAuthorityDrugs(_ value: SpecialAuthorityDrug)

    @objc(removeSpecialAuthorityDrugsObject:)
    @NSManaged public func removeFromSpecialAuthorityDrugs(_ value: SpecialAuthorityDrug)

    @objc(addSpecialAuthorityDrugs:)
    @NSManaged public func addToSpecialAuthorityDrugs(_ values: NSSet)

    @objc(removeSpecialAuthorityDrugs:)
    @NSManaged public func removeFromSpecialAuthorityDrugs(_ values: NSSet)

}

// MARK: Generated accessors for vaccineCard
extension Patient {

    @objc(addVaccineCardObject:)
    @NSManaged public func addToVaccineCard(_ value: VaccineCard)

    @objc(removeVaccineCardObject:)
    @NSManaged public func removeFromVaccineCard(_ value: VaccineCard)

    @objc(addVaccineCard:)
    @NSManaged public func addToVaccineCard(_ values: NSSet)

    @objc(removeVaccineCard:)
    @NSManaged public func removeFromVaccineCard(_ values: NSSet)

}
