//
//  String+EXT.swift
//  ClientVaxPass-POC
//
//  Created by Connor Ogilvie on 2021-09-09.
//

import UIKit
import CoreImage.CIFilterBuiltins
import QRCodeGenerator
import PocketSVG

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
        // Separate numeric and alphanumberic portions of the code
        let prefix = "shc:/"
        let numeric = self.lowercased().replacingOccurrences(of: prefix, with: "")
        let shcSegment: QRSegment = QRSegment.makeBytes(Array(prefix.utf8))
        let numericSegment: QRSegment = QRSegment.makeNumeric(Array(numeric))
        let minBorder = 2
        let thinBorder = 3
        let mediumBorder = 4
        let thickBorder = 5
        var border = 6
        let payloadSize = self.lowercased().count
        if payloadSize > 1900 {
            border = minBorder
        } else if payloadSize > 1800 {
            border = thinBorder
        } else if payloadSize > 1700 {
            border = mediumBorder
        } else if payloadSize > 1600 {
            border = thickBorder
        }
        do {
            // Create QR SVG ( what what the library gives us.. )
            let qr = try QRCode.encode(segments: [shcSegment, numericSegment], ecl: .low)
            let svg = qr.toSVGString(border: border)
            // Generate UIImage from svg
            let path = SVGBezierPath.paths(fromSVGString: svg)
            let layer = SVGLayer()
            layer.paths = path
            let size = UIView.screenWidth
            let frame = CGRect(x: 0, y:  0 , width: size, height: size)
            layer.frame = frame
            let img = snapshotImage(for: layer)
            print(frame)
            print(self.lowercased().count)
            return img
            
        } catch {
            return nil
        }
        /*
        if #available(iOS 15.0, *) {
            let data = self.data(using: String.Encoding.ascii)
            let transform = CGAffineTransform(scaleX: 10, y: 10)
            
            let filter = CIFilter.qrCodeGenerator()
            let context = CIContext()
            filter.correctionLevel = "L"
            filter.setValue(data, forKey: "inputMessage")
            if let outputImage = filter.outputImage?.transformed(by: transform) {
                if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
                    return UIImage(cgImage: cgimg)
                }
            }
        } else {
            // Separate numeric and alphanumberic portions of the code
            let prefix = "shc:/"
            let numeric = self.lowercased().replacingOccurrences(of: prefix, with: "")
            let shcSegment: QRSegment = QRSegment.makeBytes(Array(prefix.utf8))
            let numericSegment: QRSegment = QRSegment.makeNumeric(Array(numeric))
            do {
                // Create QR SVG ( what what the library gives us.. )
                let qr = try QRCode.encode(segments: [shcSegment, numericSegment], ecl: .low)
                let svg = qr.toSVGString(border: 5)
                // Generate UIImage from svg
                let path = SVGBezierPath.paths(fromSVGString: svg)
                let layer = SVGLayer()
                layer.paths = path
                let size = UIView.screenWidth
                let frame = CGRect(x: 10, y: 10, width: size, height: size)
                layer.frame = frame
                let img = snapshotImage(for: layer)
                return img
                
            } catch {
                return nil
            }
        }
        */
        
        /* Ideal way - no longer working:
         https://developer.apple.com/library/archive/documentation/GraphicsImaging/Reference/CoreImageFilterReference/index.html#//apple_ref/doc/filter/ci/CIQRCodeGenerator
         if let filter = CIFilter(name: "CIQRCodeGenerator") {
         filter.setValue(data, forKey: "inputMessage")
         filter.setValue("L", forKey:"inputCorrectionLevel")
         if let cgimg = filter.outputImage?.transformed(by: transform) {
         return UIImage(ciImage: cgimg)
         }
         */
        
//        return nil
    }
    
    fileprivate func snapshotImage(for view: CALayer) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, UIScreen.main.scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        view.render(in: context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
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
