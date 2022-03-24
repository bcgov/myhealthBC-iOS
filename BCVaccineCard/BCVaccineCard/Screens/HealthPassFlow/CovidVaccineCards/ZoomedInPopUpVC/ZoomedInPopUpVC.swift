//
//  ZoomedInPopUpVC.swift
//  ClientVaxPass-POC
//
//  Created by Connor Ogilvie on 2021-09-10.
//

import UIKit

protocol ZoomedInPopUpVCDelegate: AnyObject {
    func closeButtonTapped()
}

class ZoomedInPopUpVC: UIViewController {
    
    class func constructZoomedInPopUpVC(withQRImage image: UIImage?, parentVC: UIViewController?, delegateOwner: UIViewController) -> ZoomedInPopUpVC {
        if let vc = Storyboard.healthPass.instantiateViewController(withIdentifier: String(describing: ZoomedInPopUpVC.self)) as? ZoomedInPopUpVC {
            vc.image = image
            vc.modalPresentationStyle = .overCurrentContext
            vc.parentVC = parentVC
            vc.delegate = delegateOwner as? ZoomedInPopUpVCDelegate
            return vc
        }
        return ZoomedInPopUpVC()
    }
    private let coverTag = 419231
    @IBOutlet weak var zoomedInView: VaxQRZoomedInView!
    private var image: UIImage?
    private var parentVC: UIViewController?
    private weak var delegate: ZoomedInPopUpVCDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        view.layoutIfNeeded()
    }
    
    func setup() {
        view.isOpaque = false
        view.backgroundColor = .clear
        zoomedInView.configure(qrImage: self.image, closeButtonDelegateOwner: self)
        if let parentVC = parentVC {
            let cover = UIView(frame: .zero)
            cover.tag = coverTag
            // TODO: put in AppColours
            cover.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)
            parentVC.view.addSubview(cover)
            cover.alpha = 0
            cover.addEqualSizeContraints(to: parentVC.view)
            parentVC.view.layoutIfNeeded()
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn) {
                cover.alpha = 1
                parentVC.view.layoutIfNeeded()
            }
        }
    }

}

extension ZoomedInPopUpVC: AppStyleButtonDelegate {
    func buttonTapped(type: AppStyleButton.ButtonType) {
        
        if type == .close {
            if let parentVC = parentVC, let cover = parentVC.view.viewWithTag(coverTag) {
                cover.removeFromSuperview()
            }
            delegate?.closeButtonTapped()
            self.dismiss(animated: true, completion: nil)
        }
    }

}
