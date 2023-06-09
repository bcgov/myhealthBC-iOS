//
//  EnterTextTableViewCell.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2023-06-07.
//

import UIKit

enum NotesTextViewType {
    case Title
    case Text
    
    var getCharacterLimit: Int {
        switch self {
        case .Title: return 50
        case .Text: return 500
        }
    }
    
    var getPlaceholderText: String {
        switch self {
        case .Title: return "Untitled"
        case .Text: return "Tap here to start typing..."
        }
    }
    
    var getFont: UIFont {
        switch self {
        case .Title: return UIFont.bcSansBoldWithSize(size: 24)
        case .Text: return UIFont.bcSansRegularWithSize(size: 17)
        }
    }
    
    var getPlaceholderColor: UIColor {
        switch self {
        case .Title: return AppColours.borderGray
        case .Text: return AppColours.notesPlaceholderGrey
        }
    }
    
    var getForegroundColor: UIColor {
        switch self {
        case .Title: return AppColours.appBlue
        case .Text: return AppColours.textBlack
        }
    }
}

protocol EnterTextTableViewCellDelegate: AnyObject {
    func resizeTableView()
    func noteValueChanged(type: NotesTextViewType, text: String)
}

class EnterTextTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var textView: UITextView!
    @IBOutlet private weak var placeholderLabel: UILabel!
    
    private var type: NotesTextViewType?
    private weak var delegate: EnterTextTableViewCellDelegate?
    
    private var previousRect: CGRect?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // TODO: Check this here for editing functionality
        print("CONNOR CALLED HERE")
//        self.textView.becomeFirstResponder()
    }
    
    private func setup() {
        textView.delegate = self
        createCustomKeyboard()
        placeholderLabel.isUserInteractionEnabled = false
        textView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func configure(type: NotesTextViewType, note: PostNote?, state: NoteVCCellState, delegateOwner: UIViewController) {
        self.type = type
        setupUI(type: type, note: note)
        textView.isUserInteractionEnabled = state != .ViewNote
        self.delegate = delegateOwner as? EnterTextTableViewCellDelegate
        self.textView.resignFirstResponder()
    }
    
    private func setupUI(type: NotesTextViewType, note: PostNote?) {
        textView.font = type.getFont
        textView.textColor = type.getForegroundColor
        placeholderLabel.font = type.getFont
        placeholderLabel.text = type.getPlaceholderText
        placeholderLabel.textColor = type.getPlaceholderColor
        guard let note = note else {
            placeholderLabel.isHidden = false
            return
        }
        switch type {
        case .Title:
            let noteHasTitle = note.title.trimWhiteSpacesAndNewLines.count > 0
            placeholderLabel.isHidden = noteHasTitle
            textView.text = noteHasTitle ? note.title : nil
        case .Text:
            let noteHasText = note.text.trimWhiteSpacesAndNewLines.count > 0
            placeholderLabel.isHidden = noteHasText
            textView.text = noteHasText ? note.text : nil
        }
    }
    
    private func createCustomKeyboard() {
        let bar = UIToolbar()
        bar.sizeToFit()
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let dismissKeyboard = UIBarButtonItem(image: UIImage(named: "down-arrow"), style: .plain, target: self, action: #selector(dismissKeyboard))
        // NOTE: Will be using more buttons when we add ability to add other media
        bar.items = [spacer, dismissKeyboard]
        bar.tintColor = AppColours.appBlue
        textView.inputAccessoryView = bar
    }
    
    @objc private func dismissKeyboard() {
        self.textView.resignFirstResponder()
    }
    
}

extension EnterTextTableViewCell: UITextViewDelegate {
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        placeholderLabel.isHidden = true
        return true
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        if textView.text.trimWhiteSpacesAndNewLines.count == 0 {
            placeholderLabel.isHidden = false
        }
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let pos = textView.endOfDocument
        let currentRect = textView.caretRect(for: pos)
        if previousRect != CGRect.zero {
            if currentRect.origin.y > previousRect?.origin.y ?? 0 {
                // Array of Strings
                var currentLines = textView.text.components(separatedBy: "\n")
                // Remove Blank Strings
                currentLines = currentLines.filter{ $0 != "" }
                //increase the counter counting how many items inside the array
//                counter = currentLines.count
                // FIXME: Need to sort this out
//                self.delegate?.resizeTableView()
            }
        }
        previousRect = currentRect
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // get the current text, or use an empty string if that failed
        let currentText = textView.text ?? ""

        // attempt to read the range they are trying to change, or exit if we can't
        guard let stringRange = Range(range, in: currentText) else { return false }

        // add their new text to the existing text
        let updatedText = currentText.replacingCharacters(in: stringRange, with: text)
        
        // Format other UI
        let noteText = updatedText.count <= type?.getCharacterLimit ?? 500 ? updatedText : currentText
        self.delegate?.noteValueChanged(type: self.type ?? .Title, text: noteText)
//        // make sure the result is under 500 characters
        return updatedText.count <= type?.getCharacterLimit ?? 500
    }

}
