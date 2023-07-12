//
//  HomeScreenAuthCollectionViewCell.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2023-07-12.
//

import UIKit

protocol HomeScreenAuthCollectionViewCellDelegate: AnyObject {
    func loginTapped()
}

class HomeScreenAuthCollectionViewCell: UICollectionViewCell, Theme {
    
    @IBOutlet weak var rectContainer: UIView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bgImageView: UIImageView!
    
    weak var delegate: HomeScreenAuthCollectionViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBAction func loginAction(_ sender: Any) {
        guard let delegate = self.delegate else {
            return
        }
        delegate.loginTapped()
    }
    
    func configure(type: ContentType, delegateOwner: UIViewController) {
        self.delegate = delegateOwner as? HomeScreenAuthCollectionViewCellDelegate
        style(contentType: type)
    }
    
    private func style(contentType: ContentType) {
        style(button: loginButton, style: .Fill, title: contentType.buttonText, image: nil, bold: true)
        titleLabel.font = UIFont.bcSansBoldWithSize(size: 17)
        titleLabel.textColor = AppColours.appBlue
        subtitleLabel.font = UIFont.systemFont(ofSize: 13)
        subtitleLabel.text = contentType.subtitleText
        titleLabel.text = contentType.titleText
        rectContainer.backgroundColor = AppColours.backgroundGray
        rectContainer.layer.cornerRadius = 4
        bgImageView.isHidden = contentType == .LoginExpired
        
    }

}

extension HomeScreenAuthCollectionViewCell {
    enum ContentType {
        case Unauthenticated
        case LoginExpired
        
        var buttonText: String {
            switch self {
            case .Unauthenticated:
                return "Get started"
            case .LoginExpired:
                return "Log in with BC Services Card"
            }
        }
        
        var titleText: String {
            switch self {
            case .Unauthenticated:
                return "Log in with BC Service Card"
            case .LoginExpired:
                return "Your session has timed out"
            }
        }
        
        var subtitleText: String {
            switch self {
            case .Unauthenticated:
                return "Gain full access to health records for you and your family."
            case .LoginExpired:
                return "Log in again to access to your health records."
            }
        }
    }
}
