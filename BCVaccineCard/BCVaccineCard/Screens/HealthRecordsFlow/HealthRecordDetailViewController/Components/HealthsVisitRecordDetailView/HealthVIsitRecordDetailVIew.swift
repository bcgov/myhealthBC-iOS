//
//  HealthVIsitRecordDetailVIew.swift
//  BCVaccineCard
//
//  Created by Amir on 2022-07-12.
//

import UIKit

extension HealthRecordsDetailDataSource.Record {
    fileprivate func healthVisit() -> HealthVisit? {
        switch self.type {
        case .healthVisit(model: let model):
            return model
        default:
            return nil
        }
    }
}

class HealthVisitRecordDetailView: BaseHealthRecordsDetailView, UITableViewDelegate, UITableViewDataSource {
    
    enum Section: Int, CaseIterable {
        case Fields
        case Comments
    }
    
    private var fields: [TextListModel] = []

    override func setup() {
        tableView?.dataSource = self
        tableView?.delegate = self
        tableView?.register(UINib.init(nibName: HealthVisitRecordDetailTableViewCell.getName, bundle: .main), forCellReuseIdentifier: HealthVisitRecordDetailTableViewCell.getName)
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
    
    private func getCell(indexPath: IndexPath, tableView: UITableView) -> HealthVisitRecordDetailTableViewCell? {
        let cell = tableView.dequeueReusableCell(withIdentifier: HealthVisitRecordDetailTableViewCell.getName, for: indexPath) as? HealthVisitRecordDetailTableViewCell
        cell?.selectionStyle = .none
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = Section(rawValue: section) else {return 0}
        switch section {
        case .Fields:
            return fields.count + 1
        case .Comments:
            return comments.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        layoutIfNeeded()
        guard let section = Section(rawValue: indexPath.section) else {return UITableViewCell()}
        switch section {
        case .Fields:
            if indexPath.row == 0 {
                guard let cell = getCell(indexPath: indexPath, tableView: tableView) else {return UITableViewCell()}
                cell.configure()
                return cell
            }
            if indexPath.row > 0 {
                guard let cell = textCell(indexPath: indexPath, tableView: tableView) else {return UITableViewCell()}
                cell.setup(with: fields[indexPath.row - 1])
                return cell
            }
        case .Comments:
            guard let cell = commentCell(indexPath: indexPath, tableView: tableView) else {return UITableViewCell()}
            cell.configure(comment: comments[indexPath.row], showOptionsButton: false)
            return cell
        }
        
        return UITableViewCell()
    }
    
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        guard section != 0 else {return nil}
//        return separatorView()
//    }
//
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        guard section != 0 else {return 0}
//        return separatorHeight + separatorBottomSpace
//    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let section = Section(rawValue: section), section == .Comments, let model = self.model else {return nil}
        
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


extension HealthVisitRecordDetailView {
    
    private func createFields() -> [TextListModel] {
        guard let model = model, let object = model.healthVisit() else {return []}

        let fields: [TextListModel] = [
            TextListModel(
                header: TextProperties(
                    text: "Clinic Name:",
                    bolded: true),
                subtext: TextProperties(
                    text: object.clinic?.name ?? "",
                    bolded: false)),
            TextListModel(
                header: TextProperties(
                    text: "Practitioner Name:",
                    bolded: true),
                subtext: TextProperties(
                    text: object.practitionerName ?? "",
                    bolded: false))
        ]
       
        return fields
    }
}
