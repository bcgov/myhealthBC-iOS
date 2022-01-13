//
//  QRMaker.swift
//  BCVaccineCard
//
//  Created by Amir on 2022-01-13.
//

import UIKit
import CoreImage.CIFilterBuiltins
import QRCodeGenerator
import PocketSVG

class QRCache {
    let code: String
    let image: UIImage
    var lastUsed: Date
    
    init(code: String, image: UIImage, lastUsed: Date) {
        self.code = code
        self.image = image
        self.lastUsed = lastUsed
    }
}

class QRMaker {
    
    static var cache: [QRCache] = [] {
        didSet {
            cleanCache()
        }
    }
    
    static func image(for string: String, completion: @escaping(UIImage?)->Void) {
        DispatchQueue.global(qos: .background).async {
            if let cahced = cache.filter({$0.code == string}).first {
                cahced.lastUsed = Date()
                DispatchQueue.main.async {
                    return completion(cahced.image)
                }
            } else if let image = string.generateQRCode() {
                let cacheObject = QRCache(code: string, image: image, lastUsed: Date())
                cache.append(cacheObject)
                DispatchQueue.main.async {
                    return completion(image)
                }
            } else {
                return completion(nil)
            }
        }
    }
    
    fileprivate static func cleanCache() {
        if cache.count < 5 { return }
        var sorted = cache.sorted(by: {$0.lastUsed > $1.lastUsed})
        sorted.removeSubrange(4...)
        cache = sorted
    }
}
// MARK: Convert String Code to UIImage
extension String {
    fileprivate func generateQRCode() -> UIImage? {
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
    
}
