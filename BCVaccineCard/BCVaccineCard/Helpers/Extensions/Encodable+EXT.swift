//
//  Encodable+EXT.swift
//  BCVaccineCard
//
//  Created by Amir on 2021-11-29.
//

import Foundation
import CommonCrypto

extension Encodable {
    fileprivate func toString() -> String? {
        let encoder = JSONEncoder()
        if let jsonData = try? encoder.encode(self) {
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                return jsonString
            }
        }
        return nil
    }
    
    func md5Hash() -> String? {
        guard let string = self.toString(), let messageData = string.data(using:.utf8) else {return nil}

        let length = Int(CC_MD5_DIGEST_LENGTH)
        
        var digestData = Data(count: length)
        
        _ = digestData.withUnsafeMutableBytes { digestBytes -> UInt8 in
            messageData.withUnsafeBytes { messageBytes -> UInt8 in
                if let messageBytesBaseAddress = messageBytes.baseAddress, let digestBytesBlindMemory = digestBytes.bindMemory(to: UInt8.self).baseAddress {
                    let messageLength = CC_LONG(messageData.count)
                    CC_MD5(messageBytesBaseAddress, messageLength, digestBytesBlindMemory)
                }
                return 0
            }
        }
        return digestData.base64EncodedString()
    }
}
