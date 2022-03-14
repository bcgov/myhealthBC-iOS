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
    
    /// This returns whether or not the string is empty by trimming whitespaces and new lines characters.
    var isBlank: Bool {
        return self.trimWhiteSpacesAndNewLines.isEmpty
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
    func widthForView(font:UIFont, height:CGFloat)  -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingRect = self.boundingRect(with: constraintRect, options: [.usesLineFragmentOrigin, .usesFontLeading],
                                             attributes: [.font: font],
                                             context: nil)
        return ceil(boundingRect.width)
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

// MARK: For capitalization
extension String {
    private func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }

    func sentenceCase() -> String {
        return self.lowercased().capitalizingFirstLetter()
    }
}

extension Optional where Wrapped == String {
    
    /// This computable property unwraps an optional string value to empty string.
    var unwrapped: String {
        return self ?? ""
    }
    
    /// This computable property checks if the optional string is nil or blank.
    var isBlank: Bool {
        guard let castedSelf = self else { return true }
        return castedSelf.isBlank
    }
    
}

// MARK: For XML Parsing
extension String{
    // remove amp; from string
    func removeAMPSemicolon() -> String{
        return replacingOccurrences(of: "amp;", with: "")
    }
    
    // replace "&" with "And" from string
    func replaceAnd() -> String{
        return replacingOccurrences(of: "&", with: "And")
    }
    
    // replace "\n" with "" from string
    func removeNewLine() -> String{
        return replacingOccurrences(of: "\n", with: "")
    }
    
    func replaceAposWithApos() -> String{
        return replacingOccurrences(of: "Andapos;", with: "'")
    }
}


extension Array where Element == String {
    func maxHeightNeeded(width: CGFloat, font: UIFont) -> CGFloat {
        var max: CGFloat = 0
        for string in self {
            let height = string.heightForView(font: font, width: width)
            if height > max {
                max = height
            }
        }
        return max
    }
}
