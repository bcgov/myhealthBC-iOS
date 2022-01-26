//
//  UrlAccessor.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-10-08.
//

import Foundation

/// This accessor helps accessing all the endpoints being used in the app.
protocol EndpointsAccessor {
    var getVaccineCard: URL { get }
    var getTestResults: URL { get }
    var getAuthenticatedVaccineCard: URL { get }
    var getAuthenticatedTestResults: URL { get }
}

struct UrlAccessor {
    #if PROD
    let baseUrl = URL(string: "https://healthgateway.gov.bc.ca/api/")!
    #elseif DEV
    let baseUrl = URL(string: "https://dev.healthgateway.gov.bc.ca/api/")!
//    let baseUrl = URL(string: "https://healthgateway.gov.bc.ca/api/")!
    #endif
    
    private var immunizationBaseUrl: URL {
        return self.baseUrl.appendingPathComponent("immunizationservice")
    }
    
    private var laboratoryServiceBaseURL: URL {
        return self.baseUrl.appendingPathComponent("laboratoryservice")
    }
    
    // TODO: Add patient details endpoint here
    
}

extension UrlAccessor: EndpointsAccessor {
    
    var getVaccineCard: URL {
        return self.immunizationBaseUrl.appendingPathComponent("v1/api/PublicVaccineStatus")
    }
    
    var getTestResults: URL {
        return self.laboratoryServiceBaseURL.appendingPathComponent("v1/api/PublicLaboratory/CovidTests")
    }
    
    var getAuthenticatedVaccineCard: URL {
        return self.immunizationBaseUrl.appendingPathComponent("v1/api/AuthenticatedVaccineStatus")
    }
    
    var getAuthenticatedTestResults: URL {
        return self.laboratoryServiceBaseURL.appendingPathComponent("v1/api/Laboratory")
    }
}

