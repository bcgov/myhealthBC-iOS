//
//  MIMEType.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-10-08.
//

import Foundation

enum MIMEType: String {
    
    case png, jpeg
    
    var mimeType: String {
        return "image/\(self.rawValue)"
    }
    
}
