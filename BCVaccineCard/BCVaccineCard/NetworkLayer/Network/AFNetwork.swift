//
//  Network.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2022-09-14.
//

import Foundation
import Alamofire
import SwiftyJSON

struct BodyStringEncoding: ParameterEncoding {
    
    private let body: String
    
    init(body: String) { self.body = body }
    
    func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        guard var urlRequest = urlRequest.urlRequest else { throw Errors.emptyURLRequest }
        guard let data = body.data(using: .utf8) else { throw Errors.encodingProblem }
        urlRequest.httpBody = data
        return urlRequest
    }
}

extension BodyStringEncoding {
    enum Errors: Error {
        case emptyURLRequest
        case encodingProblem
    }
}

extension BodyStringEncoding.Errors: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .emptyURLRequest: return "Empty url request"
        case .encodingProblem: return "Encoding problem"
        }
    }
}

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
        if let stringBody = stringBody {
//            let encoder: ParameterEncoder = .urlEncodedForm(encoder: URLEncodedFormEncoder(dataEncoding: .base64), destination: .httpBody)
//            let param = Data(stringBody.utf8).base64EncodedString()
//            return AF.request(url, method: type.AFMethod, parameters: param, encoder: .urlEncodedForm, headers: afHeaders)
            
            var request = URLRequest(url: url)
            request.httpMethod = type.AFMethod.rawValue
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = stringBody.data(using: .utf8)
            if let unwrappedHeaders = afHeaders {
                request.headers = unwrappedHeaders
            }
            return AF.request(request)
        } else {
            let alamoEncoder: ParameterEncoder = encoder == .json ? .json : .urlEncodedForm
            return AF.request(url, method: type.AFMethod, parameters: parameters, encoder: alamoEncoder, headers: afHeaders)
        }
    }
}


class AFNetwork: Network {
    private var requestAttempts: [URL: Int] = [URL: Int]()
    
    func request<Parameters: Encodable, T: Decodable>(with requestData: NetworkRequest<Parameters, T>) {
        DispatchQueue.global(qos: .userInitiated).async {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .secondsSince1970 // Decode UNIX timestamps
            let AFRequest = requestData.AFRequest
            print(AFRequest)
            AFRequest.responseDecodable(of: T.self, decoder: decoder, completionHandler: {response in
                return self.returnOrRetryIfneeded(with: requestData, response: response)
            })
        }
    }
}


// MARK: Retry Logic
extension AFNetwork {
    private func returnOrRetryIfneeded<Parameters: Encodable, T: Decodable>(with requestData: NetworkRequest<Parameters, T>, response: DataResponse<T, AFError>)  {
        guard let value = response.value else {
            // Didnt get a response.. return nil
            // Note - this is for empty responses with 200 status codes
            guard let statusCode = response.response?.statusCode else { return requestData.completion(nil) }
            if (200...299).contains(statusCode) {
                return requestData.completion(statusCode as? T)
            } else {
                return requestData.completion(nil)
            }
        }
        
        // Base GATEWAY reposnse (V1 API)
        guard value is BaseGatewayResponse,
              let gateWayResponse = value as? BaseGatewayResponse,
              let dict = gateWayResponse.toDictionary(),
              let resourcePayloadDict = JSON(dict)["resourcePayload"].dictionary,
              let retryIn = resourcePayloadDict["retryin"]?.int,
              let loaded = resourcePayloadDict["loaded"]?.bool
        else {
            // Not a BaseGatewayResponse - return response
            // Handle v2 Response
            let statusCode = response.response?.statusCode
            if let code = statusCode, let errorCallback = requestData.onError {
                if (200...299).contains(code) {
                    // Success
                    return requestData.completion(value)
                } else if code == 401 {
                    errorCallback(.code401)
                } else if code == 403 {
                    errorCallback(.code403)
                } else if code == 404 {
                    errorCallback(.code404)
                } else if code == 503 {
                    errorCallback(.code503)
                } else if (400...499).contains(code) {
                    errorCallback(.codeGeneric400)
                } else if (500...599).contains(code) {
                    errorCallback(.codeGeneric500)
                } else {
                    errorCallback(.codeUnmapped)
                }
            }
            // There was an error that was specified by errorCallback
            // - or the caller doesnt care about errors and there was no error
            return requestData.completion(value)
        }
        let payLoadStruct = RetryableGatewayResponse(loaded: loaded, retryin: retryIn)

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
            
            var retryIn: Double = Double(requestData.retryIn)
            if let payloadRetry = payLoadStruct.retryin {
                retryIn = Double(payloadRetry) / 1000
                if retryIn < 1 {
                    retryIn = Double(requestData.retryIn)
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + retryIn) {
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


extension Encodable {

    func toDictionary(_ encoder: JSONEncoder = JSONEncoder()) -> [String: Any]? {
        do {
            let data = try encoder.encode(self)
            let object = try JSONSerialization.jsonObject(with: data)
            guard let json = object as? [String: Any] else {
                return nil
            }
            return json
        } catch {
            return nil
        }
        
    }
}
