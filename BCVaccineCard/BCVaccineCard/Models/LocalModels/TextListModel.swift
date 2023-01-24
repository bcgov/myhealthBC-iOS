//
//  TextListModel.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-11-29.
//

import UIKit

struct TextListModel: Codable {
    var header: TextProperties
    var subtext: TextProperties?
    var thirdLine: TextProperties?
}

struct LinkedStrings: Codable, Equatable {
    let text: String
    let link: String
}

struct TextProperties: Codable {
    var text: String
    var bolded: Bool
    var italic: Bool? = false
    var fontSize: CGFloat = 17.0
    var links: [LinkedStrings]? = nil
    var textColor: CodableColors = .black
    
    enum CodableColors: Codable {
        case black, red, green, grey
        
        var getUIColor: UIColor {
            switch self {
            case .black: return AppColours.textBlack
            case .red: return AppColours.appRed
            case .green: return AppColours.green
            case .grey: return UIColor(red: 0.427, green: 0.459, blue: 0.49, alpha: 1)
            }
        }
    }
    
    var font: UIFont {
        if bolded {
            return UIFont.bcSansBoldWithSize(size: fontSize)
        }
        if let italic = italic, italic {
            return UIFont.bcSansItalicWithSize(size: fontSize)
        }
        return UIFont.bcSansRegularWithSize(size: fontSize)
    }
}
