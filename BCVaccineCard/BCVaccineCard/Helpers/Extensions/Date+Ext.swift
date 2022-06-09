//
//  Date+Ext.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-09-17.
//

import Foundation

extension Date {
    struct Formatter {
        static let iso8601: DateFormatter = {
            let formatter = DateFormatter()
            formatter.calendar = Calendar(identifier: Calendar.Identifier.iso8601)
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            formatter.dateFormat = "MM/dd/yyyy HH:mm:ss z"
            return formatter
        }()
        
        //MARK: - Date & Time
        
        static let short: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .short
            return formatter
        }()
        
        static let medium: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .medium
            return formatter
        }()
        
        static let long: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateStyle = .long
            formatter.timeStyle = .long
            return formatter
        }()
        
        static let full: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateStyle = .full
            formatter.timeStyle = .full
            return formatter
        }()
        static let customDateTime: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM dd\nhh:mm a"
            return formatter
        }()
        static let issuedOnDateTime: DateFormatter = {
            let formatter = DateFormatter()
//            September-09-2012, 14:27
            formatter.dateFormat = "MMMM-dd-yyyy, hh:mm z"
            return formatter
        }()
        static let issuedOnDate: DateFormatter = {
            let formatter = DateFormatter()
//            September-09-2012
            formatter.dateFormat = "MMMM-dd-yyyy"
            return formatter
        }()
        static let gatewayDateAndTime: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            return formatter
        }()
        static let gatewayDateAndTimeWithMS: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
            return formatter
        }()
        static let gatewayDateAndTimeWithMSAndTimeZone: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            return formatter
        }()
        static let gatewayDateAndTimeWithTimeZone: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            return formatter
        }()
        static let labOrderDateTime: DateFormatter = {
            let formatter = DateFormatter()
//            2012-May-14, 4:35 PM
            formatter.dateFormat = "yyyy-MMMM-dd, hh:mm a"
            return formatter
        }()
        static let commentsDateTime: DateFormatter = {
            let formatter = DateFormatter()
//            2012-Apr-14, 4:35 PM
            formatter.dateFormat = "yyyy-MMM-dd, hh:mm a"
            return formatter
        }()
        
        //MARK: - Date
        static let shortDate: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            return formatter
        }()
        
        static let mediumDate: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter
        }()
        
        static let longDate: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateStyle = .long
            return formatter
        }()
        
        static let fullDate: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateStyle = .full
            return formatter
        }()
        
        static let birthdayYearDate: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy"
            return formatter
        }()
        
        static let monthDayYearDate: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM d, yyyy"
            return formatter
        }()
        
        
        //MARK: - Time
        static let shortTime: DateFormatter = {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            return formatter
        }()
        
        static let mediumTime: DateFormatter = {
            let formatter = DateFormatter()
            formatter.timeStyle = .medium
            return formatter
        }()
        
        static let longTime: DateFormatter = {
            let formatter = DateFormatter()
            formatter.timeStyle = .long
            return formatter
        }()
        
        static let fullTime: DateFormatter = {
            let formatter = DateFormatter()
            formatter.timeStyle = .full
            return formatter
        }()
        
        static let monthAndDay: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM dd"
            return formatter
        }()
        
        static let yearMonthDay: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            return formatter
        }()
        
        static let monthAndYear: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM yyyy"
            return formatter
        }()
        
        static let customHeaderDateAndTime: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM dd, hh:mm a"
            return formatter
        }()
        
        static let customHeaderDateAndTimeShort: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM dd, hh:mm a"
            return formatter
        }()
        
        //DOW
        static let dayOfWeek: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEE"
            return formatter
        }()
        
        //DAY
        static let dayNumber: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "d"
            return formatter
        }()
    }
    
    //MARK: - Date & Time Strings
    var shortString: String { return Formatter.short.string(from: self) }
    var mediumString: String { return Formatter.medium.string(from: self) }
    var longString: String { return Formatter.long.string(from: self) }
    var fullString: String { return Formatter.full.string(from: self) }
    var customDateTimeString: String { return Formatter.customDateTime.string(from: self) }
    var monthAndDayString: String { return Formatter.monthAndDay.string(from: self) }
    var monthAndYearString: String { return Formatter.monthAndYear.string(from: self) }
    var yearMonthDayString: String { return Formatter.yearMonthDay.string(from: self) }
    var customHeaderDateAndTime: String { return Formatter.customHeaderDateAndTime.string(from: self) }
    var customHeaderDateAndTimeShort: String { return Formatter.customHeaderDateAndTimeShort.string(from: self) }
    var issuedOnDateTime: String { return Formatter.issuedOnDateTime.string(from: self) }
    var issuedOnDate: String { return Formatter.issuedOnDate.string(from: self) }
    var gatewayDateAndTime: String { return Formatter.gatewayDateAndTime.string(from: self) }
    var gatewayDateAndTimeWithTimeZone: String { return Formatter.gatewayDateAndTimeWithTimeZone.string(from: self) }
    var gatewayDateAndTimeWithMS: String { return Formatter.gatewayDateAndTimeWithMS.string(from: self) }
    var gatewayDateAndTimeWithMSAndTimeZone: String { return Formatter.gatewayDateAndTimeWithMSAndTimeZone.string(from: self) }
    var labOrderDateTime: String { return Formatter.labOrderDateTime.string(from: self) }
    var commentsDateTime: String { return Formatter.commentsDateTime.string(from: self) }
    
    //MARK: - Date Strings
    var shortDateString: String { return Formatter.shortDate.string(from: self) }
    var mediumDateString: String { return Formatter.mediumDate.string(from: self) }
    var longDateString: String { return Formatter.longDate.string(from: self) }
    var fullDateString: String { return Formatter.fullDate.string(from: self) }
    var birthdayYearDateString: String { return Formatter.birthdayYearDate.string(from: self) }
    var monthDayYearString: String { return Formatter.monthDayYearDate.string(from: self) }
    
    //MARK: - Time String
    var shortTimeString: String { return Formatter.shortTime.string(from: self) }
    var mediumTimeString: String { return Formatter.mediumTime.string(from: self) }
    var longTimeString: String { return Formatter.longTime.string(from: self) }
    var fullTimeString: String { return Formatter.fullTime.string(from: self) }
    
    //MARK: - DOW String
    var dayOfWeekString: String { return Formatter.dayOfWeek.string(from: self) }
    
    //MARK: - Day Numer
    var dayNumberString: String { return Formatter.dayNumber.string(from: self) }
    
    //MARK: - Time Ago String
    var timeAgoString: String {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .weekOfYear, .day, .hour, .minute, .second], from: self)
        
        if components.year! >= 1 { return "\(components.year!) years ago" }
        else if components.month! >= 1 { return "\(components.month!) months ago" }
        else if components.weekOfYear! >= 1 { return "\(components.weekOfYear!) weeks ago" }
        else if components.day! >= 1 { return "\(components.day!) days ago" }
        else if components.hour! >= 1 { return "\(components.hour!) hours ago" }
        else if components.minute! >= 1 { return "\(components.minute!) minutes ago" }
        else if components.second! >= 3 { return "\(components.second!) seconds ago" }
        else { return "Just now" }
    }
    
    static func combineDateWithTime(date: Date, time: Date) -> Date? {
        let calendar = Calendar.current
        
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
        let timeComponents = calendar.dateComponents([.hour, .minute, .second], from: time)
        
        var mergedComponments = DateComponents()
        mergedComponments.year = dateComponents.year!
        mergedComponments.month = dateComponents.month!
        mergedComponments.day = dateComponents.day!
        mergedComponments.hour = timeComponents.hour!
        mergedComponments.minute = timeComponents.minute!
        mergedComponments.second = timeComponents.second!
        
        return calendar.date(from: mergedComponments)
    }
    
    static func getFutureDate() -> Date {
        let calendar = Calendar.current
        var dateComponents = calendar.dateComponents([.year], from: Date())
        dateComponents.year = dateComponents.year! + 100
        return calendar.date(from: dateComponents)!
    }
    
    static func dateByAddingDays(days: Int) -> Date? {
        guard let newDate = Calendar.current.date(byAdding: .day, value: days, to: Date()) else {
            return nil
        }
        return newDate
    }
    
    func differenceInDaysWithDate(date: Date) -> Int {
        let calendar = Calendar.current
        
        let date1 = calendar.startOfDay(for: self)
        let date2 = calendar.startOfDay(for: date)
        
        let components = calendar.dateComponents([.day], from: date1, to: date2)
        return components.day ?? 0
    }
}

extension Date {
    
    func isBetween(_ date1: Date, and date2: Date) -> Bool {
        return (min(date1, date2) ... max(date1, date2)).contains(self)
    }
    
    /// This returns `self` converted to from GMT to the local time zone
    var localTimeZoneDate: Date {
        let targetOffset = TimeInterval(TimeZone.autoupdatingCurrent.secondsFromGMT(for: self))
        return addingTimeInterval(targetOffset)
    }
    
}
