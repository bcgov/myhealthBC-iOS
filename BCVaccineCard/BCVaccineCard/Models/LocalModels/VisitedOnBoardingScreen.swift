//
//  VisitedOnBoardingScreen.swift
//  BCVaccineCard
//
//  Created by Amir on 2021-11-23.
//

import Foundation

struct VisitedOnboardingScreen: Encodable, Decodable {
    let type: Int
    let version: Int
    
    func geTypeEnum() -> OnboardingScreenType? {
        return OnboardingScreenType.init(rawValue: type) ?? nil
    }
}

/**
        To add a new screen, add the new case here, build and follow the errors
        To update a screen version, go to Constants. -> onBoardingScreenLatestVersion()
 */
enum OnboardingScreenType: Int, CaseIterable {
    case healthPasses = 0
    case healthResources
    case newsFeed
}
