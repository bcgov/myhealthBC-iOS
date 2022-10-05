//
//  LabOrderRecordDetailView.swift
//  HealthGatewayTest
//
//  Created by Amir on 2022-06-22.
//

import UIKit

extension HealthRecordsDetailDataSource.Record {
    fileprivate func labOrder() -> LaboratoryOrder? {
        switch self.type {
        case .laboratoryOrder(let model, _):
            return model
        default:
            return nil
        }
    }
    
    fileprivate func LabTests() -> [LaboratoryTest]? {
        switch self.type {
        case .laboratoryOrder(_, let tests):
            return tests
        default:
            return nil
        }
    }
    
    fileprivate func labOrderBannerType() -> LabOrderBsnnerTableViewCell.LabOrderBsnnerType? {
        guard let labTests = LabTests()  else {return .NoTests}
        
        if labTests.isEmpty {
            return .NoTests
        } else if status?.lowercased() == "pending" {
            return .Pending
        } else if status?.lowercased() == "cancelled" {
            return .Cancelled
        }
        return nil
    }
}

class LabOrderRecordDetailView: BaseHealthRecordsDetailView, UITableViewDelegate, UITableViewDataSource {
    
    enum Section: Int, CaseIterable {
        case Fields
        case Comments
    }
    
    private var fields: [[TextListModel]] = [[]]
    
    struct HeaderSection {
        enum HeaderType {
            case banner
            case pdf
        }
        
        var bannerPresent: Bool
        var pdfPresent: Bool
        
        func indexOfType(type: HeaderType) -> Int {
            switch type {
            case .banner:
                return 0
            case .pdf:
                return bannerPresent ? 1 : 0
            }
        }
        
        var headerCount: Int {
            var count = 0
            if bannerPresent {
                count += 1
            }
            if pdfPresent {
                count += 1
            }
            return count
        }
    }
    
    var headerSection = HeaderSection(bannerPresent: false, pdfPresent: false)
    
    var hasHeader: Bool {
        return (model?.labOrderBannerType() != nil || model?.labOrder()?.reportAvailable == true)
    }
    
    var numberOrSections: Int {
        // 2 to account for header & comments or just comments
        hasHeader ? fields.count + 2 : fields.count + 1
    }
    
