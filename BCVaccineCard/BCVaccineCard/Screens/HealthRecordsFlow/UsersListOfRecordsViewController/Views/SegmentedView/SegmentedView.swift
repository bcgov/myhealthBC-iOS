//
//  SegmentedView.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2023-06-07.
//

import UIKit

enum SegmentType {
    case Timeline
    case Notes
    
    var getTitle: String {
        switch self {
        case .Timeline: return "Timeline"
        case .Notes: return "Notes"
        }
    }
    
    var getIndex: Int {
        switch self {
        case .Timeline: return 0
        case .Notes: return 1
        }
    }
}

protocol SegmentedViewDelegate: AnyObject {
    func segmentSelected(type: SegmentType)
}

class SegmentedView: UIView {
    
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var segmentedControl: UISegmentedControl!
    @IBOutlet private weak var bottomViewSeparator: UIView!
    
    weak var delegate: SegmentedViewDelegate?
    
    var dataSource: [SegmentType] = []
    
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
        Bundle.main.loadNibNamed(SegmentedView.getName, owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        baseSetup()
    }
    
    private func baseSetup() {
        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: AppColours.textGray, NSAttributedString.Key.font: UIFont.bcSansRegularWithSize(size: 15)], for: .normal)
        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: AppColours.appBlue, NSAttributedString.Key.font: UIFont.bcSansBoldWithSize(size: 15)], for: .selected)
        bottomViewSeparator.backgroundColor = AppColours.borderGray
    }
    
    func configure(delegateOwner: UIViewController, dataSource: [SegmentType]) {
        self.delegate = delegateOwner as? SegmentedViewDelegate
        self.dataSource = dataSource
        configureSegment(dataSource: dataSource)
    }
    
    func setSegmentedControl(forType type: SegmentType) {
        segmentedControl.selectedSegmentIndex = type.getIndex
        segmentedControl.changeUnderlinePosition()
    }
    
    private func configureSegment(dataSource: [SegmentType]) {
        segmentedControl.removeAllSegments()
        for (index, segment) in dataSource.enumerated() {
            segmentedControl.insertSegment(withTitle: segment.getTitle, at: index, animated: false)
        }
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addUnderlineForSelectedSegment()
    }
    
    @IBAction private func segmentedControlDidChange(_ sender: UISegmentedControl) {
        segmentedControl.changeUnderlinePosition()
        guard dataSource.count > sender.selectedSegmentIndex else { return }
        let type = dataSource[sender.selectedSegmentIndex]
        delegate?.segmentSelected(type: type)
    }
    
}

