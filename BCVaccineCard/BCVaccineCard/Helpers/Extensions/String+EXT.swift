//
//  String+EXT.swift
//  ClientVaxPass-POC
//
//  Created by Connor Ogilvie on 2021-09-09.
//

import UIKit

// Validation checks on strings
extension String {
    
    var isValidNumber: Bool {
        let numberRegEx = "^[0-9]+$"
        let numberTest = NSPredicate(format: "SELF MATCHES %@", numberRegEx)
        return numberTest.evaluate(with: self.removeWhiteSpaceFormatting)
    }
    
    func isValidLength(length: Int) -> Bool {
        return self.removeWhiteSpaceFormatting.count == length
    }
    
    func isValidDate(withFormatter formatter: DateFormatter) -> Bool {
        guard formatter.date(from: self) != nil else { return false }
        return true
    }
    
    func isValidDateRange(withFormatter formatter: DateFormatter, earliestDate: Date? = nil, latestDate: Date? = nil) -> Bool {
        guard let date = formatter.date(from: self) else { return false }
        if let earliest = earliestDate, let latest = latestDate {
            return date >= earliest && date <= latest
        } else if let earliest = earliestDate {
            return date >= earliest
        } else if let latest = latestDate {
            return date <= latest
        }
        return true
    }
    
    var removeWhiteSpaceFormatting: String {
        return self.replacingOccurrences(of: " ", with: "")
    }
    
    var trimWhiteSpacesAndNewLines: String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
}

extension String {
    /// This method returns height of a string with specific `width` and `font`
    /// - Parameter width: Width of the view where string has to be displayed
    /// - Parameter font: Font of the view where string has to be displayed
    func heightForView(font:UIFont, width:CGFloat)  -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingRect = self.boundingRect(with: constraintRect, options: [.usesLineFragmentOrigin, .usesFontLeading],
                                             attributes: [.font: font],
                                             context: nil)
        return ceil(boundingRect.height)
                                             
    }
}

// MARK: Convert String Code to UIImage
extension String {
    func toImage() -> UIImage? {
        if let data = Data(base64Encoded: self, options: .ignoreUnknownCharacters){
            return UIImage(data: data)
        }
        return nil
    }
}
