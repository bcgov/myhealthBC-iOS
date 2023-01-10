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
}


// MARK: Retry Logic
extension AFNetwork {
    private func returnOrRetryIfneeded<Parameters: Encodable, T: Decodable>(with requestData: NetworkRequest<Parameters, T>, response: DataResponse<T, AFError>)  {
        guard let value = response.value else {
            // Didnt get a response.. return nil
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
            // is a BaseRetryableGatewayResponse but is not retry-able - return response
            return requestData.completion(value)
        }
        
        // Request is retry-able:
        
        let shouldRetry = shouldRetry(request: requestData, responsePayload: payLoadStruct)
        switch shouldRetry {
            
        case .NotNeeded:
            // retry not needed - return response
            requestAttempts[requestData.url] = 0
            return requestData.completion(value)
        case .ShouldRetry:
            // retry needed - increment attempt and request again
            if let attempts = requestAttempts[requestData.url] {
                requestAttempts[requestData.url] = attempts + 1
            } else {
                requestAttempts[requestData.url] = 1
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + (Double(payLoadStruct.retryin ?? requestData.retryIn))) {
                return self.request(with: requestData)
            }
        case .MaxRetryReached:
            // Max retry reached - return reponse and error
            if let error = requestData.onError {
                error(.FailedAfterRetry)
            }
            return requestData.completion(value)
        }
    }
    
    
    // Retry criteria Logic
    private func shouldRetry<Parameters: Encodable, T: Decodable>(request requestData: NetworkRequest<Parameters, T>,
                                                                  responsePayload: BaseRetryableGatewayResponse) -> RetryRestult {
        if responsePayload.loaded == false {
            if let attempts = requestAttempts[requestData.url] {
                if attempts < requestData.maxAttempts {
                    // havent reached max retry yet
                    return .ShouldRetry
                } else {
                    // reached max retry attempts
                    return .MaxRetryReached
                }
            } else {
                // Not retried yet
                return .ShouldRetry
            }
        } else {
            // loaded is true
            return .NotNeeded
        }
    }
    
    enum RetryRestult {
        case NotNeeded
        case ShouldRetry
        case MaxRetryReached
    }
}
