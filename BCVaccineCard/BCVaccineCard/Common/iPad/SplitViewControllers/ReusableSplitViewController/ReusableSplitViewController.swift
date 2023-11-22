//
//  ReusableSplitViewController.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2023-11-21.
//

import UIKit

class ReusableSplitViewController: UISplitViewController {
    
    class func construct(masterVC: UIViewController, secondaryVC: UIViewController?) -> ReusableSplitViewController {
        if let vc =  Storyboard.iPadHome.instantiateViewController(withIdentifier: String(describing: ReusableSplitViewController.self)) as? ReusableSplitViewController {
            vc.masterVC = masterVC
            vc.secondaryVC = secondaryVC
            return vc
        }
        return ReusableSplitViewController()
    }
    
    private var masterVC: UIViewController?
    private var secondaryVC: UIViewController?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
