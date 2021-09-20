//
//  UINavigationItem+Ext.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-09-15.
//

import UIKit

public extension UINavigationItem {
    func backItemTitle(with title: String?) {
        backBarButtonItem = UIBarButtonItem(title: title, style: .plain, target: nil, action: nil)
    }
}
