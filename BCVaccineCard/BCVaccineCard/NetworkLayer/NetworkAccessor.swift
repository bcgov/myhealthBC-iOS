//
//  NetworkApiClient.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-10-08.
//

import UIKit
import Alamofire
import SwiftyJSON

typealias MethodType = HTTPMethod
typealias Encoding = ParameterEncoding
typealias Headers = HTTPHeaders
typealias RequestParameters = Parameters
typealias JsonEncoding = JSONEncoding
typealias UrlEncoding = URLEncoding
typealias Interceptor = RequestInterceptor
// FIXME: Will need to edit error response and use that as the response object instead, using ResultError for now as it is the only request
typealias NetworkRequestCompletion<T: Decodable> = ((Result<T, ResultError>) -> Void)

protocol RemoteAccessor {
    func authorizationHeader(fromToken token: String) -> Headers
    func request<T: Decodable>(withURL url: URL, method: MethodType, encoding: Encoding,
                               headers: Headers?, parameters: RequestParameters?, interceptor: Interceptor?,
                               andCompletion completion: @escaping NetworkRequestCompletion<T>)
    func request<Parameters: Encodable, T: Decodable>(withURL url: URL, method: MethodType,
                                                      headers: Headers?, encoder: ParameterEncoder, parameters: Parameters?,
                                                      interceptor: Interceptor?,
                                                      andCompletionHandler completion: @escaping NetworkRequestCompletion<T>)
    func uploadRequest<T: Decodable>(withURL url: URL, method: MethodType, mediaType: MIMEType?,
                                     headers: Headers, parameters: RequestParameters, interceptor: Interceptor?,
                                     andCompletion completion: @escaping NetworkRequestCompletion<T>)
}

extension RemoteAccessor {
    
    func request<T: Decodable>(withURL url: URL, method: MethodType,
                               encoding: Encoding = JsonEncoding.default,
                               headers: Headers? = nil,
                               parameters: RequestParameters? = nil,
                               interceptor: Interceptor? = nil,
                               andCompletion completion: @escaping NetworkRequestCompletion<T>) {
        return request(withURL: url, method: method, encoding: encoding, headers: headers,
                       parameters: parameters, interceptor: interceptor, andCompletion: completion)
    }
    
    func request<Parameters: Encodable, T: Decodable>(
        withURL url: URL,
        method: MethodType,
        headers: Headers? = nil,
        encoder: ParameterEncoder? = nil,
        parameters: Parameters,
        interceptor: Interceptor? = nil,
        andCompletionHandler completion: @escaping NetworkRequestCompletion<T>) {
        
        let defaultEncoder: ParameterEncoder
        if let encoder = encoder {
            defaultEncoder = encoder
        } else if [.get, .head, .delete].contains(method) {
            defaultEncoder = URLEncodedFormParameterEncoder.default
        } else {
            let jsonEncoder = JSONEncoder()
            jsonEncoder.dateEncodingStrategy = .secondsSince1970 // Encode UNIX timestamps
            defaultEncoder = JSONParameterEncoder(encoder: jsonEncoder)
        }
        
        return request(withURL: url,
                       method: method,
                       headers: headers,
                       encoder: defaultEncoder,
                       parameters: parameters,
                       interceptor: interceptor,
                       andCompletionHandler: completion)
    }
    
}

final class NetworkAccessor {
    
    private var sessionExpiredObserver: (() -> Void)?
    
    private func execute<T: Decodable>(request: DataRequest,
                                       withCompletion completion: @escaping NetworkRequestCompletion<T>) {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970 // Decode UNIX timestamps
        request.responseDecodable(of: T.self, decoder: decoder) { response in
            switch response.result {
            case .success(let successResponse):
                completion(.success(successResponse))
            case .failure(let error):
                guard
                    let responseData = response.data,
                    let errorResponse = try? JSONDecoder().decode(GatewayVaccineCardResponse.self, from: responseData) else {
//                        let errorMessage = error.errorDescription.unwrapped
                        let unexpectedErrorResponse = ResultError(resultMessage: "Unknown", errorCode: "Unknown Code", traceID: "Unknown Trace", actionCode: "Unknown action code")
                        return completion(.failure(unexpectedErrorResponse))
                }
                completion(.failure(errorResponse.resultError ?? ResultError(resultMessage: "No value", errorCode: "No value", traceID: "No value", actionCode: "No value")))
            }
        }
    }
    
}

extension NetworkAccessor: RemoteAccessor {
    
    func authorizationHeader(fromToken token: String) -> Headers {
        return [Constants.authorizationHeaderKey: token]
    }
    
    func request<T: Decodable>(withURL url: URL, method: MethodType, encoding: Encoding,
                               headers: Headers?, parameters: RequestParameters?, interceptor: Interceptor?,
                               andCompletion completion: @escaping NetworkRequestCompletion<T>) {
        let request = AF.request(url, method: method, parameters: parameters, encoding: encoding, headers: headers, interceptor: interceptor)
        self.execute(request: request, withCompletion: completion)
    }
    
    func request<Parameters: Encodable, T: Decodable> (
        withURL url: URL,
        method: MethodType,
        headers: Headers?,
        encoder: ParameterEncoder,
        parameters: Parameters?,
        interceptor: Interceptor?,
        andCompletionHandler completion: @escaping NetworkRequestCompletion<T>) {
        
        let request = AF.request(url, method: method, parameters: parameters, encoder: encoder, headers: headers)
        self.execute(request: request, withCompletion: completion)
    }
    
    func uploadRequest<T: Decodable>(withURL url: URL, method: MethodType, mediaType: MIMEType?,
                                     headers: Headers, parameters: RequestParameters, interceptor: Interceptor?,
                                     andCompletion completion: @escaping NetworkRequestCompletion<T>) {
        let request = AF.upload(multipartFormData: { multipartFormData in
            parameters.forEach({ (key, value) in
                if let castedData = value as? Data {
                    multipartFormData.append(castedData, withName: key, fileName: key, mimeType: mediaType?.mimeType)
                } else if let castedStringData = (value as? String)?.data(using: .utf8) {
                    multipartFormData.append(castedStringData, withName: key)
                }
            })
        }, to: url, method: method, headers: headers)
        self.execute(request: request, withCompletion: completion)
    }
    
//    func setSessionExpiredObserver(_ observer: @escaping (() -> Void)) {
//        self.sessionExpiredObserver = observer
//    }
    
}
