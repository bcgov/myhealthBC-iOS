//
//  HiddenRecordsTableViewCell.swift
//  BCVaccineCard
//
//  Created by Amir on 2022-02-07.
//

import UIKit

enum HiddenRecordType: Equatable {
    case loginToAccess(hiddenRecords: Int)
    case medicalRecords
    case authenticate
    
    var getButtonImage: UIImage? {
        switch self {
        case .loginToAccess, .authenticate: return nil
        case .medicalRecords: return UIImage(named: "lock-icon-new") // TODO: Check that this is working
        }
    }
    
    var getButtonTitle: String {
        switch self {
        case .loginToAccess, .authenticate: return .bcscLogin
        case .medicalRecords: return "Unlock records"
        }
    }
    
    var getTitleText: String {
        switch self {
        case .loginToAccess(_): return "Your session has timed out"
        case .medicalRecords: return "Medication history"
        case .authenticate: return "Manage your records"
        }
    }
    
    var getDescriptionText: String {
        switch self {
        case .loginToAccess: return "Log in again to view your health records"
        case .medicalRecords: return "Some of your health records are locked. You need to enter your protective word to unlock them."
        case .authenticate: return "Log in with your BC Services Card to view your health records"
        }
    }
}

//protocol

class HiddenRecordsTableViewCell: UITableViewCell, Theme {

    @IBOutlet weak var numberOfHiddenRecordsLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var backgroundContainer: UIView!
    
    private var hiddenType: HiddenRecordType?
    var completionHandler: ((HiddenRecordType?)->Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func actionButtonTapped(_ sender: Any) {
        guard let completionHandler = completionHandler else {
            return
        }
        completionHandler(self.hiddenType)
    }
    
    func configure(forRecordType type: HiddenRecordType, onAction: @escaping(HiddenRecordType?)->Void) {
        numberOfHiddenRecordsLabel.text = type.getTitleText
        descLabel.text = type.getDescriptionText
        completionHandler = onAction
        style(forRecordType: type)
    }
    
    private func style(forRecordType type: HiddenRecordType) {
        self.hiddenType = type
        style(label: numberOfHiddenRecordsLabel, style: .Bold, size: 17, colour: .Blue)
        style(label: descLabel, style: .Regular, size: 13, colour: .Black)
        style(button: actionButton, style: .Fill, title: type.getButtonTitle, image: type.getButtonImage, bold: true)
        // TODO: put in AppColours
        backgroundContainer.backgroundColor = UIColor(red: 0.969, green: 0.969, blue: 0.969, alpha: 1)
        backgroundContainer.layer.cornerRadius = 4
    }
    
}
