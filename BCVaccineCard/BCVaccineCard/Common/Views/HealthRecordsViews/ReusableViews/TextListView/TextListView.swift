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
    private var listOfStacks: [UIStackView]?
    
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
        self.setupStackViews(data: data)
    }
    
    private func setupStackViews(data: [TextListModel]) {
        removeOldStacks()
        listOfStacks = []
        for listComponent in data {
            let stack = initializeStackView()
            if let header = initializeLabel(textListProperties: listComponent.header) {
                stack.addArrangedSubview(header)
            }
            if let subtext = initializeLabel(textListProperties: listComponent.subtext) {
                stack.addArrangedSubview(subtext)
            }
            self.setupAccessibility(stack: stack, listComponent: listComponent)
            self.baseStackView.addArrangedSubview(stack)
            self.listOfStacks?.append(stack)
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
    
    private func initializeLabel(textListProperties: TextProperties?) -> UILabel? {
        guard let properties = textListProperties else { return nil }
        if let links = properties.links, !links.isEmpty {
            let label = InteractiveLinkLabel()
            let textSize = properties.fontSize
            let font = properties.bolded ? UIFont.bcSansBoldWithSize(size: textSize) : UIFont.bcSansRegularWithSize(size: textSize)
            label.attributedText = label.attributedText(withString: properties.text, linkedStrings: links, textColor: textListProperties?.textColor.getUIColor ?? AppColours.textBlack, font: font)
            label.numberOfLines = 0
            return label
        } else {
            let label = UILabel()
            label.textColor = textListProperties?.textColor.getUIColor ?? AppColours.textBlack
            let textSize = properties.fontSize
            label.font = properties.bolded ? UIFont.bcSansBoldWithSize(size: textSize) : UIFont.bcSansRegularWithSize(size: textSize)
            label.text = properties.text
            label.numberOfLines = 0
            return label
        }
    }
    
    private func removeOldStacks() {
        guard let listOfStacks = listOfStacks else { return }
        for stack in listOfStacks {
            stack.removeFromSuperview()
        }
    }
    
    // TODO: Setup accessibility
    private func setupAccessibility(stack: UIStackView, listComponent: TextListModel) {
        stack.isAccessibilityElement = true
        stack.accessibilityLabel = listComponent.header.text
        stack.accessibilityValue = listComponent.subtext?.text
    }
}
