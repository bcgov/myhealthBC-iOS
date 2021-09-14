//
//  NavigationHeaderView.swift
//  ClientVaxPass-POC
//
//  Created by Connor Ogilvie on 2021-09-09.
//

import UIKit

class NavigationHeaderView: UIView {
    
    @IBOutlet weak var contentView: UIView!
    
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
        Bundle.main.loadNibNamed("NavigationHeaderView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        setup()
    }
    
    private func setup() {
        self.backgroundColor = .clear
    }
}
