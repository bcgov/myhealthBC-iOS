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


extension Network {
    func addLoader(message: LoaderMessage) {
        DispatchQueue.main.async {
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                appDelegate.incrementLoader(message: message)
            }
        }
    }
    
    func removeLoader() {
        DispatchQueue.main.async {
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                appDelegate.decrementLoader()
            }
        }
    }
}

extension Network {
    func showToast(message: String, style: AppDelegate.ToastStyle? = .Default) {
        DispatchQueue.main.async {
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                appDelegate.showToast(message: message, style: style)
            }
        }
    }
}
