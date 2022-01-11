//
//  Log.swift
//  BCVaccineCard
//
//  Created by Amir on 2022-01-06.
//

import Foundation

class Logger {
    public static func log(string: String) {
        #if DEV
        print(string)
        #endif
    }
}
