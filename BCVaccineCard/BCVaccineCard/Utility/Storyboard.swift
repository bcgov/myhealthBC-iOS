//
//  Storyboard.swift
//  ClientVaxPass-POC
//
//  Created by Connor Ogilvie on 2021-09-09.
//

import UIKit

enum Storyboard {
    static var main: UIStoryboard { return UIStoryboard(name: "Main", bundle: nil) }
    static var home: UIStoryboard { return UIStoryboard(name: "Home", bundle: nil) }
    static var authentication: UIStoryboard { return UIStoryboard(name: "Authentication", bundle: nil) }
    static var healthPass: UIStoryboard { return UIStoryboard(name: "HealthPass", bundle: nil) }
    static var records: UIStoryboard { return UIStoryboard(name: "Records", bundle: nil) }
    static var resource: UIStoryboard { return UIStoryboard(name: "Resource", bundle: nil) }
    static var booking: UIStoryboard { return UIStoryboard(name: "Booking", bundle: nil) }
    static var newsFeed: UIStoryboard { return UIStoryboard(name: "NewsFeed", bundle: nil) }
    static var reusable: UIStoryboard { return UIStoryboard(name: "Reusable", bundle: nil) }
}
