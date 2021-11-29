//
//  TextListView.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-11-19.
// https://www.figma.com/file/ga1F6q5Kvi6CD6FLS27fXq/My-Health-BC?node-id=3275%3A42965
// This is just the text component

import UIKit

class TextListView: UIView {
    
    @IBOutlet weak private var contentView: UIView!
    @IBOutlet weak private var baseStackView: UIStackView!
    
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
    }
    
    func configure(data: [TextListModel]) {
        setupAccessibility()
        self.setupStackViews(data: data)
    }
    
    private func setupStackViews(data: [TextListModel]) {
        for listComponent in data {
            let stack = initializeStackView()
            if let header = initializeLabel(textListProperties: listComponent.header) {
                stack.addArrangedSubview(header)
            }
            if let subtext = initializeLabel(textListProperties: listComponent.subtext) {
                stack.addArrangedSubview(subtext)
            }
            self.baseStackView.addArrangedSubview(stack)
        }
    }
    
    private func initializeStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.distribution = .fill
        stackView.spacing = 2
        return stackView
    }
    
    private func initializeLabel(textListProperties: TextListModel.TextProperties?) -> UILabel? {
        guard let properties = textListProperties else { return nil }
        let label = UILabel()
        label.textColor = AppColours.textBlack
        let textSize = properties.fontSize
        label.font = properties.bolded ? UIFont.bcSansBoldWithSize(size: textSize) : UIFont.bcSansRegularWithSize(size: textSize)
        label.text = properties.text
        label.numberOfLines = 0
        return label
    }
    
    // TODO: Setup accessibility
    private func setupAccessibility() {
        self.isAccessibilityElement = true
        let accessibilityLabel = ""
        self.accessibilityLabel = accessibilityLabel
//        let accessibilityValue = expanded ? "\(model.codableModel.name), \(model.codableModel.status.getTitle), \(model.getFormattedIssueDate()), \(AccessibilityLabels.VaccineCardView.qrCodeImage)" : "\(model.codableModel.name), \(model.codableModel.status.getTitle)"
//        self.accessibilityValue = accessibilityValue
        self.accessibilityHint = ""
    }
}
