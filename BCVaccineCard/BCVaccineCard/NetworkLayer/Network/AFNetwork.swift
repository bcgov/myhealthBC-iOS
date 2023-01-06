//
//  Network.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2022-09-14.
//

import Foundation
import Alamofire

extension NetworkRequest.RequestType {
    var AFMethod: HTTPMethod {
        switch self {
        case .Get:
            return .get
        case .Post:
            return .post
        case .Put:
            return .put
        case .Delete:
            return .delete
        }
    }
}

extension NetworkRequest {
    var AFRequest:  DataRequest {
        let afHeaders: HTTPHeaders?
        if let requestHeaders = headers {
            afHeaders = HTTPHeaders(requestHeaders)
        } else {
            afHeaders = nil
        }
        let alamoEncoder: ParameterEncoder = encoder == .json ? .json : .urlEncodedForm
        return AF.request(url, method: type.AFMethod, parameters: parameters, encoder: alamoEncoder, headers: afHeaders)
    }
}


class AFNetwork: Network {
    
    private var requestAttempts: [URL: Int] = [URL: Int]()
    
    func request<Parameters: Encodable, T: Decodable>(with requestData: NetworkRequest<Parameters, T>) {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970 // Decode UNIX timestamps
        let AFRequest = requestData.AFRequest
        AFRequest.responseDecodable(of: T.self, decoder: decoder, completionHandler: {response in
            return self.returnOrRetryIfneeded(with: requestData, response: response)
        })
    }
    
    private func returnOrRetryIfneeded<Parameters: Encodable, T: Decodable>(with requestData: NetworkRequest<Parameters, T>, response: DataResponse<T, AFError>)  {
        guard let value = response.value else {
            return requestData.completion(nil)
        }
        
        guard value is BaseGatewayResponse, var gateWayResponse = value as? BaseGatewayResponse else {
            // Not a BaseGatewayResponse - return response
            return requestData.completion(value)
        }
        
        guard let payload = swift_value(of: &gateWayResponse, key: "resourcePayload"),
           payload is BaseRetryableGatewayResponse,
           let payLoadStruct = payload as? BaseRetryableGatewayResponse else
        {
            // Retry not needed - return
            return requestData.completion(value)
        }
        
        // Request is retry-able
        
        if shouldRetry(request: requestData, responsePayload: payLoadStruct) {
            // retry needed
            if let attempts = requestAttempts[requestData.url] {
                requestAttempts[requestData.url] = attempts + 1
            } else {
                requestAttempts[requestData.url] = 1
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + (Double(payLoadStruct.retryin ?? requestData.retryIn))) {
                return self.request(with: requestData)
            }
        } else {
            // retry not needed
            return requestData.completion(value)
        }
    }
    
    
    // Retry criteria Logic
    private func shouldRetry<Parameters: Encodable, T: Decodable>(request requestData: NetworkRequest<Parameters, T>,
                                                                  responsePayload: BaseRetryableGatewayResponse) -> Bool {
        if responsePayload.loaded == false {
            if let attempts = requestAttempts[requestData.url] {
                if attempts < requestData.maxAttempts {
                    // havent reached max retry yet
                    return true
                } else {
                    // reached max retry attempts
                    return false
                }
            } else {
                // Not retried yet
                return true
            }
        } else {
            // loaded is true
            return false
        }
    }
}
