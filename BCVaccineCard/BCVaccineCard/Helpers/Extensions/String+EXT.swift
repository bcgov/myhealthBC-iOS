//
//  String+EXT.swift
//  ClientVaxPass-POC
//
//  Created by Connor Ogilvie on 2021-09-09.
//

import UIKit

extension String {
    
//    var isValidPHN: Bool {
//        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
//        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
//        return emailTest.evaluate(with: self.trimWhiteSpacesAndNewLines)
//    }
    
    var trimWhiteSpacesAndNewLines: String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
}
