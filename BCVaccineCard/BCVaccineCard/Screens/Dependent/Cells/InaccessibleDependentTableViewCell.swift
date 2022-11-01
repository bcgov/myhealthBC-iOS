//
//  InaccessibleDependentTableViewCell.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2022-11-01.
//

import UIKit

protocol InaccessibleDependentDelegate {
    func delete(dependent: Dependent)
}
class InaccessibleDependentTableViewCell: UITableViewCell, Theme {

    @IBOutlet weak var dependentNameLabel: UILabel!
    @IBOutlet weak var dependentIcon: UIImageView!
    
    @IBOutlet weak var cellContainer: UIView!
    @IBOutlet weak var warningContainer: UIView!
    @IBOutlet weak var warningLabel: UILabel!
    @IBOutlet weak var waringIcon: UIImageView!
    @IBOutlet weak var removeButton: UIButton!
    
    var dependent: Dependent? = nil
    var delegate: InaccessibleDependentDelegate? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    @IBAction func removeAction(_ sender: Any) {
        guard let dependent = dependent, let delegate = delegate else {return}
        delegate.delete(dependent: dependent)
    }
    
    func configure(dependent: Dependent, delegate: InaccessibleDependentDelegate) {
        self.dependent = dependent
        self.delegate = delegate
        dependentNameLabel.text = dependent.info?.name
        style()
    }
    
    func style() {
        dependentIcon.image = UIImage(named: "dependent-icon")
        waringIcon.image = UIImage(named: "warn")
        dependentNameLabel.textColor = AppColours.appBlue
        warningContainer.backgroundColor = Constants.UI.Toast.WarnColors.backgroundColor
        warningContainer.layer.borderColor = UIColor(red: 0.98, green: 0.922, blue: 0.8, alpha: 1).cgColor
        warningContainer.layer.borderWidth = 1
        warningContainer.layer.cornerRadius = Constants.UI.Theme.cornerRadiusRegular
        warningLabel.textColor = Constants.UI.Toast.WarnColors.labelColor
        warningLabel.font = UIFont.bcSansRegularWithSize(size: 17)
        warningLabel.text = "You no longer have access to this dependent as they have turned 12"
        dependentNameLabel.font = UIFont.bcSansBoldWithSize(size: 17)
        cellContainer.backgroundColor = AppColours.commentBackground
        style(button: removeButton, style: .Hollow, title: "Remove Dependent", image: nil)
        cellContainer.layer.cornerRadius = Constants.UI.Theme.cornerRadiusRegular
        
    }
    
}
