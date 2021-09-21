//
//  QRSelectionTableViewCell.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-09-16.
//

import UIKit

protocol GoToQRRetrievalMethodDelegate: AnyObject {
    func goToEnterGateway()
    func goToCameraScan()
    func goToUploadImage()
}

enum QRRetrievalMethod {
    case scanWithCamera, uploadImage, enterGatewayInfo
    
    var getTitle: String {
        switch self {
        case .scanWithCamera: return Constants.Strings.MyCardFlow.QRMethodSelection.cameraScanOption
        case .uploadImage: return Constants.Strings.MyCardFlow.QRMethodSelection.imageUploadOption
        case .enterGatewayInfo: return Constants.Strings.MyCardFlow.QRMethodSelection.healthGatewayOption
        }
    }
    
    var getImage: UIImage {
        switch self {
        case .scanWithCamera: return #imageLiteral(resourceName: "camera")
        case .uploadImage: return #imageLiteral(resourceName: "arrow-to-top")
        case .enterGatewayInfo: return #imageLiteral(resourceName: "address-card")
        }
    }
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
        optionTitleLabel.font = UIFont.bcSansRegularWithSize(size: 16)
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
