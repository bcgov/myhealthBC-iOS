//
//  PharmacistAssessmentDetailView.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2023-10-23.
//

import UIKit

class PharmacistAssessmentDetailView: BaseHealthRecordsDetailView, UITableViewDelegate, UITableViewDataSource {
    
    enum Section: Int, CaseIterable {
        case Fields
        case Comments
    }
    
    private var fields: [TextListModel] = []
    
    override func setup() {
        tableView?.dataSource = self
        tableView?.delegate = self
        fields = createFields()
        comments = model?.comments.filter({ $0.shouldHide != true }) ?? []
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

extension PharmacistAssessmentDetailView {
    // TODO: Connor - update the UI so that Outcome can be in a separate area
    private func createFields() -> [TextListModel] {
        guard let model = model else {return []}
        switch model.type {
        case .pharmacist(model: let prescription):
            let dateString = prescription.dispensedDate?.monthDayYearString
            var address = ""
            if let addy = prescription.pharmacy?.addressLine1 {
                address = addy
            }
            if let city = prescription.pharmacy?.city {
                if address.count > 0 {
                    address.append(", ")
                    address.append(city)
                } else {
                    address = city
                }
            }
            if let province = prescription.pharmacy?.province {
                if address.count > 0 {
                    address.append(", ")
                    address.append(province)
                } else {
                    address = province
                }
            }
            
            let dinText = (prescription.medication?.isPin ?? false) ? "PIN:" : "DIN:"
            let outcome = (prescription.medication?.prescriptionProvided == true) ? "Prescription provided" : "Prescription not provided"
            let thirdLine: TextProperties? = prescription.medication?.prescriptionProvided == true ? TextProperties(text: "Advised the patient to seek medical attention from a physician or other health care professional", bolded: false, italic: true) : nil
            let fields: [TextListModel] = [
                TextListModel(
                    header: TextProperties(text: "Practitioner:", bolded: true),
                    subtext: TextProperties(text: prescription.practitionerSurname ?? "", bolded: false)),
                TextListModel(
                    header: TextProperties(text: "Service type:", bolded: true),
                    subtext: TextProperties(text: prescription.medication?.pharmacyAssessmentTitle ?? "", bolded: false)),
                TextListModel(
                    header: TextProperties(text: dinText, bolded: true),
                    subtext: TextProperties(text: prescription.medication?.din ?? "", bolded: false)),
                TextListModel(
                    header: TextProperties(text: "Location:", bolded: true),
                    subtext: TextProperties(text: prescription.pharmacy?.name ?? "", bolded: false)),
                TextListModel(
                    header: TextProperties(text: "Address:", bolded: true),
                    subtext: TextProperties(text: address, bolded: false)),
                TextListModel(
                    header: TextProperties(text: "Outcome:", bolded: true),
                    subtext: TextProperties(text: outcome, bolded: false),
                    thirdLine: thirdLine)
            ]
            return fields
        default:
            return []
        }
    }
}
