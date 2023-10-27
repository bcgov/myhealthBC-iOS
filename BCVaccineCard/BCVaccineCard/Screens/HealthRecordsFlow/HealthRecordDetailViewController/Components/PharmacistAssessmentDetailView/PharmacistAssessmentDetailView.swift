//
//  PharmacistAssessmentDetailView.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2023-10-23.
//

import UIKit
// TODO: Clean this up, it's too messy (for the table view logic)
class PharmacistAssessmentDetailView: BaseHealthRecordsDetailView, UITableViewDelegate, UITableViewDataSource {
    
    enum Section: Int, CaseIterable {
        case Fields
        case Comments
        
        var getNumberOfSections: Int {
            switch self {
            case .Fields: return 2
            case .Comments: return 1
            }
        }
        
        static func getSection(index: Int) -> Section? {
            if index < 2 {
                return .Fields
            } else if index == 2 {
                return .Comments
            } else {
                return nil
            }
        }
    }
    
    private var fields: [[TextListModel]] = [[]]
    
    override func setup() {
        fields = createFields()
        comments = model?.comments.filter({ $0.shouldHide != true }) ?? []
        tableView?.dataSource = self
        tableView?.delegate = self
    }
    
    override func submittedComment(object: Comment) {
        comments.append(object)
        tableView?.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: { [weak self] in
            let row = (self?.comments.count ?? 0) - 1
            guard row >= 0 else { return }
            let indexPath = IndexPath(row: row, section: self?.commentsSectionIndex() ?? 2)
            self?.tableView?.scrollToRow(at: indexPath, at: .bottom, animated: true)
        })
    }
    
    private func commentsSectionIndex() -> Int {
        // Comments will always be after fields, so with 2 fields sections, there are 3 sections total, and comments section will be index 2
        return fields.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // Fields has two sections
        return self.fields.count + 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionType = Section.getSection(index: section) else { return 0 }
        switch sectionType {
        case .Fields:
            return fields[section].count
        case .Comments:
            return comments.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = Section.getSection(index: indexPath.section) else {return UITableViewCell()}
        switch section {
        case .Fields:
            guard let cell = textCell(indexPath: indexPath, tableView: tableView) else {return UITableViewCell()}
            cell.setup(with: fields[indexPath.section][indexPath.row])
            return cell
        case .Comments:
            guard let cell = commentCell(indexPath: indexPath, tableView: tableView) else {return UITableViewCell()}
            cell.configure(comment: comments[indexPath.row], showOptionsButton: false)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 2 {
            guard let section = Section.getSection(index: section), section == .Comments ,let model = self.model else {return nil}
            
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
        guard section != 0 else {return nil}
        return separatorView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 2 {
            guard let section = Section.getSection(index: section), section == .Comments, let model = self.model else {return 0}
            guard !model.comments.isEmpty else {
                return 0
            }
            return "Comments".heightForView(font: TableSectionHeader.font, width: bounds.width) + 10
        }
        guard section != 0 else {return 0}
        return separatorHeight + separatorBottomSpace
    }
    
}

extension PharmacistAssessmentDetailView {
    private func createFields() -> [[TextListModel]] {
        guard let model = model else {return []}
        switch model.type {
        case .medication(model: let prescription):
            var address = ""
            if let addy1 = prescription.pharmacy?.addressLine1 {
                address = addy1
            }
            if let addy2 = prescription.pharmacy?.addressLine2 {
                if address.count > 0 {
                    address.append(" ")
                }
                address.append(addy2)
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
            let thirdLine: TextProperties? = prescription.medication?.redirectedToHealthCareProvider == true ? TextProperties(text: "Advised the patient to seek medical attention from a physician or other health care professional", bolded: false, italic: true, textColor: .grey) : nil
            let field1: [TextListModel] = [
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
                    subtext: TextProperties(text: address, bolded: false))
            ]
            let field2: [TextListModel] = [
                TextListModel(
                    header: TextProperties(text: "Outcome:", bolded: true),
                    subtext: TextProperties(text: outcome, bolded: false),
                    thirdLine: thirdLine)
            ]
            return [field1, field2]
        default:
            return [[]]
        }
    }
}
