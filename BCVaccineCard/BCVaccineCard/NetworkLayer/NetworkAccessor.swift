//
//  NetworkApiClient.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-10-08.
//

import UIKit
import Alamofire
import SwiftyJSON
import QueueITLibrary

typealias MethodType = HTTPMethod
typealias Encoding = ParameterEncoding
typealias Headers = HTTPHeaders
typealias RequestParameters = Parameters
typealias JsonEncoding = JSONEncoding
typealias UrlEncoding = URLEncoding
typealias Interceptor = RequestInterceptor
typealias NetworkRequestCompletion<T: Decodable> = ((Result<T, ResultError>) -> Void)

protocol RemoteAccessor {
    func authorizationHeader(fromToken token: String) -> Headers
    func request<T: Decodable>(withURL url: URL, method: MethodType, encoding: Encoding,
                               headers: Headers?, parameters: RequestParameters?, interceptor: Interceptor?, checkQueueIt: Bool,
                               andCompletion completion: @escaping NetworkRequestCompletion<T>)
    func request<Parameters: Encodable, T: Decodable>(withURL url: URL, method: MethodType,
                                                      headers: Headers?, encoder: ParameterEncoder, parameters: Parameters?,
                                                      interceptor: Interceptor?, checkQueueIt: Bool,
                                                      andCompletionHandler completion: @escaping NetworkRequestCompletion<T>)
    func uploadRequest<T: Decodable>(withURL url: URL, method: MethodType, mediaType: MIMEType?,
                                     headers: Headers, parameters: RequestParameters, interceptor: Interceptor?, checkQueueIt: Bool,
                                     andCompletion completion: @escaping NetworkRequestCompletion<T>)
}

extension RemoteAccessor {
    
    func request<T: Decodable>(withURL url: URL, method: MethodType,
                               encoding: Encoding = JsonEncoding.default,
                               headers: Headers? = nil,
                               parameters: RequestParameters? = nil,
                               interceptor: Interceptor? = nil,
                               checkQueueIt: Bool,
                               andCompletion completion: @escaping NetworkRequestCompletion<T>) {
        return request(withURL: url, method: method, encoding: encoding, headers: headers,
                       parameters: parameters, interceptor: interceptor, checkQueueIt: checkQueueIt, andCompletion: completion)
    }
    
    func request<Parameters: Encodable, T: Decodable>(
        withURL url: URL,
        method: MethodType,
        headers: Headers? = nil,
        encoder: ParameterEncoder? = nil,
        parameters: Parameters,
        interceptor: Interceptor? = nil,
        checkQueueIt: Bool,
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
                       checkQueueIt: checkQueueIt,
                       andCompletionHandler: completion)
    }
    
}

protocol QueueItWorkerDelegate: AnyObject {
    
}

final class NetworkAccessor {
    
    weak var delegate: QueueItWorkerDelegate?
    
    init(delegateOwner: QueueItWorkerDelegate) {
        self.delegate = delegateOwner
    }
    
    private func execute<T: Decodable>(request: DataRequest, checkQueueIt: Bool, withCompletion completion: @escaping NetworkRequestCompletion<T>) {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970 // Decode UNIX timestamps
        request.responseDecodable(of: T.self, decoder: decoder) { response in
            if self.checkIfCookieIsSet() {
                self.decodeResponse(response: response, withCompletion: completion)
            } else if self.checkForQueueItRedirect() {
                //TODO: call delegate here
            } else {
                self.decodeResponse(response: response, withCompletion: completion)
            }
            
        }
    }
    
    private func decodeResponse<T: Decodable>(response: DataResponse<T, AFError>, withCompletion completion: @escaping NetworkRequestCompletion<T>) {
        switch response.result {
        case .success(let successResponse):
            completion(.success(successResponse))
        case .failure(let error):
            guard let responseData = response.data, let errorResponse = try? JSONDecoder().decode(ResultError.self, from: responseData) else {
                print(error.errorDescription.unwrapped)
                let unexpectedErrorResponse = ResultError(resultMessage: .genericErrorMessage)
                return completion(.failure(unexpectedErrorResponse))
            }
            completion(.failure(errorResponse))
        }
    }
    
}

// MARK: QueueIt functions
// TODO: Add in logic here
extension NetworkAccessor {
    private func checkIfCookieIsSet() -> Bool {
        // if cookie is set, then we can likely extract the response already
        return true
    }
    
    private func checkForQueueItRedirect() -> Bool {
        // if redirect is in the url, then we need to run queue it by calling the delegate, then API client will run QUEUE IT, will get the token, then we will retry the request
        return true
    }
}

extension NetworkAccessor: RemoteAccessor {
    
    func authorizationHeader(fromToken token: String) -> Headers {
        return [Constants.authorizationHeaderKey: token]
    }
    
    func request<T: Decodable>(withURL url: URL, method: MethodType, encoding: Encoding,
                               headers: Headers?, parameters: RequestParameters?, interceptor: Interceptor?, checkQueueIt: Bool,
                               andCompletion completion: @escaping NetworkRequestCompletion<T>) {
        let request = AF.request(url, method: method, parameters: parameters, encoding: encoding, headers: headers, interceptor: interceptor)
        self.execute(request: request, checkQueueIt: checkQueueIt, withCompletion: completion)
    }
    
    func request<Parameters: Encodable, T: Decodable> (
        withURL url: URL,
        method: MethodType,
        headers: Headers?,
        encoder: ParameterEncoder,
        parameters: Parameters?,
        interceptor: Interceptor?,
        checkQueueIt: Bool,
        andCompletionHandler completion: @escaping NetworkRequestCompletion<T>) {
        
        let request = AF.request(url, method: method, parameters: parameters, encoder: encoder, headers: headers)
            self.execute(request: request, checkQueueIt: checkQueueIt, withCompletion: completion)
    }
    
    func uploadRequest<T: Decodable>(withURL url: URL, method: MethodType, mediaType: MIMEType?,
                                     headers: Headers, parameters: RequestParameters, interceptor: Interceptor?, checkQueueIt: Bool,
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
        self.execute(request: request, checkQueueIt: checkQueueIt, withCompletion: completion)
    }
}


