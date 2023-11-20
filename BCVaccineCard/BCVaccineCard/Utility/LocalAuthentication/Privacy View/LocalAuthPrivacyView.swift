//
//  LocalAuthPrivacyView.swift
//  BCVaccineCard
//
//  Created by Amir on 2022-02-01.
//

import UIKit

class LocalAuthPrivacyView: UIView, UITextViewDelegate, Theme {

    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
//    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func backButtonAction(_ sender: Any) {
        self.removeFromSuperview()
    }
    
    public func show(over parentView: UIView, foriPad: Bool) {
        // TODO: Adjust programatically here
        self.frame = parentView.bounds
        let transition = CATransition()
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromLeft
        parentView.layer.add(transition, forKey: nil)
        parentView.addSubview(self)
        if foriPad {
            self.center(in: parentView, width: 604, height: 387)
            backButton.setImage(UIImage(named: "close-icon-blue"), for: .normal)
        } else {
            self.addEqualSizeContraints(to: parentView)
        }
        style()
    }
    
    private func style() {
//        textSetup()
        style(label: titleLabel, style: .Bold, size: 17, colour: .Blue)
        self.setupTableView()
//        textView.font = UIFont.bcSansRegularWithSize(size: 17)
//        textView.textColor = AppColours.textBlack
        titleLabel.text = .keepingYourDataSecure
        self.layoutIfNeeded()
    }
    
//    private func textSetup() {
//        let attributedText = NSMutableAttributedString(string: .localAuthPrivacyText)
//        _ = attributedText.setAsLink(textToFind: "here", linkURL: "https://www2.gov.bc.ca/gov/content/governments/government-id/bcservicescardapp/terms-of-use")
//        textView.attributedText = attributedText
//        textView.isEditable = false
//        textView.isUserInteractionEnabled = true
//        textView.delegate = self
//        textView.isEditable = false
//    }
//
//    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
//        UIApplication.shared.open(URL)
//        return false
//    }

}

extension LocalAuthPrivacyView: UITableViewDelegate, UITableViewDataSource {
    private func setupTableView() {
        tableView.register(UINib.init(nibName: DataSecurityTipsTableViewCell.getName, bundle: .main), forCellReuseIdentifier: DataSecurityTipsTableViewCell.getName)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DataSecurityTipsTableViewCell.DataTipType.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: DataSecurityTipsTableViewCell.getName, for: indexPath) as? DataSecurityTipsTableViewCell {
            guard let type = DataSecurityTipsTableViewCell.DataTipType.init(rawValue: indexPath.row) else {return UITableViewCell()}
            cell.configure(type: type)
            return cell
        }
        return UITableViewCell()
    }
}
