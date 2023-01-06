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


struct AFNetwork: Network {
    
    func request<Parameters: Encodable, T: Decodable>(with requestData: NetworkRequest<Parameters, T>) {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970 // Decode UNIX timestamps
        let AFRequest = requestData.AFRequest
        AFRequest.responseDecodable(of: T.self, decoder: decoder, completionHandler: {response in
            return returnOrRetryIfneeded(with: requestData, response: response)
        })
    }
    
    func returnOrRetryIfneeded<Parameters: Encodable, T: Decodable>(with requestData: NetworkRequest<Parameters, T>, response: DataResponse<T, AFError>)  {
        guard let value = response.value else {
            return requestData.completion(nil)
        }
        
        guard value is BaseGatewayResponse, var gateWayResponse = value as? BaseGatewayResponse else {
            // Not a BaseGatewayResponse - return response
            return requestData.completion(value)
        }
        
        // BaseGatewayResponse - check if retry is needed
        if let payload = swift_value(of: &gateWayResponse, key: "resourcePayload"),
           payload is BaseRetryableGatewayResponse,
           let payLoadStruct = payload as? BaseRetryableGatewayResponse,
           payLoadStruct.loaded == false // if not loaded
        {
            // Retry needed - retry
            print("RETRYABLE!!!")
            /*
             TODO: Connor please check this retry criteria.
             Do we need if payLoadStruct.queued ??
             Whats the default retry time?
             */
            DispatchQueue.main.asyncAfter(deadline: .now() + (Double(payLoadStruct.retryin ?? 3000))) {
                return request(with: requestData)
            }
        } else {
            // Retry not needed - return (if no network error)
            return requestData.completion(value)
        }
    }
}
