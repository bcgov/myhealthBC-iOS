//
//  ProfileDetailViewModel.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2023-03-03.
//

import Foundation


extension ProfileDetailsViewController {
    struct ViewModel {
        enum ScreenType {
            case PatientProfile(patient: Patient)
            case DependentProfile(dependent: Dependent)
        }
        
        let patient: Patient?
        let dependent: Dependent?
        let firstName: String?
        let lastName: String?
        let phn: String?
        let physicalAddress: String?
        let mailingAddress: String?
        let dob: String?
        let delegateCount: Int?
        let type: ScreenType!
        
        init(type: ScreenType) {
            self.type = type
            switch type {
            case .PatientProfile(patient: let patient):
                self.patient = patient
                firstName = patient.firstName
                lastName = patient.lastName
                phn = patient.phn
                physicalAddress = AuthenticatedPatientDetailsResponseObject.Address(streetLines: patient.physicalAddress?.streetLines, city: patient.physicalAddress?.city, state: patient.physicalAddress?.state, postalCode: patient.physicalAddress?.postalCode, country: patient.physicalAddress?.country).getAddressString
                mailingAddress = AuthenticatedPatientDetailsResponseObject.Address(streetLines: patient.postalAddress?.streetLines, city: patient.postalAddress?.city, state: patient.postalAddress?.state, postalCode: patient.postalAddress?.postalCode, country: patient.postalAddress?.country).getAddressString
            case .DependentProfile(dependent: let dependent):
                self.dependent = dependent
                firstName = dependent.info?.firstName
                lastName = dependent.info?.lastName
                phn = dependent.info?.phn
                dob = dependent.info?.birthday?.yearMonthStringDayString
                delegateCount = Int(dependent.totalDelegateCount)
            }
        }
    }
}
