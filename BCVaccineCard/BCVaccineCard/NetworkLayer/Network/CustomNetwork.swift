//
//  CustomNetwork.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2022-10-03.
//

import Foundation

struct CustomNetwork: Network {
    
    func request<Parameters, T>(with requestData: NetworkRequest<Parameters, T>) where Parameters : Encodable, T : Decodable {
        var parameters: [String: Any] = [String: Any]()
        if let requestParameters = requestData.parameters?.toDictionary() {
            parameters = requestParameters
        }
        var request = URLRequest(url: requestData.url)
        switch requestData.type {
        case .Get:
            request.httpMethod = "GET"
        case .Post:
            request.httpMethod = "POST"
        case .Put:
            request.httpMethod = "PUT"
        }
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "accept")
        
        if let requestHeaders = requestData.headers {
            for (key, value) in requestHeaders {
                request.addValue(value, forHTTPHeaderField: key)
            }
        }
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else {
            return
        }
        request.httpBody = httpBody
        request.timeoutInterval = 20
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if let response = response {
                print(response)
            }
            if let error = error {
                print(error)
            }
            if let data = data {
                #if DEV
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    print(json)
                } catch {
                    print(error)
                }
                #endif
                do {
                    let decoder = JSONDecoder()
                    let obj = try decoder.decode(T.self, from: data)
                    return requestData.completion(obj)
                } catch {
                    return requestData.completion(nil)
                }
            } else {
                return requestData.completion(nil)
            }
        }.resume()
    }
    
}

extension Encodable {

    /// Converting object to postable dictionary
    func toDictionary(_ encoder: JSONEncoder = JSONEncoder()) -> [String: Any]? {
        do {
            let data = try encoder.encode(self)
            let object = try JSONSerialization.jsonObject(with: data)
            guard let json = object as? [String: Any] else {
                let context = DecodingError.Context(codingPath: [], debugDescription: "Deserialized object is not a dictionary")
                return nil
            }
            return json
        } catch {
            return nil
        }
        
    }
}
