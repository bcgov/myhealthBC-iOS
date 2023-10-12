//
//  FilterRecordsViewController.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2023-05-03.
//
// FIXME: NEED TO LOCALIZE 
import UIKit

class FilterRecordsViewController: BaseViewController {
    
    class func construct(viewModel: ViewModel) -> FilterRecordsViewController {
        if let vc = Storyboard.records.instantiateViewController(withIdentifier: String(describing: FilterRecordsViewController.self)) as? FilterRecordsViewController {
            vc.vm = viewModel
//            vc.currentFilter = currentFilter
//            vc.availableFilters = availableFilters
            vc.delegate = viewModel.delegateOwner as? FilterRecordsViewDelegate
            return vc
        }
        return FilterRecordsViewController()
    }
    
    private var vm: ViewModel?
//    private var currentFilter: RecordsFilter?
//    private var availableFilters: [RecordsFilter.RecordType]?
//    
    weak var delegate: FilterRecordsViewDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        navSetup()
    }
    
    private func setup() {
        let fv: FilterRecordsView = UIView.fromNib()
        let availFilters = vm?.availableFilters ?? RecordsFilter.RecordType.avaiableFilters
        fv.showModally(on: self.view, availableFilters: availFilters, filter: vm?.currentFilter)
        fv.delegate = self
    }
    
    private func navSetup() {
        self.navDelegate?.setNavigationBarWith(title: "Filter",
                                               leftNavButton: nil,
                                               rightNavButton: nil,
                                               navStyle: .small,
                                               navTitleSmallAlignment: .Center,
                                               targetVC: self,
                                               backButtonHintString: nil)
    }

}

extension FilterRecordsViewController: FilterRecordsViewDelegate {
    func selected(filter: RecordsFilter) {
        delegate?.selected(filter: filter)
    }
    
    func dismiss() {
        self.navigationController?.popViewController(animated: true)
    }
}
