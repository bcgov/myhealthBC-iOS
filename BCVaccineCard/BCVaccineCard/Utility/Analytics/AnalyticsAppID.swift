//
//  AnalyticsAppID.swift
//  BCVaccineCard
//
//  Created by Amir on 2021-12-06.
//

import Foundation

extension AnalyticsService {
    var appID: String {
#if PROD
        return "Snowplow_standalone_HApp_prod"
#elseif TEST
        return "Snowplow_standalone_HApp_dev"
#elseif DEV
        return "Snowplow_standalone_HApp_dev"
#endif
    }

}


