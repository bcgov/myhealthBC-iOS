//
//  CommentTextFieldView.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2022-08-30.
//

import UIKit


protocol CommentTextFieldViewDelegate {
    func textChanged(text: String?)
    func submit(text: String)
}
class CommentTextFieldView: UIView {
    
    @IBOutlet weak var fieldContainer: UIView!
    @IBOutlet weak var leftImageView: UIImageView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    
    var delegate: CommentTextFieldViewDelegate? = nil
    
    @IBAction func textFieldChanged(_ sender: Any) {
        delegate?.textChanged(text: textField.text)
        styleSubmit(enabled: textField.text?.count ?? 0 > 0)
    }
    
    @IBAction func submitAction(_ sender: Any) {
        print("tapped")
        guard let text = textField.text, text.count > 0 else {return}
        delegate?.submit(text: text)
    }
    
    func setup() {
        style()
    }
    
    private func styleSubmit(enabled: Bool) {
        let img = enabled ? UIImage(named: "submit-active" ) : UIImage(named: "submit-inactive")
        submitButton.setImage(img, for: .normal)
    }
    
    private func style() {
        guard fieldContainer != nil else { return }
        backgroundColor = .white
        fieldContainer.backgroundColor = AppColours.backgroundGray
        fieldContainer.layer.cornerRadius = 4
        textField.backgroundColor = .clear
        textField.borderStyle = .none
        textField.placeholder = "Comment here"
        textField.textColor = AppColours.textGray
        textField.font = UIFont.bcSansRegularWithSize(size: 17)
        submitButton.setTitle("", for: .normal)
        submitButton.setImage(UIImage(named: "submit-inactive"), for: .normal)
        leftImageView.image = UIImage(named: "https")
        
        self.layer.cornerRadius = 4
        self.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.07).cgColor
        self.layer.shadowOpacity = 1
        self.layer.shadowOffset = CGSize(width: -1, height: 5)
        self.layer.shadowRadius = 5
        layoutSubviews()
    }
    
}
