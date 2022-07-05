//
//  BaseHeaderTableViewCell.swift
//  BCVaccineCard
//
//  Created by Amir on 2022-06-30.
//

import UIKit

class BaseHeaderTableViewCell: UITableViewCell {

    var largeFontSize: CGFloat {
        if Device.IS_IPHONE_5 {
            return 16
        } else {
            return 18
        }
    }
    
    var mediumFontSize: CGFloat {
        if Device.IS_IPHONE_5 {
            return 14
        } else {
            return 16
        }
    }
    
    var smallFontSize: CGFloat {
        if Device.IS_IPHONE_5 {
            return 12
        } else {
            return 15
        }
    }
    
}
