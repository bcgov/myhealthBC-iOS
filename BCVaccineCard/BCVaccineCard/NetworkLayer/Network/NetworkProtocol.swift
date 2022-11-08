//
//  NetworkProtocol.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2022-09-14.
//

import Foundation
import UIKit

protocol Network {
    func request<Parameters: Encodable, T: Decodable>(with requestData: NetworkRequest<Parameters, T>)
}
