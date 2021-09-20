//
//  ZoomedInPopUpVC.swift
//  ClientVaxPass-POC
//
//  Created by Connor Ogilvie on 2021-09-10.
//

import UIKit

class ZoomedInPopUpVC: UIViewController {
    
    class func constructZoomedInPopUpVC(withQRImage image: UIImage?) -> ZoomedInPopUpVC {
        if let vc = Storyboard.main.instantiateViewController(withIdentifier: String(describing: ZoomedInPopUpVC.self)) as? ZoomedInPopUpVC {
            vc.image = image
            vc.modalPresentationStyle = .overCurrentContext
            return vc
        }
        return ZoomedInPopUpVC()
    }
    
    @IBOutlet weak var zoomedInView: VaxQRZoomedInView!
    private var image: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    func setup() {
        view.isOpaque = false
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)
        zoomedInView.configure(qrImage: self.image, closeButtonDelegateOwner: self)
    }

}

extension ZoomedInPopUpVC: AppStyleButtonDelegate {
    func buttonTapped(type: AppStyleButton.ButtonType) {
        if type == .close {
            self.dismiss(animated: true, completion: nil)
        }
    }

}
