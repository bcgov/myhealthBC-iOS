//
//  AppStoreDataModel.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2022-11-02.
//

import Foundation
// MARK: - AppStoreData
struct AppStoreVersionData: Codable {
    let resultCount: Int?
    let results: [AppStoreVersionDataResult]?
}

// MARK: - Result
struct AppStoreVersionDataResult: Codable {
    let version: String?
    
    enum CodingKeys: String, CodingKey {
        case version
    }
}
