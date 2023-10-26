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
    private var delegate: HealthRecordDetailDelegate?
    private weak var recordView: BaseHealthRecordsDetailView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(model: HealthRecordsDetailDataSource.Record, delegate: HealthRecordDetailDelegate) {
        self.delegate = delegate
        self.model = model
        self.recordView?.removeFromSuperview()
        let recordView: BaseHealthRecordsDetailView
        switch model.type {
        case .covidImmunizationRecord:
            recordView = CovidImmunizationRecordDetailView(frame: .zero)
        case .covidTestResultRecord:
            recordView = CovidTestResultRecordDetailView(frame: .zero)
        case .medication(let model):
            if model.medication?.isPharmacistAssessment == true {
                recordView = PharmacistAssessmentDetailView(frame: .zero)
            } else {
                recordView = MedicationRecordDetailView(frame: .zero)
            }
//        case .pharmacist:
//            recordView = PharmacistAssessmentDetailView(frame: .zero)
        case .laboratoryOrder:
            recordView = LabOrderRecordDetailView(frame: .zero)
        case .immunization:
            recordView = ImmunizationRecordDetailView(frame: .zero)
        case .healthVisit:
            recordView = HealthVisitRecordDetailView(frame: .zero)
        case .specialAuthorityDrug:
            recordView = SpecialAuthorityDrugDetailView(frame: .zero)
        case .hospitalVisit:
            recordView = HospitalVisitRecordDetailView(frame: .zero)
        case .clinicalDocument:
            recordView = ClinicalDocumentRecordDetailView(frame: .zero)
        case .diagnosticImaging:
            recordView = DiagnosticImagingDetailView(frame: .zero)
        case .note:
            // We won't get here
            recordView = BaseHealthRecordsDetailView(frame: .zero)
        }
        self.contentView.subviews.forEach({$0.removeFromSuperview()})
        self.contentView.addSubview(recordView)
        recordView.addEqualSizeContraints(to: self.contentView, paddingVertical: 0, paddingHorizontal: 0)
        recordView.setup(model: model, enableComments: model.commentsEnabled, delegate: delegate)
        self.recordView = recordView
    }
}
