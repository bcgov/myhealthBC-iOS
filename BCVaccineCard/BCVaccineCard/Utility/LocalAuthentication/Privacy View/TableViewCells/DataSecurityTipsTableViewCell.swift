//
//  DataSecurityTipsTableViewCell.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2022-04-06.
//
// FIXME: NEED TO LOCALIZE 
import UIKit

class DataSecurityTipsTableViewCell: UITableViewCell {
    
    enum DataTipType: Int, CaseIterable {
        case introText
        case touchTip
        case passcodeTip
        case unlockTip
        
        var text: String {
            switch self {
            case .introText:
                return "Health information for you and your family can be stored on this device. To keep this data private, you must have your device security features turned on."
            case .touchTip:
                return "Do not turn off your fingerprint ID or face ID"
            case .passcodeTip:
                return "Do not share or turn off your passcode"
            case .unlockTip:
                return "Do not leave your device unlocked"
            }
        }
        
        var image: UIImage? {
            switch self {
            case .introText: return nil
            case .touchTip: return UIImage(named: "data-tip-touch")
            case .passcodeTip: return UIImage(named: "data-tip-passcode")
            case .unlockTip: return UIImage(named: "data-tip-unlock")
            }
        }
        
        var constraints: (width: CGFloat, leading: CGFloat) {
            switch self {
            case .introText: return (width: 0, leading: 0)
            case .touchTip, .passcodeTip, .unlockTip: return (width: 48, leading: 15)
            }
        }
    }
    
    @IBOutlet weak private var dataTextLabel: UILabel!
    @IBOutlet weak private var dataTextLabelLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak private var dataImageView: UIImageView!
    @IBOutlet weak private var dataImageViewWidthConstraint: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    private func setup() {
        dataTextLabel.textColor = AppColours.textBlack
        dataTextLabel.font = UIFont.bcSansRegularWithSize(size: 17)
    }
    
    func configure(type: DataTipType) {
        dataTextLabel.text = type.text
        dataImageView.image = type.image
        let constraints = type.constraints
        dataTextLabelLeadingConstraint.constant = constraints.leading
        dataImageViewWidthConstraint.constant = constraints.width
    }
}
