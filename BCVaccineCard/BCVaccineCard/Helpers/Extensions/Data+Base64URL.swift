//
//  Data+Base64URL.swift
//  BCVaccineCard
//
//  Created by Health Gateway on 2024.
//

import Foundation

extension Data {
    /// Initialize Data from a base64 URL-encoded string
    /// Base64 URL encoding uses `-` instead of `+` and `_` instead of `/`
    init?(base64URLEncoded string: String) {
        // Convert base64URL to standard base64
        var base64 = string
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")

        // Add padding if needed
        let remainder = base64.count % 4
        if remainder > 0 {
            base64 = base64.padding(toLength: base64.count + 4 - remainder,
                                    withPad: "=",
                                    startingAt: 0)
        }

        self.init(base64Encoded: base64)
    }
}
