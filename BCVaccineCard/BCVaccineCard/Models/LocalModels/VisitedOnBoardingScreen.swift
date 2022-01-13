//
//  VisitedOnBoardingScreen.swift
//  BCVaccineCard
//
//  Created by Amir on 2021-11-23.
//

import Foundation

struct VisitedOnboardingScreen: Encodable, Decodable {
    let type: String
    let version: Int
    
    func geTypeEnum() -> OnboardingScreenType? {
        guard let typeID = OnboardingScreenTypeID.init(rawValue: type) else {
            return nil
        }
        return typeID.toScreenType()
    }
}

/**
 To add a new screen, add the new case here, build and follow the errors
 To update a screen version, go to Constants. -> onBoardingScreenLatestVersion()
 Check UI constraint logic in the adjustRotatingImageViewConstraints function, as constraints/assets may need to be updated
 */
enum OnboardingScreenType: Int, CaseIterable {
    case healthPasses = 0
    case healthRecords
    case healthResources
    case newsFeed
}

enum OnboardingScreenTypeID: String {
    case healthPasses = "healthPasses"
    case healthRecords = "healthRecords"
    case healthResources = "healthResources"
    case newsFeed = "newsFeed"
}

extension OnboardingScreenType {
     func toScreenTypeID() -> OnboardingScreenTypeID {
        switch self {
        case .healthPasses:
            return .healthPasses
        case .healthRecords:
            return .healthRecords
        case .healthResources:
            return .healthResources
        case .newsFeed:
            return .newsFeed
        }
    }
}

extension OnboardingScreenTypeID {
     func toScreenType() -> OnboardingScreenType {
        switch self {
        case .healthPasses:
            return .healthPasses
        case .healthRecords:
            return .healthRecords
        case .healthResources:
            return .healthResources
        case .newsFeed:
            return .newsFeed
        }
    }
}
