//
//  ProfileDetailViewModel.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2023-03-03.
//

import Foundation


extension ProfileDetailsViewController {
    struct ViewModel {
        let patient: Patient?
        let firstName: String?
        let lastName: String?
        let phn: String?
        let physicalAddress: String?
        let mailingAddress: String?
        
        init(patient: Patient) {
            self.patient = patient
            firstName = patient.firstName
            lastName = patient.lastName
            phn = patient.phn
            physicalAddress = AuthenticatedPatientDetailsResponseObject.Address(streetLines: patient.physicalAddress?.streetLines, city: patient.physicalAddress?.city, state: patient.physicalAddress?.state, postalCode: patient.physicalAddress?.postalCode, country: patient.physicalAddress?.country).getAddressString
            mailingAddress = AuthenticatedPatientDetailsResponseObject.Address(streetLines: patient.postalAddress?.streetLines, city: patient.postalAddress?.city, state: patient.postalAddress?.state, postalCode: patient.postalAddress?.postalCode, country: patient.postalAddress?.country).getAddressString
        }
    }
}
