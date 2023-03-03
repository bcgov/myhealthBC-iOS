//
//  AuthenticationViewModel.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2023-03-03.
//

import Foundation


extension AuthenticationViewController {
    struct ViewModel {
        let initialView: InitialView
        let completion: ((AuthenticationStatus)->Void)?
    }
    
    enum InitialView {
        case Landing
        case AuthInfo
        case Auth
    }
    
    enum AuthenticationStatus {
        case Completed
        case Cancelled
        case Failed
    }
}

