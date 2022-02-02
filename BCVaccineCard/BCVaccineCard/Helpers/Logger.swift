//
//  Log.swift
//  BCVaccineCard
//
//  Created by Amir on 2022-01-06.
//

import Foundation

class Logger {
    
    enum LogType {
        case general
        case storage
        case localAuth
    }
    
    /// Add LogType to array to hide logs of that type
    private static let hiddenLogTypes: [LogType] = []
    
    public static func log(string: String, type: LogType) {
        #if DEV
        if hiddenLogTypes.contains(type) {return}
        print(string)
        #endif
    }
}
