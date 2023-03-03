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
    }
}
