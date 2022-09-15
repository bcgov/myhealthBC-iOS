//
//  CommunicationMessageUIViewController.swift
//  HealthGatewayTest
//
//  Created by Amir Shayegh on 2022-09-15.
//

import Foundation
import UIKit


class CommunicationMessageUIViewController: UIViewController {

    var text: NSAttributedString? = nil
    var titleString: String = ""
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = .white
        
        let textView = UITextView()
        
        view.addSubview(textView)
        textView.addEqualSizeContraints(to: view, paddingVertical: 16, paddingHorizontal: 16)
        
        textView.attributedText = text
        textView.font = UIFont.bcSansRegularWithSize(size: 13)
        textView.backgroundColor = .clear
        textView.isEditable = false
        
        title = titleString
        navigationController?.navigationBar.prefersLargeTitles = false
    }
}
