//
//  ShadowCardView.swift
//  ClientVaxPass-POC
//
//  Created by Connor Ogilvie on 2021-09-09.
// NOTE: Not currently using this

import UIKit

class ShadowCardView: UIView {
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var roundedView: UIView!
    
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
        Bundle.main.loadNibNamed("ShadowCardView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        setup()
    }
    
    private func setup() {
        self.backgroundColor = .clear
        contentView.backgroundColor = .clear
        roundedView.backgroundColor = .white
        // shadow
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOffset = CGSize(width: 0, height: 0)
        contentView.layer.shadowOpacity = 0.1
        contentView.layer.shadowRadius = 10.0
        // corner radius
        roundedView.layer.cornerRadius = 5
        roundedView.layer.masksToBounds = true
        
    }
}
