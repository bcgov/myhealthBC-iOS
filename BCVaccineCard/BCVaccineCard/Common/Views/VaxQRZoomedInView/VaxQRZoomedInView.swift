//
//  VaxQRZoomedInView.swift
//  ClientVaxPass-POC
//
//  Created by Connor Ogilvie on 2021-09-10.
//

import UIKit

class VaxQRZoomedInView: UIView {
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var presentForScanningLabel: UILabel!
    @IBOutlet weak var closeButton: AppStyleButton!
    @IBOutlet weak var qrCodeZoomedInImageView: UIImageView!
    
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
        Bundle.main.loadNibNamed(VaxQRZoomedInView.getName, owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        setup()
    }
    
    private func setup() {
        self.backgroundColor = .clear
        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = true
        presentForScanningLabel.text = Constants.Strings.MyCardFlow.HasCards.presentForScanning
        presentForScanningLabel.textColor = AppColours.appBlue
        presentForScanningLabel.font = UIFont.bcSansBoldWithSize(size: 20)
    }
    
    func configure(qrImage: UIImage?, closeButtonDelegateOwner: UIViewController) {
        qrCodeZoomedInImageView.image = qrImage
        closeButton.configure(withStyle: .white, buttonType: .close, delegateOwner: closeButtonDelegateOwner, enabled: true)
    }
}
