//
//  LargerTouchAreaButton.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-11-02.
//

import UIKit

class LargerTouchAreaButton: UIButton {
    
    private var xAdjustment: CGFloat = 0
    private var yAdjustment: CGFloat = 0
    
    @IBInspectable var expandedX: CGFloat {
        set {
            xAdjustment = newValue
        }
        get {
            return xAdjustment
        }
    }
    
    @IBInspectable var expandedY: CGFloat {
        set {
            yAdjustment = newValue
        }
        get {
            return yAdjustment
        }
    }

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let biggerFrame = bounds.insetBy(dx: -xAdjustment, dy: -yAdjustment)
        return biggerFrame.contains(point)
    }
}
