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
}

// MARK: Convert String Code to UIImage
extension String {
    func generateQRCode() -> UIImage? {
        let data = self.data(using: String.Encoding.ascii)
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 10, y: 10)

            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }
        return nil
    }
    
    // TODO: This is for the static data for testing purposes - once health gateway is actually working, we can remove this
    func toImage() -> UIImage? {
        if let data = Data(base64Encoded: self, options: .ignoreUnknownCharacters){
            return UIImage(data: data)
        }
        return nil
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


