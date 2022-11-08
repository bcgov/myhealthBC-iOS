//
//  DependentInfoViewController.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2022-11-01.
//

import UIKit

class DependentInfoViewController: BaseDependentViewController {
    
    class func construct(dependent: Dependent?) -> DependentInfoViewController {
        if let vc = Storyboard.dependents.instantiateViewController(withIdentifier: String(describing: DependentInfoViewController.self)) as? DependentInfoViewController {
            vc.dependent = dependent
            return vc
        }
        return DependentInfoViewController()
    }
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var lastNameLabel: UILabel!
    @IBOutlet weak var firstNameValueLabel: UILabel!
    @IBOutlet weak var lastNameValueLabel: UILabel!
    @IBOutlet weak var phnLabel: UILabel!
    @IBOutlet weak var phnValueLabel: UILabel!
    @IBOutlet weak var dobLabel: UILabel!
    @IBOutlet weak var dobValueLabel: UILabel!
    
    @IBOutlet weak var removeButton: UIButton!
    
    @IBOutlet weak var divider1: UIView!
    @IBOutlet weak var divider2: UIView!
    @IBOutlet weak var divider3: UIView!
    @IBOutlet weak var divider4: UIView!
    
    var dividers: [UIView] {
        return [divider1, divider2, divider3, divider4]
    }
    
    var headers: [UILabel] {
        return [firstNameLabel, lastNameLabel, phnLabel, dobLabel]
    }
    
    var fields: [UILabel] {
        return [firstNameValueLabel, lastNameValueLabel, phnValueLabel, dobValueLabel]
    }
    
    private var dependent: Dependent? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        navSetup()
        setData()
        style()
    }
    
    @IBAction func removeDependent(_ sender: Any) {
        guard let dependent = self.dependent else {return}
        delete(dependent: dependent) { [weak self] confirmed in
            guard confirmed else {return}
            self?.popBack(toControllerType: DependentsHomeViewController.self)
        }
    }
    
    func setData() {
        guard let dependent = dependent, let info = dependent.info else {
            return
        }
        name.text = info.name
        firstNameValueLabel.text = info.firstName
        lastNameValueLabel.text = info.lastName
        phnValueLabel.text = info.phn
        dobValueLabel.text = info.birthday?.yearMonthStringDayString
    }
    
    func style() {
        icon.image = UIImage(named: "dependent-icon")
        name.textColor = AppColours.appBlue
        name.font = UIFont.bcSansBoldWithSize(size: 17)
        
        headers.forEach { label in
            label.textColor = AppColours.darkGreyText
            label.font = UIFont.bcSansRegularWithSize(size: 14)
        }
        
        fields.forEach { label in
            label.textColor = AppColours.darkGreyText
            label.font = UIFont.bcSansRegularWithSize(size: 17)
        }
        
        dividers.forEach { divider in
            divider.backgroundColor = AppColours.divider
        }
        style(button: removeButton, style: .Fill, title: "Remove Dependent", image: nil)
    }

}
extension DependentInfoViewController {
    private func navSetup() {
        self.navDelegate?.setNavigationBarWith(title: .settings,
                                               leftNavButton: nil,
                                               rightNavButton: nil,
                                               navStyle: .small,
                                               navTitleSmallAlignment: .Center,
                                               targetVC: self,
                                               backButtonHintString: nil)
    }
}

