//
//  VaccinePassportVC.swift
//  ClientVaxPass-POC
//
//  Created by Connor Ogilvie on 2021-09-09.
//

import UIKit

enum VaccineStatus: String, Codable {
    case fully = "fully", partially, notVaxed
    
    var getTitle: String {
        switch self {
        case .fully: return "VACCINATED"
        case .partially: return "PARTIALLY VACCINATED"
        case .notVaxed: return "NO RECORD FOUND"
        }
    }
    
    var getColor: UIColor {
        switch self {
        case .fully: return AppColours.vaccinatedGreen
        case .partially: return AppColours.partiallyVaxedBlue
        case .notVaxed: return .darkGray //Note: If this gets used, we will need to change the color to the actual grey
        }
    }
}

protocol GoToCardsDelegate: AnyObject {
    func goToCardsTab()
}

class VaccinePassportVC: UIViewController {
    
    class func constructVaccinePassportVC(withModel vaccinePassportModel: VaccinePassportModel, delegateOwner: UIViewController?) -> VaccinePassportVC {
        if let vc = Storyboard.main.instantiateViewController(withIdentifier: "VaccinePassportVC") as? VaccinePassportVC {
            vc.vaccinePassportModel = vaccinePassportModel
            vc.delegate = delegateOwner as? GoToCardsDelegate
            return vc
        }
        return VaccinePassportVC()
    }
    
    @IBOutlet weak var headerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var roundedContainerView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var checkmarkImageView: UIImageView!
    @IBOutlet weak var vaccineStatusLabel: UILabel!
    @IBOutlet weak var issuedOnLabel: UILabel!
    @IBOutlet weak var qrCodeImage: UIImageView!
    // NOTE: This is currently disabled - can likely just be a label. Transparent button overlay over whole statusBackgroundView acting as the 'tap to zoom'
    @IBOutlet weak var tapToZoomButton: UIButton!
    @IBOutlet weak var tapToZoomInFingerImage: UIImageView!
    @IBOutlet weak var transparentTapToZoomButton: UIButton!
    @IBOutlet weak var statusBackgroundView: UIView!
    @IBOutlet weak var doneButton: AppStyleButton!
    @IBOutlet weak var saveACopyButton: AppStyleButton!
    
    private var vaccinePassportModel: VaccinePassportModel!
    weak var delegate: GoToCardsDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        self.scrollView.layoutSubviews()
    }
    
    func setup() {
        setupUI()
        configureProperties()
        setupButtons()
        disablePropertiesForNoPassport()
    }
    
    func setupUI() {
        roundedContainerView.layer.cornerRadius = 5
        roundedContainerView.layer.masksToBounds = true
        checkmarkImageView.tintColor = .white // Not working
        tapToZoomInFingerImage.tintColor = .white // Not working
    }
    
    func configureProperties() {
        nameLabel.text = self.vaccinePassportModel.name
        checkmarkImageView.isHidden = self.vaccinePassportModel.status != .fully
        vaccineStatusLabel.text = self.vaccinePassportModel.status.getTitle
        statusBackgroundView.backgroundColor = self.vaccinePassportModel.status.getColor
        qrCodeImage.image = UIImage(named: vaccinePassportModel.imageName)
    }
    
    func disablePropertiesForNoPassport() {
        if self.vaccinePassportModel.status == .notVaxed {
            tapToZoomInFingerImage.isHidden = true
            tapToZoomButton.isHidden = true
            transparentTapToZoomButton.isUserInteractionEnabled = false
        }
    }
    
    private func setupButtons() {
        doneButton.configure(withStyle: .white, buttonType: .done, delegateOwner: self, enabled: true)
        let enabled = self.vaccinePassportModel.status == .fully || self.vaccinePassportModel.status == .partially
        saveACopyButton.configure(withStyle: .blue, buttonType: .saveACopy, delegateOwner: self, enabled: enabled)
    }
    
    @IBAction func tapToZoomTapped(_ sender: UIButton) {
        let vc = ZoomedInPopUpVC.constructZoomedInPopUpVC(withQRImage: qrCodeImage.image)
        self.present(vc, animated: true, completion: nil)
    }

}

extension VaccinePassportVC: AppStyleButtonDelegate {
    func buttonTapped(type: AppStyleButton.ButtonType) {
        if type == .done {
            self.dismiss(animated: true, completion: nil)
        } else if type == .saveACopy {
            if let ds = Defaults.vaccinePassports {
                guard ds.firstIndex(of: self.vaccinePassportModel) == nil else {
                    presentAlertWith(title: "Oops", message: "Looks like you've already added this vaccine card to your list of vaccine cards. Go to the 'Cards' tab to view it.", actionOneTitle: "OK", actionOneCompletionHandler: { _ in
                        self.dismiss(animated: true, completion: nil)

                    }, actionTwoTitle: nil, actionTwoCompletionHandler: nil)
                    return
                }
                Defaults.vaccinePassports?.append(self.vaccinePassportModel)
                showSuccessAlert()
            } else {
                Defaults.vaccinePassports = []
                Defaults.vaccinePassports?.append(self.vaccinePassportModel)
                showSuccessAlert()
            }
        }
    }
    
    func showSuccessAlert() {
        self.presentAlertWith(title: "Success", message: "Congratulations! You have added your vaccine card to your list of vaccine cards. If you would like to see your list of vaccine cards, tap 'See My Cards'.\n Otherwise, tap 'OK' to dismiss.", actionOneTitle: "OK", actionOneCompletionHandler: { _ in
            self.dismiss(animated: true, completion: nil)
        }, actionTwoTitle: "See My Cards") { _ in
            self.dismiss(animated: true) {
                self.delegate?.goToCardsTab()
            }
        }
    }

}

// MARK: Alert vc logic for save card functionality
extension VaccinePassportVC {
    
    func presentAlertWith(title: String, message: String, actionOneTitle: String, actionOneCompletionHandler: ((UIAlertAction) -> Void)?, actionTwoTitle: String?, actionTwoCompletionHandler: ((UIAlertAction) -> Void)?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: actionOneTitle, style: .default, handler: actionOneCompletionHandler))
        if actionTwoTitle != nil {
            alert.addAction(UIAlertAction(title: actionTwoTitle, style: .default, handler: actionTwoCompletionHandler))
        }
        self.present(alert, animated: true, completion: nil)
    }
}
