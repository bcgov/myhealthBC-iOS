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

class EnterTextTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var textView: UITextView!
    
    private var type: NotesTextViewType?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // TODO: Check this here for editing functionality
        print("CONNOR CALLED HERE")
        self.becomeFirstResponder()
    }
    
    private func setup() {
        textView.delegate = self
    }
    
    func configure(type: NotesTextViewType, note: PostNote?) {
        self.type = type
        setupUI(type: type, note: note)
    }
    
    private func setupUI(type: NotesTextViewType, note: PostNote?) {
        textView.font = type.getFont
        guard let note = note else {
            textView.textColor = type.getPlaceholderColor
            textView.text = type.getPlaceholderText
            return
        }
        switch type {
        case .Title:
            textView.text = note.title.trimWhiteSpacesAndNewLines.count == 0 ? note.title : type.getPlaceholderText
            textView.textColor = note.title.trimWhiteSpacesAndNewLines.count == 0 ? type.getForegroundColor : type.getPlaceholderColor
        case .Text:
            textView.text = note.text.trimWhiteSpacesAndNewLines.count == 0 ? note.text : type.getPlaceholderText
            textView.textColor = note.text.trimWhiteSpacesAndNewLines.count == 0 ? type.getForegroundColor : type.getPlaceholderColor
        }
    }
    
    private func createCustomKeyboard() {
        let bar = UIToolbar()
        let dismissKeyboard = UIBarButtonItem(image: UIImage(named: "down-arrow"), style: .done, target: self, action: #selector(dismissKeyboard))
        // NOTE: Will be using this when we add ability to add other media
//        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        bar.items = [dismissKeyboard]
        bar.sizeToFit()
        textView.inputAccessoryView = bar
    }
    
    @objc private func dismissKeyboard() {
        self.resignFirstResponder()
    }
    
}

extension EnterTextTableViewCell: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // Combine the textView text and the replacement text to
            // create the updated text string
            let currentText:String = textView.text
            let updatedText = (currentText as NSString).replacingCharacters(in: range, with: text)

            // If updated text view will be empty, add the placeholder
            // and set the cursor to the beginning of the text view
            if updatedText.isEmpty {

                textView.text = self.type?.getPlaceholderText
                textView.textColor = self.type?.getPlaceholderColor

                textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
            }

            // Else if the text view's placeholder is showing and the
            // length of the replacement string is greater than 0, set
            // the text color to black then set its text to the
            // replacement string
        else if textView.text == self.type?.getPlaceholderText && !text.isEmpty {
            textView.textColor = self.type?.getForegroundColor
                textView.text = text
            }

            // For every other case, the text should change with the usual
            // behavior...
            else {
                let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
                let numberOfChars = newText.count
                if numberOfChars > type?.getCharacterLimit ?? 500 {
                    return false
                } else {
                    return true
                }
            }
            self.layoutIfNeeded() // Note: uncomment this if there are UI issues, I suspect there will be
            // ...otherwise return false since the updates have already
            // been made
            return false
    }
}
