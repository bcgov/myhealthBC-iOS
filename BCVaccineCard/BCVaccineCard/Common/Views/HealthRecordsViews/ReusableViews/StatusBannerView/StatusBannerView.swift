//
//  StatusBannerView.swift
//  BCVaccineCard
//
//  Created by Amir on 2021-11-25.
//

import UIKit

/**
  TODO:
 - check stackview spacing
 - add gov logo image
 - check fonts and font sizes
 - adjust status icon size (ratio is set 1:1, but widht or height is not set)
 */

/**
 Usage:
 let ban: StatusBannerView = StatusBannerView.fromNib()
 ban.setup()
 */
class StatusBannerView: UIView {
    
    @IBOutlet weak var contentStackView: UIStackView!
    @IBOutlet weak var bannerImage: UIImageView!
    @IBOutlet weak var topContainer: UIView!
    @IBOutlet weak var mainContainer: UIView!
    @IBOutlet weak var recordTypeLabel: UILabel!
    @IBOutlet weak var statusStack: UIStackView!
    @IBOutlet weak var statusIcon: UIImageView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    private var labels: [UILabel?] {
        return [recordTypeLabel, statusLabel, nameLabel, timeLabel]
    }
    
    enum RecordType {
        case CovidTest
        case VaccineRecord
    }
    
    /// Configure View
    /// - Parameters:
    ///   - containerView: Container that this view will place itself in.
    ///   - type: Record type
    ///   - name: Name text
    ///   - status: status text
    ///   - date: date text
    ///   - backgroundColor: card background (not top banner)
    ///   - textColor: all text colour
    ///   - statusColor: status text colour
    ///   - statusIconImage: status image icon. leave nil to remove icon
    public func setup(in containerView: UIView, type: RecordType, name: String, status: String, date: String, backgroundColor: UIColor, textColor: UIColor, statusColor: UIColor, statusIconImage: UIImage?) {
        // TODO: Delete this label? Not sure if it's being used by anything other than QA'ing the UI
        recordTypeLabel.isHidden = true
        // Place in container
        self.frame = .zero
        containerView.addSubview(self)
        self.addEqualSizeContraints(to: containerView)
        
        // set banner icon (gov logo)
        bannerImage.image = UIImage(named: "bc-logo")
        
        // Hide Top banner if needed
        if type == .CovidTest {
            topContainer.isHidden = true
        }
        
        // Set Status Icon if needed
        if let icon = statusIconImage {
            statusIcon.image = icon
        } else {
            statusIcon.isHidden = true
        }
        
        // Set backgerund and text colours
        mainContainer.backgroundColor = backgroundColor
        labels.forEach { label in
            if let item = label {
                item.textColor = textColor
            }
        }
        statusLabel.textColor = statusColor
        
        // set texts
        nameLabel.text = name
        statusLabel.text = status
        timeLabel.text = date
        
        // Adjust fonts based on type
        switch type {
        case .CovidTest:
            // TODO: put corrent fonts and sizes
            nameLabel.font = UIFont.bcSansBoldWithSize(size: 17)
            statusLabel.font = UIFont.bcSansBoldWithSize(size: 17)
            timeLabel.font = UIFont.bcSansRegularWithSize(size: 15)
        case .VaccineRecord:
            // TODO: put corrent fonts and sizes
            nameLabel.font = UIFont.bcSansBoldWithSize(size: 17)
            statusLabel.font = UIFont.bcSansBoldWithSize(size: 17)
            timeLabel.font = UIFont.bcSansRegularWithSize(size: 15)
        }
    }


}
