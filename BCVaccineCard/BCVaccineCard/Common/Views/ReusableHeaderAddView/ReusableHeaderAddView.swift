//
//  ReusableHeaderAddView.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-11-29.
// Note: This is for the view with text beside it, along with an add icon

import UIKit

protocol AddCardsTableViewCellDelegate: AnyObject {
    func addCardButtonTapped(screenType: ReusableHeaderAddView.ScreenType)
}

class ReusableHeaderAddView: UIView {
    
    enum ScreenType {
        case healthPass
        case healthRecords
    }
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var boldTextLabel: UILabel!
    @IBOutlet weak var subtextLabel: UILabel!
    @IBOutlet weak var addCardButton: UIButton!
    
    weak private var delegate: AddCardsTableViewCellDelegate?
    private var screenType: ScreenType!
    
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
        Bundle.main.loadNibNamed(ReusableHeaderAddView.getName, owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        setup()
    }
    
    private func setup() {
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        labelSetup()
    }
    
    private func labelSetup() {
        boldTextLabel.font = UIFont.boldSystemFont(ofSize: 17)
        boldTextLabel.text = .bcVaccinePass
        boldTextLabel.textColor = .black
        subtextLabel.font = UIFont.bcSansRegularWithSize(size: 13)
        subtextLabel.textColor = AppColours.textGray
        addCardButton.accessibilityLabel = AccessibilityLabels.AddCard.addCardLabel
        addCardButton.accessibilityHint = AccessibilityLabels.AddCard.addCardHint
    }
    
    @IBAction func addCardButtonTapped(_ sender: UIButton) {
        delegate?.addCardButtonTapped(screenType: self.screenType)
    }
    
    // NOTE: For now, have two different config methods (in which case, we wouldn't need the screen type property - leaving for now as I'll likely be making just one config function once designs are finalized
    func configureForHealthPass(savedCards: Int?, delegateOwner: UIViewController) {
        self.screenType = .healthPass
        setupAccessibility()
        if let savedCards = savedCards, savedCards > 1 {
            subtextLabel.isHidden = false
            subtextLabel.text = .passCount(count: "\(savedCards)")
        } else {
            subtextLabel.isHidden = true
        }
        self.delegate = delegateOwner as? AddCardsTableViewCellDelegate
    }
    
    func configureForHealthRecords(delegateOwner: UIViewController) {
        self.screenType = .healthRecords
        subtextLabel.isHidden = true
        setupAccessibility()
        self.delegate = delegateOwner as? AddCardsTableViewCellDelegate
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
