//
//  TableViewButtonView.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-10-28.
//

import UIKit

class TableViewButtonView: UIView {
    
    enum ButtonStyle {
        case white, blue
        
        var getColorScheme: (backgroundColor: UIColor, titleColor: UIColor) {
            let bg = self == .white ? UIColor.white : AppColours.appBlue
            let tc = self == .white ? AppColours.appBlue : UIColor.white
            return (backgroundColor: bg, titleColor: tc)
        }
    }
    
    enum ButtonType {
        case goToEnterGateway
        case goToCameraScan
        case goToUploadImage
        
        var getTitle: String {
            switch self {
            case .goToEnterGateway: return .healthGatewayOption
            case .goToCameraScan: return .cameraScanOption
            case .goToUploadImage: return .imageUploadOption
            }
        }
        
        var getImage: UIImage {
            switch self {
            case .goToEnterGateway: return #imageLiteral(resourceName: "address-card")
            case .goToCameraScan: return #imageLiteral(resourceName: "camera")
            case .goToUploadImage: return #imageLiteral(resourceName: "arrow-to-top")
            }
        }
        
        var accessibilityHint: String {
            switch self {
            case .goToEnterGateway: return AccessibilityLabels.QRMethods.enterGatewayInfo
            case .goToCameraScan: return AccessibilityLabels.QRMethods.scanWithCamera
            case .goToUploadImage: return AccessibilityLabels.QRMethods.uploadImage
            }
        }
    }
    
    @IBOutlet weak private var contentView: UIView!
    @IBOutlet weak private var borderRoundedView: UIView!
    @IBOutlet weak private var roundedView: UIView!
    @IBOutlet weak private var optionTitleLabel: UILabel!
    @IBOutlet weak private var optionImageView: UIImageView!
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed(TableViewButtonView.getName, owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        setup()
    }
    
    private func setup() {
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        borderRoundedView.layer.cornerRadius = 4.0
        borderRoundedView.layer.masksToBounds = true
        borderRoundedView.backgroundColor = AppColours.appBlue
        roundedView.layer.cornerRadius = 4.0
        roundedView.layer.masksToBounds = true
        optionTitleLabel.font = UIFont.bcSansBoldWithSize(size: 16)
    }
    
    func configure(withStyle style: ButtonStyle, buttonType: ButtonType) {
        roundedView.backgroundColor = style.getColorScheme.backgroundColor
        optionTitleLabel.textColor = style.getColorScheme.titleColor
        optionTitleLabel.text = buttonType.getTitle
        if #available(iOS 13.0, *) {
            optionImageView.image = buttonType.getImage.withTintColor(style.getColorScheme.titleColor)
        } else {
            optionImageView.image = buttonType.getImage.withRenderingMode(.alwaysTemplate)
            optionImageView.tintColor = style.getColorScheme.titleColor
        }
    }
}