    override func setup() {
        setupHeaderSection()
        tableView?.register(UINib.init(nibName: LabOrderBsnnerTableViewCell.getName, bundle: .main), forCellReuseIdentifier: LabOrderBsnnerTableViewCell.getName)
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
            guard row >= 0, let numberOfSections = self?.numberOrSections else { return }
            let indexPath = IndexPath(row: row, section: numberOfSections - 1)
            self?.tableView?.scrollToRow(at: indexPath, at: .bottom, animated: true)
        })
    }
    
    private func setupHeaderSection() {
        if model?.labOrderBannerType() != nil {
            headerSection.bannerPresent = true
        }
        if model?.labOrder()?.reportAvailable == true {
            headerSection.pdfPresent = true
        }
    }
    
    public func labOrderHeaderCell(indexPath: IndexPath, tableView: UITableView) -> LabOrderBsnnerTableViewCell? {
        return tableView.dequeueReusableCell(withIdentifier: LabOrderBsnnerTableViewCell.getName, for: indexPath) as? LabOrderBsnnerTableViewCell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return numberOrSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Header section
        if hasHeader, section == 0 {
            return headerSection.headerCount
        }
        
        // Comment section
        if section == numberOrSections - 1 {
            return comments.count
        }
        
        // Fields
        if hasHeader {
            return fields[section - 1].count
        } else {
            return fields[section].count
        }
    }
    // TODO: Clean this part up
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let model = self.model else {return UITableViewCell()}
        
        // Header cell
        if hasHeader, indexPath.section == 0 {
            if let bannerType = model.labOrderBannerType(), indexPath.row == headerSection.indexOfType(type: .banner) {
                guard let cell = labOrderHeaderCell(indexPath: indexPath, tableView: tableView) else {return UITableViewCell()}
                cell.setup(type: bannerType)
                return cell
            }
            if model.labOrder()?.reportAvailable == true, indexPath.row == headerSection.indexOfType(type: .pdf) {
                guard let cell = viewPDFButtonCell(indexPath: indexPath, tableView: tableView) else { return UITableViewCell() }
                cell.configure(delegateOwner: HealthRecordDetailViewController.currentInstance)
                return cell
            }
        }
        
        // Last section is comments
        if indexPath.section == numberOrSections - 1 {
            guard let cell = commentCell(indexPath: indexPath, tableView: tableView) else {return UITableViewCell()}
            cell.configure(comment: comments[indexPath.row])
            return cell
        }
        
        // Fields
        let fieldSection = hasHeader ? indexPath.section - 1 : indexPath.section
        guard let cell = textCell(indexPath: indexPath, tableView: tableView) else {return UITableViewCell()}
        cell.setup(with: fields[fieldSection][indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == numberOrSections - 1, let model = self.model {
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
        guard section != 0 else {return nil}
        return separatorView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == numberOrSections - 1, let model = self.model {
            guard !model.comments.isEmpty else {
                return 0
            }
            return "Comments".heightForView(font: TableSectionHeader.font, width: bounds.width) + 10
        }
        guard section != 0 else {return 0}
        return separatorHeight + separatorBottomSpace
    }
   
}

extension LabOrderRecordDetailView {
    
    private func createFields() -> [[TextListModel]] {
        guard let model = model, let labOrder = model.labOrder(), let labTests = model.LabTests() else {return []}
        var fields: [[TextListModel]] = []
        
        fields.append([
            TextListModel(
                header: TextProperties(text: "Collection date:", bolded: true),
                subtext: TextProperties(text: labOrder.timelineDateTime?.labOrderDateTime ?? "", bolded: false)),
            TextListModel(
                header: TextProperties(text: "Ordering provider:", bolded: true),
                subtext: TextProperties(text: labOrder.orderingProvider ?? "", bolded: false)),
            TextListModel(
                header: TextProperties(text: "Reporting Lab:", bolded: true),
                subtext: TextProperties(text: labOrder.reportingSource ?? "", bolded: false))
        ])
        
        if !labTests.isEmpty {
            for (index, test) in labTests.enumerated() {
                let resultTuple = formatResultField(test: test)
                let statusTuple = formatStatusField(test: test)
                var section: [TextListModel] = [
                    TextListModel(
                        header: TextProperties(text: "Test name:", bolded: true),
                        subtext: TextProperties(text: test.batteryType ?? "", bolded: false)),
                    TextListModel(
                        header: TextProperties(text: "Result:", bolded: true),
                        subtext: TextProperties(text: resultTuple.text, bolded: resultTuple.bolded, textColor: resultTuple.color)),
                    TextListModel(
                        header: TextProperties(text: "Test status:", bolded: true),
                        subtext: TextProperties(text: statusTuple.text ,bolded: statusTuple.bolded))
                ]
                if index == 0 {
                    let links = [LinkedStrings(text: "Learn more", link: "https://www.healthgateway.gov.bc.ca/faq")]
                    section.insert(TextListModel(header: TextProperties(text: "Test summary", bolded: true), subtext: TextProperties(text: "Find resources to learn about your lab test and what the results mean. Learn more", bolded: false, links: links)), at: 0)
                }
                fields.append(section)
            }
        }
        return fields
    }
    
    private func formatStatusField(test: LaboratoryTest) -> (text: String, color:  TextProperties.CodableColors, bolded: Bool) {
        if test.testStatus == "Active" {
            return ("Pending", .black, false)
        } else if test.testStatus == "Cancelled" {
            return ("Cancelled", .black, false)
        } else if test.testStatus == "Completed" {
            return ("Completed", .black, false)
        } else if test.testStatus == "Corrected" {
            return ("Corrected", .black, false)
        }
        return ("Unknown", .black, false)
    }
    
    private func formatResultField(test: LaboratoryTest) -> (text: String, color: TextProperties.CodableColors, bolded: Bool) {
        if test.testStatus == "Active" {
            return ("Pending", .black, false)
        } else if test.testStatus == "Cancelled" {
            return ("Cancelled", .black, false)
        } else if test.testStatus == "Completed" || test.testStatus == "Corrected" {
            let text = test.outOfRange ? "Out of Range" : "In Range"
            let color: TextProperties.CodableColors = test.outOfRange ? .red : .green
            return (text, color, true)
        }
        
        return ("Unknown", .black, false)
    }
}
