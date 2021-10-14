//
//  NetworkRequestInterceptor.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-10-13.
//

import Alamofire
import Foundation

class NetworkRequestInterceptor: Interceptor {
  //1
  let retryLimit = 5
  let retryDelay: TimeInterval = 10
  //2
  func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
    var urlRequest = urlRequest
      // Note: We would add cookie here
//    if let token = TokenManager.shared.fetchAccessToken() {
//      urlRequest.setValue("token \(token)", forHTTPHeaderField: "Authorization")
//    }
      guard let urlString = urlRequest.url?.absoluteString else { return }
      urlRequest.addValue(urlString, forHTTPHeaderField: "x-queueit-ajaxpageurl")
    completion(.success(urlRequest))
  }
  //3
  func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
    let response = request.task?.response as? HTTPURLResponse
    //Retry for 5xx status codes
    if let statusCode = response?.statusCode,
      (500...599).contains(statusCode),
      request.retryCount < retryLimit {
        completion(.retryWithDelay(retryDelay))
    } else {
      return completion(.doNotRetry)
    }
  }
}
