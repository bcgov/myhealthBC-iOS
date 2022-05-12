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
class StatusBannerView: UIView, UITextViewDelegate {
    
    static let roundness: CGFloat = 5
    
    @IBOutlet weak var textView: UITextView!
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
    
    private var labels: [UILabel?] {
        return [recordTypeLabel, statusLabel, nameLabel, timeLabel]
    }
    
    enum BannerType {
        case Message
        case CovidTest
        case VaccineRecord
        case NoBanner
    }
    
    /// Configure View
    /// - Parameters:
    ///   - containerView: Container that this view will place itself in.
    public func setup(in containerView: UIView, type: BannerType) {
        // TODO: Delete this label? Not sure if it's being used by anything other than QA'ing the UI
        recordTypeLabel.isHidden = true
        // Place in container
        position(in: containerView)
        style(for: type)
    }
    
    /// Configure data
    /// - Parameters:
    ///   - type: Record type
    ///   - name: Name text
    ///   - status: status text
    ///   - date: date text
    ///   - backgroundColor: card background (not top banner)
    ///   - textColor: all text colour
    ///   - statusColor: status text colour
    ///   - statusIconImage: status image icon. leave nil to remove icon
    func update(type: BannerType,
                name: String?,
                status: String,
                date: String,
                backgroundColour: UIColor,
                textColour: UIColor,
                statusColour: UIColor,
                statusIconImage: UIImage?,
                attributedString: NSMutableAttributedString?
    ) {
        // set banner icon (gov logo)
        bannerImage.image = UIImage(named: "bc-logo")
        
        // Hide Top banner if needed & set rounded corners
        if type == .CovidTest {
            topContainer.isHidden = true
            mainContainer.layer.cornerRadius = Constants.UI.Theme.cornerRadiusRegular
        } else {
            topContainer.roundTopCorners(radius: Constants.UI.Theme.cornerRadiusRegular)
            mainContainer.roundBottomCorners(radius: Constants.UI.Theme.cornerRadiusRegular)
        }
        
        // Set Status Icon if needed
        if let icon = statusIconImage {
            statusIcon.image = icon
        } else {
            statusIcon.isHidden = true
        }
        
        // Set backgerund and text colours
        mainContainer.backgroundColor = backgroundColour
        labels.forEach { label in
            if let item = label {
                item.textColor = textColour
            }
        }
        statusLabel.textColor = statusColour
        textView.textColor = statusColour
        
        // set texts
        nameLabel.text = name
        statusLabel.text = status
        timeLabel.text = date
        textView.attributedText = attributedString
        
        self.layoutIfNeeded()
        style(for: type)
    }
    
    func style(for type: BannerType) {
        self.layoutIfNeeded()
        switch type {
        case .CovidTest:
            textView.isHidden = true
            
            nameLabel.font = UIFont.bcSansBoldWithSize(size: mediumFontSize)
            statusLabel.font = UIFont.bcSansBoldWithSize(size: largeFontSize)
            timeLabel.font = UIFont.bcSansRegularWithSize(size: smallFontSize)
        case .VaccineRecord:
            textView.isHidden = true
            
            nameLabel.font = UIFont.bcSansBoldWithSize(size: mediumFontSize)
            statusLabel.font = UIFont.bcSansRegularWithSize(size: largeFontSize)
            timeLabel.font = UIFont.bcSansRegularWithSize(size: smallFontSize)
        case .Message:
            topContainer.isHidden = true
            statusStack.isHidden = true
            timeLabel.isHidden = true
            nameLabel.isHidden = true
            
            textView.isUserInteractionEnabled = true
            textView.delegate = self
            textView.font = UIFont.bcSansBoldWithSize(size: mediumFontSize)
            textView.translatesAutoresizingMaskIntoConstraints = true
            textView.sizeToFit()
            textView.isScrollEnabled = false
            textView.isEditable = false
            textView.backgroundColor = .clear
        case .NoBanner:
            print("Not using this cell here")
        }
        self.layoutIfNeeded()
    }
    
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        UIApplication.shared.open(URL)
        return false
    }
    
    private func position(in containerView: UIView) {
        // Place in container
        self.frame = .zero
        containerView.addSubview(self)
        self.addEqualSizeContraints(to: containerView)
    }


}
