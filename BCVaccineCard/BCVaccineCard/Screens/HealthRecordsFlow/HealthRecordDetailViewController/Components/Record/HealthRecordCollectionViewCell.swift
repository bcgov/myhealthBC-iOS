//
//  HealthRecordCollectionViewCell.swift
//  BCVaccineCard
//
//  Created by Amir on 2021-12-09.
//

import Foundation
import UIKit

class HealthRecordCollectionViewCell: UICollectionViewCell {
    
    private var model: HealthRecordsDetailDataSource.Record?
    private weak var recordView: HealthRecordView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(model: HealthRecordsDetailDataSource.Record) {
        self.model = model
        let recordView: HealthRecordView = HealthRecordView(frame: .zero)
        self.contentView.subviews.forEach({$0.removeFromSuperview()})
        self.contentView.addSubview(recordView)
        recordView.addEqualSizeContraints(to: self.contentView, paddingVertical: 0, paddingHorizontal: 20)
        recordView.configure(model: model)
        self.recordView = recordView
    }
}
