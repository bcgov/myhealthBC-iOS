//
//  VaccinePassportModel.swift
//  ClientVaxPass-POC
//
//  Created by Connor Ogilvie on 2021-09-10.
//

import UIKit

struct VaccinePassportModel: Codable, Equatable {
    let imageName: String
    let phn: String
    let name: String
    let status: VaccineStatus
}
