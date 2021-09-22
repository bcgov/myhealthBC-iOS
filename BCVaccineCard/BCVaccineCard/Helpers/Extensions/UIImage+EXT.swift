//
//  UIImage+EXT.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2021-09-21.
//

import Foundation
import UIKit
extension UIImage {
    func findQRCodes() -> [String]? {
        guard let ciImage = CIImage.init(image: self) else {
            return nil
        }
        var options: [String: Any]
        let context = CIContext()
        options = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
        let qrDetector = CIDetector(ofType: CIDetectorTypeQRCode, context: context, options: options)
        if ciImage.properties.keys.contains((kCGImagePropertyOrientation as String)){
            options = [CIDetectorImageOrientation: ciImage.properties[(kCGImagePropertyOrientation as String)] ?? 1]
        } else {
            options = [CIDetectorImageOrientation: 1]
        }
        let features = qrDetector?.features(in: ciImage, options: options)
        guard let feat = features, !feat.isEmpty else { return nil }
        var result: [String] = []
        for case let row as CIQRCodeFeature in feat {
            if let string = row.messageString {
                result.append(string)
            }
        }
        return result
    }
}

// MARK: Converting image to string code
extension UIImage {
    // Note: Not sure if we need either of these, as the BCVaccineValidator may provide this for us
    func toPngString() -> String? {
        let data = self.pngData()
        return data?.base64EncodedString(options: .endLineWithLineFeed)
    }
    
    func toJpegString(compressionQuality cq: CGFloat) -> String? {
        let data = self.jpegData(compressionQuality: cq)
        return data?.base64EncodedString(options: .endLineWithLineFeed)
    }
    
}
