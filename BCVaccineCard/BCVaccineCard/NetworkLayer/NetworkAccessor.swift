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
typealias NetworkRequestCompletion<T: Decodable> = (((Result<T, ResultError>), NetworkRetryStatus?) -> Void)

protocol RemoteAccessor {
    func authorizationHeader(fromToken token: String) -> Headers
    func request<T: Decodable>(withURL url: URL, method: MethodType, encoding: Encoding,
                               headers: Headers?, parameters: RequestParameters?, interceptor: Interceptor?,
                               checkQueueIt: Bool,  executingVC: UIViewController, includeQueueItUI: Bool,
                               andCompletion completion: @escaping NetworkRequestCompletion<T>)
    func request<Parameters: Encodable, T: Decodable>(withURL url: URL, method: MethodType,
                                                      headers: Headers?, encoder: ParameterEncoder, parameters: Parameters?,
                                                      interceptor: Interceptor?, checkQueueIt: Bool,
                                                      executingVC: UIViewController, includeQueueItUI: Bool,
                                                      andCompletionHandler completion: @escaping NetworkRequestCompletion<T>)
    func uploadRequest<T: Decodable>(withURL url: URL, method: MethodType, mediaType: MIMEType?,
                                     headers: Headers, parameters: RequestParameters, interceptor: Interceptor?,
                                     checkQueueIt: Bool, executingVC: UIViewController, includeQueueItUI: Bool,
                                     andCompletion completion: @escaping NetworkRequestCompletion<T>)
}

extension RemoteAccessor {
    
    func request<T: Decodable>(withURL url: URL, method: MethodType,
                               encoding: Encoding = JsonEncoding.default,
                               headers: Headers? = nil,
                               parameters: RequestParameters? = nil,
                               interceptor: Interceptor? = nil,
                               checkQueueIt: Bool,
                               executingVC: UIViewController,
                               includeQueueItUI: Bool,
                               andCompletion completion: @escaping NetworkRequestCompletion<T>) {
        return request(withURL: url, method: method, encoding: encoding, headers: headers,
                       parameters: parameters, interceptor: interceptor, checkQueueIt: checkQueueIt, executingVC: executingVC, includeQueueItUI: includeQueueItUI, andCompletion: completion)
    }
    
    func request<Parameters: Encodable, T: Decodable>(
        withURL url: URL,
        method: MethodType,
        headers: Headers? = nil,
        encoder: ParameterEncoder? = nil,
        parameters: Parameters,
        interceptor: Interceptor? = nil,
        checkQueueIt: Bool,
        executingVC: UIViewController,
        includeQueueItUI: Bool,
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
                       executingVC: executingVC,
                       includeQueueItUI: includeQueueItUI,
                       andCompletionHandler: completion)
    }
    
}

final class NetworkAccessor {
    
    private func execute<T: Decodable>(request: DataRequest, checkQueueIt: Bool, executingVC: UIViewController, includeQueueItUI: Bool, withCompletion completion: @escaping NetworkRequestCompletion<T>) {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970 // Decode UNIX timestamps
        request.responseDecodable(of: T.self, decoder: decoder) { response in
            guard checkQueueIt else {
                return self.decodeResponse(response: response, retryStatus: nil, withCompletion: completion)
            }
            if self.checkIfCookieIsSet(response: response) {
                self.decodeResponse(response: response, retryStatus: nil, withCompletion: completion)
            } else if let cAndE = self.checkForQueueItRedirect(response: response) {
                let url = response.request?.url
                self.setupQueueIt(onViewController: executingVC, customerID: cAndE.c, eventAlias: cAndE.e, url: url, includeQueueItUI: includeQueueItUI) { status, error in
                    if status.succeeded {
                        let token = status.token
                        QueueItLocal.saveValueToDefaults(queueitToken: token)
                        self.decodeResponse(response: response, retryStatus: NetworkRetryStatus(token: token, retry: true), withCompletion: completion)
                    
                    } else {
                        self.failedQueueItRunAttemptResponse(error: error, retryStatus: nil, withCompletion: completion)
                    }
                }
            } else {
                self.decodeResponse(response: response, retryStatus: nil, withCompletion: completion)
            }
            
        }
    }
    
    private func decodeResponse<T: Decodable>(response: DataResponse<T, AFError>, retryStatus: NetworkRetryStatus?, withCompletion completion: @escaping NetworkRequestCompletion<T>) {
        
        // TODO: Find better place for this:
        if response.request?.url?.hasQueueItToken() ?? false && !APIClientCache.isCookieSet {
            APIClientCache.isCookieSet = true
        }
        
        switch response.result {
        case .success(let successResponse):
            completion(.success(successResponse), retryStatus)
        case .failure(let error):
            guard let responseData = response.data, let errorResponse = try? JSONDecoder().decode(ResultError.self, from: responseData) else {
                Logger.log(string: error.errorDescription.unwrapped, type: .Network)
                let unexpectedErrorResponse = ResultError(resultMessage: .genericErrorMessage)
                return completion(.failure(unexpectedErrorResponse), retryStatus)
            }
            completion(.failure(errorResponse), retryStatus)
        }
    }
    
