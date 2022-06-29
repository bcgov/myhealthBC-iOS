//
//  TestResultRecordDetailView.swift
//  HealthGatewayTest
//
//  Created by Amir on 2022-06-22.
//

import UIKit

class TestResultRecordDetailView: BaseHealthRecordsDetailView, UITableViewDelegate, UITableViewDataSource {
    
    enum Section: Int, CaseIterable {
        case Header
        case Fields
    }
    
    private var fields: [TextListModel] = []
    
    override func setup() {
        tableView?.dataSource = self
        tableView?.delegate = self
        fields = createFields()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = Section(rawValue: section) else {return 0}
        switch section {
        case .Header:
            return 1
        case .Fields:
            return fields.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = Section(rawValue: indexPath.section),  let model = self.model else {return UITableViewCell()}
        switch section {
        case .Header:
            guard let cell = covidTestHeaderCell(indexPath: indexPath, tableView: tableView) else {return UITableViewCell()}
            cell.configure(record: model)
            return cell
        case .Fields:
            guard let cell = textCell(indexPath: indexPath, tableView: tableView) else {return UITableViewCell()}
            cell.setup(with: fields[indexPath.row])
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard section != 0 else {return nil}
        return separatorView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard section != 0 else {return 0}
        return separatorHeight + separatorBottomSpace
    }
}

extension TestResultRecordDetailView {
    private func createFields() -> [TextListModel] {
        guard let model = model else {return []}
        
        switch model.type {
        case .covidTestResultRecord(model: let testResult):
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
        default:
            return []
        }
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
