//
//  MedicationRecordDetailView.swift
//  HealthGatewayTest
//
//  Created by Amir on 2022-06-22.
//

import UIKit

class MedicationRecordDetailView: BaseHealthRecordsDetailView, UITableViewDelegate, UITableViewDataSource {
    
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

extension MedicationRecordDetailView {
    private func createFields() -> [TextListModel] {
        guard let model = model else {return []}
        switch model.type {
        case .medication(model: let prescription):
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
            let quantity: String = prescription.medication?.quantity.removeZerosFromEnd() ?? ""
            let fields: [TextListModel] = [
                TextListModel(
                    header: TextProperties(text: "Practitioner:", bolded: true),
                    subtext: TextProperties(text: prescription.practitionerSurname ?? "", bolded: false)),
                TextListModel(
                    header: TextProperties(text: "Quantity:", bolded: true),
                    subtext: TextProperties(text: quantity, bolded: false)),
                TextListModel(
                    header: TextProperties(text: "Strength:", bolded: true),
                    subtext: TextProperties(text: (prescription.medication?.strength ?? "") + " " + (prescription.medication?.strengthUnit ?? ""), bolded: false)),
                TextListModel(
                    header: TextProperties(text: "Form:", bolded: true),
                    subtext: TextProperties(text: prescription.medication?.form ?? "", bolded: false)),
                TextListModel(
                    header: TextProperties(text: "Manufacturer:", bolded: true),
                    subtext: TextProperties(text: prescription.medication?.manufacturer ?? "", bolded: false)),
                TextListModel(
                    header: TextProperties(text: dinText, bolded: true),
                    subtext: TextProperties(text: prescription.medication?.din ?? "", bolded: false)),
                TextListModel(
                    header: TextProperties(text: "Filled at:", bolded: true),
                    subtext: TextProperties(text: prescription.pharmacy?.name ?? "", bolded: false)),
                TextListModel(
                    header: TextProperties(text: "Filled date:", bolded: true),
                    subtext: TextProperties(text: dateString ?? "", bolded: false)),
                TextListModel(
                    header: TextProperties(text: "Address:", bolded: true),
                    subtext: TextProperties(text: address, bolded: false)),
                TextListModel(
                    header: TextProperties(text: "Phone number:", bolded: true),
                    subtext: TextProperties(text: prescription.pharmacy?.phoneNumber ?? "", bolded: false)),
                TextListModel(
                    header: TextProperties(text: "Fax:", bolded: true),
                    subtext: TextProperties(text: prescription.pharmacy?.faxNumber ?? "", bolded: false)),
                TextListModel(
                    header: TextProperties(text: "Direction for use:", bolded: true),
                    subtext: TextProperties(text: prescription.directions ?? "", bolded: false))
            ]
            return fields
        default:
            return []
        }
    }
}

extension Double {
    func removeZerosFromEnd() -> String {
        let formatter = NumberFormatter()
        let number = NSNumber(value: self)
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 16 //maximum digits in Double after dot (maximum precision)
        return String(formatter.string(from: number) ?? "")
    }
}
