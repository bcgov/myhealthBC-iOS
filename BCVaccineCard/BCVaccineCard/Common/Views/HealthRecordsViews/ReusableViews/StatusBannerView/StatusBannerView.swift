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
    @IBOutlet weak var messageIcon: UIImageView!
    @IBOutlet weak var messageStack: UIStackView!
    
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
        case LabOrderPending
        case LabOrderWithoutTests
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
            setImage(type: type, icon: icon)
        } else {
            statusIcon.isHidden = true
            messageIcon.isHidden = true
        }
        
        // Set backgerund and text colours
        mainContainer.backgroundColor = backgroundColour
        labels.forEach { label in
            if let item = label {
                item.textColor = textColour
            }
        }
        statusLabel.textColor = statusColour
        
        // set texts
        nameLabel.text = name
        statusLabel.text = status
        timeLabel.text = date
        textView.attributedText = attributedString
        
        self.layoutIfNeeded()
        style(for: type)
        textView.textColor = statusColour
    }
    
    func setImage(type: BannerType, icon: UIImage) {
        switch type {
        case .VaccineRecord:
            statusIcon.isHidden = false
            statusIcon.image = icon
        case .LabOrderPending, .LabOrderWithoutTests:
            messageIcon.isHidden = false
            messageIcon.image = icon
        default:
            statusIcon.isHidden = true
            messageIcon.isHidden = true
        }
    }
    
    func style(for type: BannerType) {
        self.layoutIfNeeded()
        switch type {
        case .CovidTest:
            messageStack.isHidden = true
            nameLabel.font = UIFont.bcSansBoldWithSize(size: mediumFontSize)
            statusLabel.font = UIFont.bcSansBoldWithSize(size: largeFontSize)
            timeLabel.font = UIFont.bcSansRegularWithSize(size: smallFontSize)
        case .VaccineRecord:
            messageStack.isHidden = true
            nameLabel.font = UIFont.bcSansBoldWithSize(size: mediumFontSize)
            statusLabel.font = UIFont.bcSansRegularWithSize(size: largeFontSize)
            timeLabel.font = UIFont.bcSansRegularWithSize(size: smallFontSize)
        case .Message:
            topContainer.isHidden = true
            statusStack.isHidden = true
            timeLabel.isHidden = true
            nameLabel.isHidden = true
            messageStack.isHidden = false
            messageIcon.isHidden = true
            messageStack.alignment = .fill
            
            setupTextView()
            textView.font = UIFont.bcSansBoldWithSize(size: mediumFontSize)
            textView.sizeToFit()
        case .LabOrderPending, .LabOrderWithoutTests:
            messageStack.isHidden = false
            setupTextView()
            nameLabel.isHidden = true
            topContainer.isHidden = true
            textView.isUserInteractionEnabled = true
            textView.delegate = self
            timeLabel.isHidden = true
            statusStack.isHidden = true
            textView.sizeToFit()
        case .NoBanner:
            Logger.log(string: "Not using this cell here", type: .general)
        }
        self.layoutIfNeeded()
    }
    
    func setupTextView() {
        textView.isUserInteractionEnabled = true
        textView.delegate = self
        textView.translatesAutoresizingMaskIntoConstraints = true
        textView.isScrollEnabled = false
        textView.isEditable = false
        textView.backgroundColor = .clear
        textView.sizeToFit()
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
//        UIApplication.shared.open(URL)
        AppDelegate.sharedInstance?.showExternalURL(url: URL.absoluteString)
        return false
    }
    
    private func position(in containerView: UIView) {
        // Place in container
        self.frame = .zero
        containerView.addSubview(self)
        self.addEqualSizeContraints(to: containerView)
    }


}
