//
//  AppStyleButton.swift
//  ClientVaxPass-POC
//
//  Created by Connor Ogilvie on 2021-09-09.
// 26 50 95

import UIKit

protocol AppStyleButtonDelegate: AnyObject {
    func buttonTapped(type: AppStyleButton.ButtonType)
}

class AppStyleButton: UIView {
    
    enum ButtonStyle {
        case white, blue
        
        var getColorScheme: (backgroundColor: UIColor, titleColor: UIColor) {
            let bg = self == .white ? UIColor.white : AppColours.appBlue
            let tc = self == .white ? AppColours.appBlue : UIColor.white
            return (backgroundColor: bg, titleColor: tc)
        }
    }
    
    enum ButtonType {
        case cancel
        case enter
        case done
        case saveACopy
        case close
        
        var getTitle: String {
            switch self {
            case .cancel: return "Cancel"
            case .enter: return "Enter"
            case .done: return "Done"
            case .saveACopy: return "Save A Copy"
            case .close: return "Close"
            }
        }
    }
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var roundedButton: UIButton!
    
    weak var delegate: AppStyleButtonDelegate?
    private var buttonType: ButtonType!
    
    var enabled: Bool = true {
        didSet {
            self.roundedButton.isEnabled = enabled
            self.roundedButton.alpha = enabled ? 1.0 : 0.3
        }
    }
    
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
        Bundle.main.loadNibNamed("AppStyleButton", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        setup()
    }
    
    private func setup() {
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOffset = CGSize(width: 0, height: 0)
        contentView.layer.shadowOpacity = 0.05
        contentView.layer.shadowRadius = 10.0
    }
    
    @IBAction func buttonTappedAction(_ sender: UIButton) {
        self.delegate?.buttonTapped(type: self.buttonType)
    }
    
    func configure(withStyle style: ButtonStyle, buttonType: ButtonType, delegateOwner: UIViewController, enabled: Bool) {
        roundedButton.backgroundColor = style.getColorScheme.backgroundColor
        roundedButton.setTitleColor(style.getColorScheme.titleColor, for: .normal)
        roundedButton.setTitle(buttonType.getTitle, for: .normal)
        self.delegate = delegateOwner as? AppStyleButtonDelegate
        self.buttonType = buttonType
        self.enabled = enabled
    }
}