    private func failedQueueItRunAttemptResponse<T: Decodable>(error: DisplayableResultError?, retryStatus: NetworkRetryStatus?, withCompletion completion: @escaping NetworkRequestCompletion<T>) {
        if let error = error {
            completion(.failure(error.resultError), retryStatus)
        } else {
            completion(.failure(ResultError(resultMessage: .genericErrorMessage)), retryStatus)
        }
    }
    
    private func setupQueueIt(onViewController vc: UIViewController, customerID: String, eventAlias: String, url: URL?, includeQueueItUI: Bool, completion: ((QueueItRunStatus, DisplayableResultError?) -> Void)?) {
        let queueIt = QueueItEngine(delegateOwner: vc, customDelegateOwner: vc)
        queueIt.setupQueueIt(customerID: customerID, eventAlias: eventAlias, url: url, includeQueueItUI: includeQueueItUI)
        queueIt.runCompletionHandler = completion
    }
}

// MARK: QueueIt checks on URL
extension NetworkAccessor {
    private func checkIfCookieIsSet<T: Decodable>(response: DataResponse<T, AFError>) -> Bool {
        // if cookie is set, then we can likely extract the response already
        if let cookie = response.response?.allHeaderFields["Set-Cookie"] as? String, cookie.contains("QueueITAccepted") {
            let header = response.response?.allHeaderFields as? [String: String]
            QueueItLocal.saveValueToDefaults(cookieHeader: header)
            return true
        }
        return false
    }
    
    private func checkForQueueItRedirect<T: Decodable>(response: DataResponse<T, AFError>) -> (c: String, e: String)? {
        // if redirect is in the url, then we need to run queue it by calling the delegate, then API client will run QUEUE IT, will get the token, then we will retry the request
        if let redirectURLStringEndcoded = response.response?.allHeaderFields["x-queueit-redirect"] as? String,
                  let decodedURLString = redirectURLStringEndcoded.removingPercentEncoding,
                  let url = URL(string: decodedURLString),
                  let items = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems {
            let customerID = items.first(where: { $0.name == "c" })?.value
            let eventAlias = items.first(where: { $0.name == "e" })?.value
            QueueItLocal.saveValueToDefaults(customerID: customerID, eventAlias: eventAlias)
            guard let custID = customerID, let evAlias = eventAlias else { return nil }
            return (c: custID, e: evAlias)
        }
        return nil
    }
}

extension NetworkAccessor: RemoteAccessor {
    
    func authorizationHeader(fromToken token: String) -> Headers {
        return [Constants.authorizationHeaderKey: token]
    }
    
    func request<T: Decodable>(withURL url: URL, method: MethodType, encoding: Encoding,
                               headers: Headers?, parameters: RequestParameters?, interceptor: Interceptor?,
                               checkQueueIt: Bool, executingVC: UIViewController, includeQueueItUI: Bool,
                               andCompletion completion: @escaping NetworkRequestCompletion<T>) {
        let request = AF.request(url, method: method, parameters: parameters, encoding: encoding, headers: headers, interceptor: interceptor)
        self.execute(request: request, checkQueueIt: checkQueueIt, executingVC: executingVC, includeQueueItUI: includeQueueItUI, withCompletion: completion)
    }
    
    func request<Parameters: Encodable, T: Decodable> (
        withURL url: URL,
        method: MethodType,
        headers: Headers?,
        encoder: ParameterEncoder,
        parameters: Parameters?,
        interceptor: Interceptor?,
        checkQueueIt: Bool,
        executingVC: UIViewController,
        includeQueueItUI: Bool,
        andCompletionHandler completion: @escaping NetworkRequestCompletion<T>) {
        
        let request = AF.request(url, method: method, parameters: parameters, encoder: encoder, headers: headers, interceptor: interceptor)
            self.execute(request: request, checkQueueIt: checkQueueIt, executingVC: executingVC, includeQueueItUI: includeQueueItUI, withCompletion: completion)
    }
    
    func uploadRequest<T: Decodable>(withURL url: URL, method: MethodType, mediaType: MIMEType?,
                                     headers: Headers, parameters: RequestParameters, interceptor: Interceptor?,
                                     checkQueueIt: Bool, executingVC: UIViewController, includeQueueItUI: Bool,
                                     andCompletion completion: @escaping NetworkRequestCompletion<T>) {
        let request = AF.upload(multipartFormData: { multipartFormData in
            parameters.forEach({ (key, value) in
                if let castedData = value as? Data {
                    multipartFormData.append(castedData, withName: key, fileName: key, mimeType: mediaType?.mimeType)
                } else if let castedStringData = (value as? String)?.data(using: .utf8) {
                    multipartFormData.append(castedStringData, withName: key)
                }
            })
        }, to: url, method: method, headers: headers, interceptor: interceptor)
        self.execute(request: request, checkQueueIt: checkQueueIt, executingVC: executingVC, includeQueueItUI: includeQueueItUI, withCompletion: completion)
    }
}


