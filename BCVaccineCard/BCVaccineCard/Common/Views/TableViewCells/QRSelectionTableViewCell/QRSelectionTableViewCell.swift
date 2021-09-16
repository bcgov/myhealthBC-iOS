//
//  QRSelectionTableViewCell.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-09-16.
//

import UIKit

enum QRRetrievalMethod {
    case scanWithCamera, scanWithImage, enterGatewayInfo
    
    var getTitle: String {
        switch self {
        case .scanWithCamera: return "Scan a vaccine card QR code"
        case .scanWithImage: return "Use an image of your QR code"
        case .enterGatewayInfo: return "Enter info to get your card"
        }
    }
    
    var getImage: UIImage {
        switch self {
        case .scanWithCamera: return #imageLiteral(resourceName: "camera")
        case .scanWithImage: return #imageLiteral(resourceName: "arrow-to-top")
        case .enterGatewayInfo: return #imageLiteral(resourceName: "address-card")
        }
    }
}

class QRSelectionTableViewCell: UITableViewCell {
    
    @IBOutlet weak private var roundedView: UIView!
    @IBOutlet weak private var optionTitleLabel: UILabel!
    @IBOutlet weak private var optionImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    private func setup() {
        roundedView.layer.cornerRadius = 4.0
        roundedView.layer.masksToBounds = true
    }
    
    func configure(method: QRRetrievalMethod) {
        optionTitleLabel.text = method.getTitle
        optionImageView.image = method.getImage
    }
    
}
