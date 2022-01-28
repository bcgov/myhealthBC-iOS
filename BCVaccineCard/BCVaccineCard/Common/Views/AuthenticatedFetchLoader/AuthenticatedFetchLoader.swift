//
//  AuthenticatedFetchLoader.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2022-01-27.
//

import UIKit

class AuthenticatedFetchLoader: UIView {
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var loadingContainerBoarderView: UIView!
    @IBOutlet weak var loadingContainerView: UIView!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var loadingViewTrailingConstraint: NSLayoutConstraint! // Max is 1, min (default) will be equal to (width of loadingContainerView - 2)
    @IBOutlet weak var statusLabel: UILabel!
    
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
    
    var getLoaderConstraintAtZero: CGFloat {
        return (loadingContainerView.frame.width - 2)
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed(AuthenticatedFetchLoader.getName, owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        setup()
    }
    
    private func setup() {
        self.backgroundColor = .clear
        contentView.backgroundColor = .white
//        contentView.clipsToBounds = true
//        contentView.layer.cornerRadius = 8
//        contentView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        loadingContainerBoarderView.backgroundColor = AppColours.borderGray
        loadingContainerBoarderView.layer.cornerRadius = loadingContainerBoarderView.frame.height / 2
        loadingContainerBoarderView.layer.masksToBounds = true
        loadingContainerView.backgroundColor = AppColours.backgroundGray
        loadingContainerView.layer.cornerRadius = loadingContainerView.frame.height / 2
        loadingContainerView.layer.masksToBounds = true
        loadingView.backgroundColor = AppColours.appBlue
        loadingView.layer.cornerRadius = loadingView.frame.height / 2
        loadingView.layer.masksToBounds = true
        statusLabel.textColor = AppColours.appBlue
        statusLabel.font = UIFont.bcSansRegularWithSize(size: 12)
        statusLabel.text = "Progress"
        loadingViewTrailingConstraint.constant = self.getLoaderConstraintAtZero
    }
    
    func configure(status: String, loadingProgress: CGFloat?) {
        statusLabel.text = status
        self.layoutIfNeeded()
        guard let loadingProgress = loadingProgress else { return }
        if loadingProgress == 1 {
            print("STARTED ANIMATION")
            UIView.animate(withDuration: 1.3, delay: 0.2, options: .curveEaseIn) {
                self.loadingViewTrailingConstraint.constant = self.calculateTrailingConstraing(progress: loadingProgress)
                self.layoutIfNeeded()
            } completion: { done in
                print("DONE ANIMATION")
            }
        }
        
        
    }
    
    func calculateTrailingConstraing(progress: CGFloat) -> CGFloat {
        guard progress < 1 else { return 1 }
        let available = self.getLoaderConstraintAtZero
        return available * (1 - progress)
    }
}
