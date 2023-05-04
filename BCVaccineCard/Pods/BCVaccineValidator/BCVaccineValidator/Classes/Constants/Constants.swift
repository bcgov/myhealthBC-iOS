//
//  File.swift
//  
//
//  Created by Amir Shayegh on 2021-09-20.
//

import Foundation

struct Constants {
    static let networkTimeout: Double = 5
        
    struct JWKSPublic {
        static let wellKnownJWKS_URLExtension = ".well-known/jwks.json"
    }
    
    struct CVX {
        static let janssen = "212"
    }
    
    struct Directories {
        static let caceDirectoryName: String = "VaccineValidatorCache"
        
        struct issuers {
            static let directoryName = "issuers"
        }
        
        struct rules {
            static let directoryName = "rules"
        }
    }
    
    struct UserDefaultKeys {
        static let issuersTimeOutKey = "issuersTimeout"
        static let vaccinationRulesTimeOutKey = "vaccinationRulesTimeout"
    }
}
