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
}

protocol SegmentedViewDelegate: AnyObject {
    func segmentSelected(type: SegmentType)
}

class SegmentedView: UIView {
    
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var segmentedControl: UISegmentedControl!
    
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
        // TODO: UI Setup here - for now, just do a basic 2 segment setup
    }
    
    func configure(delegateOwner: UIViewController, dataSource: [SegmentType]) {
        self.delegate = delegateOwner as? SegmentedViewDelegate
        self.dataSource = dataSource
        configureSegment(dataSource: dataSource)
    }
    
    private func configureSegment(dataSource: [SegmentType]) {
        segmentedControl.removeAllSegments()
        for (index, segment) in dataSource.enumerated() {
            segmentedControl.insertSegment(withTitle: segment.getTitle, at: index, animated: false)
        }
        
    }
    
}

// TODO: https://stackoverflow.com/questions/42755590/how-to-display-only-bottom-border-for-selected-item-in-uisegmentedcontrol
