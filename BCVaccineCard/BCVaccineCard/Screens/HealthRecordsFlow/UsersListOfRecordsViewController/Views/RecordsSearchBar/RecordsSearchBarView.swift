//
//  RecordsSearchBarView.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2023-04-19.
//

import UIKit

protocol RecordsSearchBarViewDelegate: AnyObject {
    func searchButtonTapped(text: String)
    func textDidChange(text: String?)
    func filterButtonTapped()
}

class RecordsSearchBarView: UIView {
    
    @IBOutlet weak private var contentView: UIView!
    @IBOutlet weak private var containerView: UIView!
    @IBOutlet weak private var searchBar: UISearchBar!
    @IBOutlet weak private var searchBarSeparatorView: UIView!
    @IBOutlet weak private var filterButton: UIButton!
    
    weak var delegate: RecordsSearchBarViewDelegate?
    
    var hideFilterSection: Bool = false {
        didSet {
            searchBarSeparatorView.isHidden = hideFilterSection
            filterButton.isHidden = hideFilterSection
        }
    }
    
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
        contentView.backgroundColor = .clear
        setup()
    }
    
    private func setup() {
        self.backgroundColor = .clear
        uiSetup()
        searchBar.delegate = self
    }
    
    private func uiSetup() {
        containerView.layer.borderWidth = 1.0
        containerView.layer.borderColor = AppColours.borderGray.cgColor
        containerView.layer.cornerRadius = 4.0
        containerView.clipsToBounds = true
        searchBar.placeholder = "Type here to search..."
        if let textField = searchBar.value(forKey: "searchField") as? UITextField {
            textField.backgroundColor = .white
//            textField.attributedPlaceholder = NSAttributedString(string: "Type here to search...", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
        }
//        , NSAttributedString.Key.font: UIFont.bcSansRegularWithSize(size: 14)
        searchBar.backgroundImage = UIImage()
    }
    
    @IBAction private func filterButtonTapped(_ sender: Any) {
        delegate?.filterButtonTapped()
    }
    
    func configure(delegateOwner: UIViewController) {
        delegate = delegateOwner as? RecordsSearchBarViewDelegate
    }

}

extension RecordsSearchBarView: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("CONNOR: TextDidChange")
        delegate?.textDidChange(text: searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("CONNOR: searchBarSearchButtonClicks")
        guard let text = searchBar.text else { return }
        delegate?.searchButtonTapped(text: text)
    }
}

