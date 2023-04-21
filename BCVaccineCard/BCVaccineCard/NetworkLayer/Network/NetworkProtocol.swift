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
    func addLoader(message: LoaderMessage, caller: LoaderCaller) {
        DispatchQueue.main.async {
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                appDelegate.incrementLoader(message: message, caller: caller)
            }
        }
    }
    
    func removeLoader(caller: LoaderCaller) {
        DispatchQueue.main.async {
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                appDelegate.decrementLoader(caller: caller)
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
    
    func showToast(error: NetworkErrorType) {
        switch error {
        case .FailedAfterRetry:
            showToast(message: .fetchRecordError, style: .Warn)
        case .code401:
            showToast(message: "401 - The client must authenticate itself to get the requested response.", style: .Warn)
        case .code403:
            showToast(message: "403 - The client does not have access rights to the content.", style: .Warn)
        case .code404:
            showToast(message: "404 - The patient could not be found.", style: .Warn)
        case .code503:
            showToast(message: "503 - Unable to get a response from the client registry.", style: .Warn)
        case .codeGeneric400:
            showToast(message: "ERROR 400", style: .Warn)
        case .codeGeneric500:
            showToast(message: "ERROR 500", style: .Warn)
        case .codeUnmapped:
            showToast(message: "Unknown network error", style: .Warn)
        }
    }
    
    
}
