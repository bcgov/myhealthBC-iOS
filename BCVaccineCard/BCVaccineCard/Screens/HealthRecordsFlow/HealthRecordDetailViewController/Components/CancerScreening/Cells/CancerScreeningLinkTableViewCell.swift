//
//  CancerScreeningLinkTableViewCell.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2024-01-26.
//

import UIKit

protocol CancerScreeningLinkTableViewCellDelegate: AnyObject {
    func linkTapped(urlString: String)
}

class CancerScreeningLinkTableViewCell: UITableViewCell {
    
    @IBOutlet weak private var linkButton: UIButton!
    @IBOutlet weak private var linkImageView: UIImageView!
    
    weak private var delegate: CancerScreeningLinkTableViewCellDelegate?
    private var urlString: String?

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    private func configureButtonAttr() -> [NSAttributedString.Key: Any] {
        let attr: [NSAttributedString.Key: Any] = [
            .font: UIFont.bcSansBoldWithSize(size: 15),
            .foregroundColor: AppColours.appBlue,
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .underlineColor: AppColours.appBlue
        ]
        return attr
    }
    
    func configure(text: String, urlString: String, delegateOwner: UIViewController) {
        let attrString = NSMutableAttributedString(string: text, attributes: configureButtonAttr())
        linkButton.setAttributedTitle(attrString, for: .normal)
        self.urlString = urlString
        self.delegate = delegateOwner as? CancerScreeningLinkTableViewCellDelegate
    }
    
    @IBAction private func linkTapped(_ sender: UIButton) {
        guard let string = self.urlString else { return }
        self.delegate?.linkTapped(urlString: string)
    }
    
}
