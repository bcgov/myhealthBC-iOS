//
//  TestResultRecordDetailView.swift
//  HealthGatewayTest
//
//  Created by Amir on 2022-06-22.
//

import UIKit

extension HealthRecordsDetailDataSource.Record {
    fileprivate func testResult() -> TestResult? {
        switch self.type {
        case .covidTestResultRecord(let model):
            return model
        default:
            return nil
        }
    }
}

class CovidTestResultRecordDetailView: BaseHealthRecordsDetailView, UITableViewDelegate, UITableViewDataSource {
    
    enum Section: Int, CaseIterable {
        case Header
        case Fields
        case Comments
    }
    
    private var fields: [TextListModel] = []
    

    private var message: NSMutableAttributedString? {
        if model?.status?.lowercased() == .pending.lowercased() {
            return NSMutableAttributedString(string: .pendingTestRecordMessage)
            
        }
        if model?.status?.lowercased() == .cancelled.lowercased() {
           let  attributedString = NSMutableAttributedString(string: .cancelledTestRecordMessage)
            _ = attributedString.setAsLink(textToFind: "BC CDC Test Results", linkURL: "http://www.bccdc.ca/health-info/diseases-conditions/covid-19/testing/test-results")
            return attributedString
        }
        
        return nil
    }
    
    override func setup() {
        tableView?.register(UINib.init(nibName: CovidTestResultBannerTableViewCell.getName, bundle: .main), forCellReuseIdentifier: CovidTestResultBannerTableViewCell.getName)
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
    
    public func covidTestHeaderCell(indexPath: IndexPath, tableView: UITableView) -> CovidTestResultBannerTableViewCell? {
        let cell = tableView.dequeueReusableCell(withIdentifier: CovidTestResultBannerTableViewCell.getName, for: indexPath) as? CovidTestResultBannerTableViewCell
        cell?.selectionStyle = .none
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = Section(rawValue: section) else {return 0}
        switch section {
        case .Header:
            if model?.testResult()?.parentTest?.reportAvailable == true {
                return 2
            }
            return 1
        case .Fields:
            return fields.count
        case .Comments:
            return comments.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = Section(rawValue: indexPath.section),  let testResult = model?.testResult() else {return UITableViewCell()}
        switch section {
        case .Header:
            if indexPath.row == 0 {
                if let message = message {
                    guard let cell = messageHeaderCell(indexPath: indexPath, tableView: tableView) else {return UITableViewCell()}
                    cell.setup(text: message, bgColor: testResult.resultType.getColor, messageColor: testResult.resultType.getResultTextColor)
                    return cell
                } else {
                    guard let cell = covidTestHeaderCell(indexPath: indexPath, tableView: tableView) else {return UITableViewCell()}
                    cell.setup(for: testResult, status: model?.status ?? "")
                    return cell
                }
            } else if indexPath.row == 1 {
                guard let cell = viewPDFButtonCell(indexPath: indexPath, tableView: tableView) else { return UITableViewCell() }
                cell.configure(delegateOwner: HealthRecordDetailViewController.currentInstance)
                return cell
            }
           return UITableViewCell()
        case .Fields:
            guard let cell = textCell(indexPath: indexPath, tableView: tableView) else {return UITableViewCell()}
            cell.setup(with: fields[indexPath.row])
            return cell
        case .Comments:
            guard let cell = commentCell(indexPath: indexPath, tableView: tableView) else {return UITableViewCell()}
            cell.configure(comment: comments[indexPath.row])
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let section = Section(rawValue: section), section == .Comments ,let model = self.model {
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
        if let section = Section(rawValue: section), section == .Comments, let model = self.model {
            guard !model.comments.isEmpty else {
                return 0
            }
            return "Comments".heightForView(font: TableSectionHeader.font, width: bounds.width) + 10
        }
        guard section != 0 else {return 0}
        return separatorHeight + separatorBottomSpace
    }
}

extension CovidTestResultRecordDetailView {
    private func createFields() -> [TextListModel] {
        guard let model = model else {return []}
        guard let testResult = model.testResult() else {return []}
        var fields: [TextListModel] = [
            TextListModel(
                header: TextProperties(text: "Date of testing:", bolded: true),
                subtext: TextProperties(text: testResult.collectionDateTime?.issuedOnDate ?? "", bolded: false)
            ),
            TextListModel(
                header: TextProperties(text: "Test status:", bolded: true),
                subtext: TextProperties(text: testResult.testStatus ?? "Pending", bolded: false)
            ),
            TextListModel(
                header: TextProperties(text: "Type name:", bolded: true),
                subtext: TextProperties(text: testResult.testType ?? "", bolded: false)
            ),
            TextListModel(
                header: TextProperties(text: "Provider / Clinic:", bolded: true),
                subtext: TextProperties(text: testResult.lab ?? "", bolded: false)
            )
        ]
        if let resultDescription = testResult.resultDescription, !resultDescription.isEmpty {
            let tuple = handleResultDescriptionAndLinks(resultDescription: resultDescription, testResult: testResult)
            let resultDescriptionfield = TextListModel(
                header: TextProperties(text: "Result description:", bolded: true),
                subtext: TextProperties(text: tuple.text, bolded: false, links: tuple.links)
            )
            fields.append(resultDescriptionfield)
        }
        return fields
    }
    
    // Note this funcion is used to append "this page" text with link from API to end of result description. In the event where there is a positive test, there is no link, but there are links embedded in the text. For this, we use NSDataDetector to create links
    private func handleResultDescriptionAndLinks(resultDescription: [String], testResult: TestResult) -> (text: String, links: [LinkedStrings]?) {
        var descriptionString = ""
        for (index, description) in resultDescription.enumerated() {
            descriptionString.append(description)
            if index < resultDescription.count - 1 {
                descriptionString.append("\n\n")
            }
        }
        if descriptionString.last != " " {
            descriptionString.append(" ")
        }
        var linkedStrings: [LinkedStrings]?
        if let link = testResult.resultLink, !link.isEmpty {
            let text = "this page"
            descriptionString.append(text)
            let linkedString = LinkedStrings(text: text, link: link)
            linkedStrings = []
            linkedStrings?.append(linkedString)
        }
        do {
            let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
            guard let matches = detector?.matches(in: descriptionString, options: [], range: NSRange(location: 0, length: descriptionString.utf16.count)) else { return (descriptionString, linkedStrings) }
            for match in matches {
                guard let range = Range(match.range, in: descriptionString) else { continue }
                let url = descriptionString[range]
                let linkString = String(url)
                let newLink = LinkedStrings(text: linkString, link: linkString)
                if linkedStrings == nil {
                    linkedStrings = []
                }
                linkedStrings?.append(newLink)
            }
        }
        return (descriptionString, linkedStrings)
    }
}
