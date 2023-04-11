//
//  HospitalVisitDetailView.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2023-01-09.
//

import UIKit

class HospitalVisitRecordDetailView: BaseHealthRecordsDetailView, UITableViewDelegate, UITableViewDataSource {
    
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
        headerView.configure(text: "\(model.comments.count) \(commentsString)", colour: AppColours.appBlue, delegate: self)
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

extension HospitalVisitRecordDetailView {
    private func createFields() -> [TextListModel] {
        guard let model = model else {return []}
        switch model.type {
        case .hospitalVisit(model: let model):
           
            var providerText = model.provider ?? "NOT AVAILABLE"
            if providerText.trimWhiteSpacesAndNewLines.count == 0 {
                providerText = "NOT AVAILABLE"
            }
            var healthServiceText = model.healthService ?? "NOT AVAILABLE"
            if healthServiceText.trimWhiteSpacesAndNewLines.count == 0 {
                healthServiceText = "NOT AVAILABLE"
            }
            var dischargeDateText = model.endDateTime?.labOrderDateTime ?? "NOT AVAILABLE"
            if dischargeDateText.trimWhiteSpacesAndNewLines.count == 0 {
                dischargeDateText = "NOT AVAILABLE"
            }
            let fields: [TextListModel] = [
                TextListModel(
                    header: TextProperties(text: "Location:", bolded: true),
                    subtext: TextProperties(text: model.facility ?? "", bolded: false),
                    thirdLine: TextProperties(text: "Virtual visits show your provider's location", bolded: false, italic: true, fontSize: 17, textColor: .grey)
                ),
                TextListModel(
                    header: TextProperties(text: "Provider:", bolded: true),
                    subtext: TextProperties(text: providerText, bolded: false),
                    thirdLine: TextProperties(text: "Inpatient visits only show the first attending physician.", bolded: false, italic: true, fontSize: 17, textColor: .grey)
                ),
                TextListModel(
                    header: TextProperties(text: "Service description:", bolded: true),
                    subtext: TextProperties(text: healthServiceText, bolded: false)
                ),
                TextListModel(
                    header: TextProperties(text: "Visit type:", bolded: true),
                    subtext: TextProperties(text: model.visitType ?? "", bolded: false)),
                TextListModel(
                    header: TextProperties(text: "Visit Date:", bolded: true),
                    subtext: TextProperties(text: model.admitDateTime?.labOrderDateTime ?? "", bolded: false)),
                TextListModel(
                    header: TextProperties(text: "Discharge Date:", bolded: true),
                    subtext: TextProperties(text: dischargeDateText, bolded: false)),
                ]
            return fields
        default:
            return []
        }
    }
}
