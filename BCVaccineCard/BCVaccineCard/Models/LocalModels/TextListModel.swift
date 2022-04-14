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
    
    struct TextProperties: Codable {
        var text: String
        var bolded: Bool
        var fontSize: CGFloat = 17.0
        var links: [LinkedStrings]? = nil
        var textColor: CodableColors = .black
        
        enum CodableColors: Codable {
            case black, red, green
            
            var getUIColor: UIColor {
                switch self {
                case .black: return AppColours.textBlack
                case .red: return AppColours.appRed
                case .green: return AppColours.vaccinatedGreen
                }
            }
        }
    }
}

