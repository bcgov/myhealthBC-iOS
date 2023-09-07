//
//  Created by Amir Shayegh
//

import Foundation

struct CustomNetwork: Network {
    
    let timeout: Double = 20
    
    func request<Parameters, T>(with requestData: NetworkRequest<Parameters, T>) where Parameters : Encodable, T : Decodable {
        var parameters: [String: Any] = [String: Any]()
        var httpBody: Data?
        
        var request = URLRequest(url: requestData.url, timeoutInterval: timeout)
        switch requestData.type {
        case .Get:
            request.httpMethod = "GET"
        case .Post:
            request.httpMethod = "POST"
        case .Put:
            request.httpMethod = "PUT"
        case .Delete:
            request.httpMethod = "DELETE"
        }
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "accept")
        
        if requestData.type != .Get {
            if let stringBody = requestData.stringBody {
                request.addValue("charset=UTF-8", forHTTPHeaderField: "Content-Type")
                httpBody = ("\"" + stringBody + "\"").data(using: .utf8)
            } else if let requestParameters = requestData.parameters?.toDictionary() {
                parameters = requestParameters
                let httpBodyJSON = try? JSONSerialization.data(withJSONObject: parameters, options: [])
                httpBody = httpBodyJSON
            }
        }
        if let requestHeaders = requestData.headers {
            for (key, value) in requestHeaders {
                request.addValue(value, forHTTPHeaderField: key)
            }
        }
       
        request.httpBody = httpBody
        request.timeoutInterval = timeout
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
                    DispatchQueue.main.async {
                        return requestData.completion(obj)
                    }
                } catch {
                    DispatchQueue.main.async {
                        return requestData.completion(nil)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    return requestData.completion(nil)
                }
            }
        }.resume()
    }
    
}
