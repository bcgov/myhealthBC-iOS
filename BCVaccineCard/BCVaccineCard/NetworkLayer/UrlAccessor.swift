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
}

struct UrlAccessor {
//    https://dev.api.saas.th.freshworks.club
    #if DEBUG
    let baseUrl = URL(string: "https://test.healthgateway.gov.bc.ca/api/")!
    #else
    let baseUrl = URL(string: "https://healthgateway.gov.bc.ca/api/")!
    #endif
            
    private var immunizationBaseUrl: URL {
        return self.baseUrl.appendingPathComponent("immunizationservice")
    }
    
}

extension UrlAccessor: EndpointsAccessor {
    
    var getVaccineCard: URL {
        return self.immunizationBaseUrl.appendingPathComponent("v1/api/VaccineStatus")
    }
}

