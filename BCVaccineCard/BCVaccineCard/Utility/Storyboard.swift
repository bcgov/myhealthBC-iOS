//
//  Storyboard.swift
//  ClientVaxPass-POC
//
//  Created by Connor Ogilvie on 2021-09-09.
//

import UIKit

enum Storyboard {
    static var main: UIStoryboard { return UIStoryboard(name: "Main", bundle: nil) }
    static var healthPass: UIStoryboard { return UIStoryboard(name: "HealthPass", bundle: nil) }
    static var records: UIStoryboard { return UIStoryboard(name: "Records", bundle: nil) }
    static var checker: UIStoryboard { return UIStoryboard(name: "Checker", bundle: nil) }
    static var booking: UIStoryboard { return UIStoryboard(name: "Booking", bundle: nil) }
    static var notifications: UIStoryboard { return UIStoryboard(name: "Notifications", bundle: nil) }
}
