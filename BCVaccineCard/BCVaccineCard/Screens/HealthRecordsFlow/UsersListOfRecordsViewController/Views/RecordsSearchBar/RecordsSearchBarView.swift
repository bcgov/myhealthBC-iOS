//
//  RecordsSearchBarView.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2023-04-19.
//

import UIKit

protocol RecordsSearchBarViewDelegate: AnyObject {
    func searchButtonTapped(text: String)
    func textDidChange(text: String)
}

class RecordsSearchBarView: UIView {
    
    @IBOutlet weak private var contentView: UIView!
    @IBOutlet weak private var searchBar: UISearchBar!
    @IBOutlet weak private var searchBarSeparatorView: UIView!
    @IBOutlet weak private var filterButton: UIButton!
    
    weak var delegate: RecordsSearchBarViewDelegate?
    
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
        Bundle.main.loadNibNamed(RecordsSearchBarView.getName, owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        setup()
    }
    
    private func setup() {
        self.backgroundColor = .clear
        uiSetup()
        searchBar.delegate = self
    }
    
    private func uiSetup() {
        
    }
    
    @IBAction private func searchButtonTapped(_ sender: Any) {
        
    }
    
    @IBAction private func filterButtonTapped(_ sender: Any) {
        
    }
    
    func configure(delegateOwner: UIViewController) {
        
    }

}

extension RecordsSearchBarView: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        <#code#>
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        <#code#>
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        <#code#>
    }
}

