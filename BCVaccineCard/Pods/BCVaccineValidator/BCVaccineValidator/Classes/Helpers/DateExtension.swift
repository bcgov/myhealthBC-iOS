//
//  File.swift
//  
//
//  Created by Amir Shayegh on 2021-10-13.
//

import Foundation

extension Date {
    func daysTo(future date: Date) -> Int? {
        guard let numberOfDays = Calendar.current.dateComponents([.day], from: date, to: self).day else {
            return nil
        }
        if numberOfDays > 0 {
            return nil
        }
        return abs(numberOfDays)
    }
    
    /// Number of calendar days between two dates
    func interval(ofComponent comp: Calendar.Component, fromDate date: Date) -> Int {
        let currentCalendar = Calendar.current
        guard let start = currentCalendar.ordinality(of: comp, in: .era, for: date),
              let end = currentCalendar.ordinality(of: comp, in: .era, for: self) else {
            return 0
        }
        return end - start
    }
}
