//
//  SpecialAuthorityDrugDetailView.swift
//  BCVaccineCard
//
//  Created by Amir on 2022-07-12.
//

import UIKit

extension HealthRecordsDetailDataSource.Record {
    fileprivate func specialAuthorityDrug() -> SpecialAuthorityDrug? {
        switch self.type {
        case .specialAuthorityDrug(model: let model):
            return model
        default:
            return nil
        }
    }
}

class SpecialAuthorityDrugDetailView: BaseHealthRecordsDetailView, UITableViewDelegate, UITableViewDataSource {
    
    enum Section: Int, CaseIterable {
        case Fields
        case Comments
    }
    
    private var fields: [TextListModel] = []

    override func setup() {
        tableView?.dataSource = self
        tableView?.delegate = self
        fields = createFields()
        comments = model?.comments ?? []
    }
    
    override func submittedComment(object: Comment) {
        comments.append(object)
        tableView?.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: { [weak self] in
            let row = (self?.comments.count ?? 0) - 1
            guard row >= 0 else { return }
            let indexPath = IndexPath(row: row, section: Section.allCases.count - 1)
            self?.tableView?.scrollToRow(at: indexPath, at: .bottom, animated: true)
        })
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = Section(rawValue: section) else {return 0}
        switch section {
        case .Fields:
            return fields.count
        case .Comments:
            return comments.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = Section(rawValue: indexPath.section) else {return UITableViewCell()}
        switch section {
        case .Fields:
            guard let cell = textCell(indexPath: indexPath, tableView: tableView) else {return UITableViewCell()}
            cell.setup(with: fields[indexPath.row])
            return cell
        case .Comments:
            guard let cell = commentCell(indexPath: indexPath, tableView: tableView) else {return UITableViewCell()}
            cell.configure(comment: comments[indexPath.row], showOptionsButton: false)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let section = Section(rawValue: section), section == .Comments ,let model = self.model else {return nil}
        
        let headerView: TableSectionHeader = TableSectionHeader.fromNib()
        guard !model.comments.isEmpty else {
            headerView.configure(text: "")
            return headerView
        }
        let commentsString = model.comments.count == 1 ? "Comment" : "Comments"
        headerView.configure(text: "\(model.comments.count) \(commentsString)",colour: AppColours.appBlue, delegate: self)
        headerView.backgroundColor = .white
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let section = Section(rawValue: section), section == .Comments, let model = self.model else {return 0}
        guard !model.comments.isEmpty else {
            return 0
        }
        return "Comments".heightForView(font: TableSectionHeader.font, width: bounds.width) + 10
    }
}


extension SpecialAuthorityDrugDetailView {
    
    private func createFields() -> [TextListModel] {
        guard let model = model, let object = model.specialAuthorityDrug() else {return []}
        var effectiveDate = ""
        if let date = object.effectiveDate {
            effectiveDate = date.issuedOnDate
        }
        
        var expiryDate = ""
        if let date = object.expiryDate {
            expiryDate = date.issuedOnDate
        }
        let prescriberFirstName = object.prescriberFirstName ?? ""
        let prescriberLastName = object.prescriberLastName ?? ""
        let fields: [TextListModel] = [
            TextListModel(
                header: TextProperties(
                    text: "Status:",
                    bolded: true),
                subtext: TextProperties(
                    text: object.requestStatus ?? "",
                    bolded: false)),
            TextListModel(
                header: TextProperties(
                    text: "Prescriber Name:",
                    bolded: true),
                subtext: TextProperties(
                    text: "\(prescriberFirstName) \(prescriberLastName)",
                    bolded: false)),
            TextListModel(
                header: TextProperties(
                    text: "Effective Date:",
                    bolded: true),
                subtext: TextProperties(
                    text: effectiveDate,
                    bolded: false)),
            TextListModel(
                header: TextProperties(
                    text: "Expiry Date:",
                    bolded: true),
                subtext: TextProperties(
                    text: expiryDate,
                    bolded: false)),
            TextListModel(
                header: TextProperties(
                    text: "Reference Number:",
                    bolded: true),
                subtext: TextProperties(
                    text: object.referenceNumber ?? "",
                    bolded: false)),
        ]
       
        return fields
    }
}
