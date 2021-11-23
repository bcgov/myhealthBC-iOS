//
//  TextListView.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-11-19.
// https://www.figma.com/file/ga1F6q5Kvi6CD6FLS27fXq/My-Health-BC?node-id=3275%3A42965
// This is just the text component

import UIKit

class TextListView: UIView {
    
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
        Bundle.main.loadNibNamed(TextListView.getName, owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        setup()
    }
    
    private func setup() {
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        uiSetup()
    }
    
    private func uiSetup() {
        
    }
    
    func configure() {
        setupAccessibility()
        // TODO: Fill in here
    }
    
    private func setupAccessibility() {
        self.isAccessibilityElement = true
        let accessibilityLabel = ""
        self.accessibilityLabel = accessibilityLabel
//        let accessibilityValue = expanded ? "\(model.codableModel.name), \(model.codableModel.status.getTitle), \(model.getFormattedIssueDate()), \(AccessibilityLabels.VaccineCardView.qrCodeImage)" : "\(model.codableModel.name), \(model.codableModel.status.getTitle)"
//        self.accessibilityValue = accessibilityValue
        self.accessibilityHint = ""
    }
}
