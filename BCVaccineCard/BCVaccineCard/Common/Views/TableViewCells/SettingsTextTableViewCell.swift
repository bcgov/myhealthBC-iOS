//
//  SettingsTextTableViewCell.swift
//  BCVaccineCard
//
//  Created by Amir on 2021-12-07.
//

import UIKit

class SettingsTextTableViewCell: UITableViewCell, Theme {
    
    enum Style {
        case Desctructive
        case Regular
    }

    private let defaultLabelHeight: CGFloat = 63
    private let horizontalPadding: CGFloat = 32
    private let spacing: CGFloat = 8
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    
    private var titleHeight: NSLayoutConstraint?
    private var subtitleHeight: NSLayoutConstraint?
    
    private var callback: (()->Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupTitleLabel()
        setupSubTitleLabel()
    }
    
    fileprivate func setupTitleLabel() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.systemFont(ofSize: 20)
        titleLabel.numberOfLines = 0
        
        contentView.addSubview(titleLabel)
        
        titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: spacing).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: horizontalPadding).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -horizontalPadding).isActive = true
        titleHeight = titleLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: defaultLabelHeight)
        titleHeight?.priority = .defaultLow
        titleHeight?.isActive = true
    }
    
    fileprivate func setupSubTitleLabel() {
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.font = UIFont.systemFont(ofSize: 13)
        subtitleLabel.numberOfLines = 0
        
        contentView.addSubview(subtitleLabel)
        
        subtitleHeight = subtitleLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: defaultLabelHeight)
        
        subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: horizontalPadding).isActive = true
        subtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -horizontalPadding).isActive = true
        subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: spacing).isActive = true
        subtitleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -spacing).isActive = true
        subtitleHeight?.priority = .defaultLow
        subtitleHeight?.isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(title: String, titleColour: LabelColour, subTitle: String, onTap: @escaping() -> Void) {
        style(label: titleLabel, style: .Regular, size: 16, colour: titleColour)
        style(label: subtitleLabel, style: .Regular, size: 13, colour: .Grey)
        titleLabel.text = title
        subtitleLabel.text = subTitle
        if let subTitleFont = subtitleLabel.font {
            subtitleHeight?.constant = subTitle.heightForView(font: subTitleFont, width: subtitleLabel.bounds.width)
        }
        if let titleFont = titleLabel.font {
            titleHeight?.constant = title.heightForView(font: titleFont, width: subtitleLabel.bounds.width) + spacing
        }
       
        callback = onTap
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        self.addGestureRecognizer(tap)
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        if let onTap = callback {
            onTap()
        }
    }
}
