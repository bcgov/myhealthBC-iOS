//
//  PrimaryVaccineCardTableViewCell.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-10-07.
//

import UIKit

protocol PrimaryVaccineCardTableViewCellDelegate: AnyObject {
    func addCardButtonTapped()
    func tapToZoomInButtonTapped()
}

class PrimaryVaccineCardTableViewCell: UITableViewCell {
    
    @IBOutlet weak var boldTextLabel: UILabel!
    @IBOutlet weak var subtextLabel: UILabel!
    @IBOutlet weak var addCardButton: UIButton!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var roundedView: UIView!
    @IBOutlet weak var vaccineCardView: VaccineCardView!
    @IBOutlet weak var tapToZoomButton: UIButton!
    @IBOutlet weak var viewAllButton: AppStyleButton!
    
    weak private var delegate: PrimaryVaccineCardTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    private func setup() {
        labelSetup()
        viewSetup()
    }
    
    private func labelSetup() {
        boldTextLabel.font = UIFont.boldSystemFont(ofSize: 17)
        boldTextLabel.text = .covidVaccineCards
        boldTextLabel.textColor = .black
        subtextLabel.font = UIFont.bcSansRegularWithSize(size: 13)
        subtextLabel.textColor = AppColours.textGray
        if #available(iOS 15.0, *) {
            addCardButton.configuration?.title = nil
            tapToZoomButton.configuration?.title = nil
        } else {
            addCardButton.setTitle(nil, for: .normal)
            tapToZoomButton.setTitle(nil, for: .normal)
        }
    }
    
    private func viewSetup() {
        shadowView.backgroundColor = UIColor.clear
        shadowView.layer.shadowColor = UIColor.black.cgColor
        shadowView.layer.shadowOffset = CGSize(width: 2, height: 2)
        shadowView.layer.shadowRadius = 6.0
        
        roundedView.layer.cornerRadius = 3
        roundedView.layer.masksToBounds = true
    }

    @IBAction func addCardButtonTapped(_ sender: UIButton) {
        delegate?.addCardButtonTapped()
    }
    
    @IBAction func tapToZoomInButtonTapped(_ sender: UIButton) {
        delegate?.tapToZoomInButtonTapped()
    }
    
    func configure(card: AppVaccinePassportModel, delegateOwner: UIViewController, hideViewAllButton: Bool) {
        // FIXME: Need to start tracking when we saved the card - also, will need to adjust localized logic like we did in espri (1 day vs 2 days). Finally, need to iron out the data shown by this label - "3 passes . Added 2 days ago". What exactly was added 2 days ago, most recent?
        subtextLabel.text = .addedDate(days: "2")
        vaccineCardView.configure(model: card, expanded: true, editMode: false)
        self.delegate = delegateOwner as? PrimaryVaccineCardTableViewCellDelegate
        guard !hideViewAllButton else {
            viewAllButton.isHidden = true
            return
        }
        viewAllButton.configure(withStyle: .white, buttonType: .viewAll, delegateOwner: delegateOwner, enabled: true, accessibilityValue: "View All", accessibilityHint: "Tapping this button will show you all of your saved covid 19 vaccine cards")
    }
    
    
}

