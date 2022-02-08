//
//  HiddenRecordsTableViewCell.swift
//  BCVaccineCard
//
//  Created by Amir on 2022-02-07.
//

import UIKit

class HiddenRecordsTableViewCell: UITableViewCell, Theme {

    @IBOutlet weak var numberOfHiddenRecordsLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var backgroundContainer: UIView!
    
    var loginCompletion: (()->Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func loginButtonTapped(_ sender: Any) {
        guard let loginCompletion = loginCompletion else {
            return
        }
        loginCompletion()
    }
    
    func configure(numberOfHiddenRecords: Int, onLogin: @escaping()->Void) {
        numberOfHiddenRecordsLabel.text = "\(numberOfHiddenRecords) hidden records"
        loginCompletion = onLogin
        style()
    }
    
    func style() {
        style(label: numberOfHiddenRecordsLabel, style: .Bold, size: 17, colour: .Blue)
        style(label: descLabel, style: .Regular, size: 13, colour: .Black)
        style(button: loginButton, style: .Fill, title: .bcscLogin, bold: true)
        backgroundContainer.backgroundColor = AppColours.backgroundGray
    }
    
}
