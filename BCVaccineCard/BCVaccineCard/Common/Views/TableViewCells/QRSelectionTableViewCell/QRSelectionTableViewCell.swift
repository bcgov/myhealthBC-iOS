//
//  QRSelectionTableViewCell.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-09-16.
//

import UIKit

protocol GoToQRRetrievalMethodDelegate: class {
    func goToEnterGateway()
    func goToCameraScan()
    func goToUploadImage()
}

enum QRRetrievalMethod {
    case scanWithCamera, uploadImage, enterGatewayInfo
    
    var getTitle: String {
        switch self {
        case .scanWithCamera: return "Scan a vaccine card QR code"
        case .uploadImage: return "Use an image of your QR code"
        case .enterGatewayInfo: return "Enter info to get your card"
        }
    }
    
    var getImage: UIImage {
        switch self {
        case .scanWithCamera: return #imageLiteral(resourceName: "camera")
        case .uploadImage: return #imageLiteral(resourceName: "arrow-to-top")
        case .enterGatewayInfo: return #imageLiteral(resourceName: "address-card")
        }
    }
    
//    var goToFunction: () {
//        switch self {
//        case .scanWithCamera:
//            scanWithCameraFunc()
//        case .uploadImage:
//            uploadImageFunc()
//        case .enterGatewayInfo:
//            enterGatewayInfoFunc()
//        }
//    }
//        
//    func scanWithCameraFunc() {
//        print("TODO: scan with camera here")
//    }
//    
//    func uploadImageFunc() {
//        print("TODO: upload image func here")
//    }
//    
//    func enterGatewayInfoFunc() {
//        print("TODO: go to form here")
//    }
}

class QRSelectionTableViewCell: UITableViewCell {
    
    @IBOutlet weak private var roundedView: UIView!
    @IBOutlet weak private var optionTitleLabel: UILabel!
    @IBOutlet weak private var optionImageView: UIImageView!
    
    weak var delegate: GoToQRRetrievalMethodDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    private func setup() {
        roundedView.layer.cornerRadius = 4.0
        roundedView.layer.masksToBounds = true
    }
    
    func configure(method: QRRetrievalMethod, delegateOwner owner: UIViewController) {
        delegate = owner as? GoToQRRetrievalMethodDelegate
        optionTitleLabel.text = method.getTitle
        optionImageView.image = method.getImage
    }
    
    func callDelegate(fromMethod method: QRRetrievalMethod) {
        switch method {
        case .scanWithCamera:
            delegate?.goToCameraScan()
        case .uploadImage:
            delegate?.goToUploadImage()
        case .enterGatewayInfo:
            delegate?.goToEnterGateway()
        }
    }
    
}
