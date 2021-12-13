//
//  VaccineCardTableViewCell.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-09-15.
//

import UIKit
import BCVaccineValidator
import SwipeCellKit

fileprivate class VaccineCardTableViewCellCache {
    static var validationResults: [String: CodeValidationResult] = [String: CodeValidationResult]()
    
    static func fromCache(code: String) -> CodeValidationResult? {
        return validationResults[code]
    }
    
    static func cache(code: String, result: CodeValidationResult) {
        validationResults[code] = result
    }
}

class VaccineCardTableViewCell: SwipeTableViewCell {
    
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var roundedView: UIView!
    @IBOutlet weak var vaccineCardView: VaccineCardView!
    @IBOutlet weak var federalPassView: FederalPassView!
    @IBOutlet weak var federalPassViewHeightConstraint: NSLayoutConstraint!
    
    private var code: String = ""
    private var model: AppVaccinePassportModel? = nil

    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }

    private func setup() {
        viewSetup()
        self.selectionStyle = .none
    }
    
    private func viewSetup() {
        shadowView.backgroundColor = UIColor.clear
        shadowView.layer.shadowColor = UIColor.black.cgColor
        shadowView.layer.shadowOffset = CGSize(width: 2, height: 2)
        shadowView.layer.shadowRadius = 6.0
        
        roundedView.layer.cornerRadius = 3
        roundedView.layer.masksToBounds = true
    }
    
    private func adjustShadow(expanded: Bool) {
        shadowView.layer.shadowOpacity = expanded ? 0.7 : 0.0
    }
    
    func configure(model: VaccineCard, expanded: Bool, editMode: Bool, delegateOwner: UIViewController) {
        guard let vaxCode = model.code else {return}
        adjustExpansion(expanded: expanded)
        if let current = self.model, current.codableModel.code == vaxCode && current.codableModel.fedCode == model.federalPass {
            config(model: current, expanded: expanded, editMode: editMode, delegateOwner: delegateOwner)
            return
        }
        self.code = vaxCode
       
        validateCode(code: vaxCode) { [weak self] result in
            guard let `self` = self, self.code == vaxCode else {return}
            if let localModel = result.toLocal(federalPass: model.federalPass, phn: model.phn) {
                self.config(model: localModel.transform(), expanded: expanded, editMode: editMode, delegateOwner: delegateOwner)
            }
        }
    }
    
    private func validateCode(code: String, completion: @escaping (CodeValidationResult)->Void) {
        if let cached = VaccineCardTableViewCellCache.fromCache(code: code.lowercased()) {
            return completion(cached)
        }
        self.contentView.startLoadingIndicator(backgroundColor: .white)
        BCVaccineValidator.shared.validate(code: code.lowercased()) { [weak self] result in
            VaccineCardTableViewCellCache.cache(code: code, result: result)
            guard let `self` = self else {return}
            DispatchQueue.main.async {[weak self] in
                guard let `self` = self else {return}
                self.contentView.endLoadingIndicator()
                return completion(result)
            }
        }
    }
    
    private func config(model: AppVaccinePassportModel, expanded: Bool, editMode: Bool, delegateOwner: UIViewController) {
        self.model = model
        vaccineCardView.configure(model: model, expanded: expanded, editMode: editMode)
        adjustExpansion(expanded: expanded)
        if expanded {
            federalPassView.configure(model: model, delegateOwner: delegateOwner)
        }
        adjustShadow(expanded: expanded)
        self.layoutIfNeeded()
    }
    
    private func adjustExpansion(expanded: Bool) {
        vaccineCardView.expandableBackgroundView.isHidden = !expanded
        federalPassView.isHidden = !expanded
        federalPassViewHeightConstraint.constant = expanded ? 94.0 : 0.0
    }

}
