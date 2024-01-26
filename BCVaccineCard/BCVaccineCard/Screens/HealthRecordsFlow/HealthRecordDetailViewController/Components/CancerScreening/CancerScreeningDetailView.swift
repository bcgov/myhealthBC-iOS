//
//  CancerScreeningDetailView.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2024-01-25.
//

import UIKit

extension HealthRecordsDetailDataSource.Record {
    fileprivate func cancerScreen() -> CancerScreening? {
        switch self.type {
        case .cancerScreening(let model):
            return model
        default:
            return nil
        }
    }
}

class CancerScreeningDetailView: BaseHealthRecordsDetailView, UITableViewDelegate, UITableViewDataSource {
    
    enum Section: Int, CaseIterable {
        case ViewPDF
        case Fields
        case Links
        case Comments
    }
    
    private var fields: [TextListModel] = []
    
    private var links: [CancerScreeningLinks] = []
    
    struct HeaderSection {
        enum HeaderType {
            case pdf
        }
        
        var pdfPresent: Bool
        
        var headerCount: Int {
            var count = 0
            if pdfPresent {
                count += 1
            }
            return count
        }
    }
    
    var headerSection = HeaderSection(pdfPresent: false)
    
    var hasHeader = true
    
    var numberOrSections: Int {
        // For now, just get PDF working
        return 1
    }
    
    override func setup() {
        tableView?.dataSource = self
        tableView?.delegate = self
        tableView?.register(UINib.init(nibName: CancerScreeningLinkTableViewCell.getName, bundle: .main), forCellReuseIdentifier: CancerScreeningLinkTableViewCell.getName)
        fields = createFields()
        links = createLinks()
        comments = model?.comments.filter({ $0.shouldHide != true }) ?? []
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
        
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = Section(rawValue: section) else {return 0}
        switch section {
        case .ViewPDF:
            return 1
        case .Fields:
            return fields.count
        case .Links:
            return links.count
        case .Comments:
            return comments.count
        }
    }
    // TODO: Clean this part up
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
        case .ViewPDF:
            guard let cell = viewPDFButtonCell(indexPath: indexPath, tableView: tableView) else { return UITableViewCell() }
            let type: AppStyleButton.ButtonType = self.model?.cancerScreen()?.eventType == "Result" ? .viewResults : .viewLetter
            cell.configure(delegateOwner: HealthRecordDetailViewController.currentInstance, style: type)
            return cell
        case .Links:
            guard let cell = cancerLinkCell(indexPath: indexPath, tableView: tableView) else {
                return UITableViewCell()
            }
            cell.configure(text: links[indexPath.row].text, urlString: links[indexPath.row].urlString, delegate: self)
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
    
    private func cancerLinkCell(indexPath: IndexPath, tableView: UITableView) -> CancerScreeningLinkTableViewCell? {
        let cell = tableView.dequeueReusableCell(withIdentifier: CancerScreeningLinkTableViewCell.getName, for: indexPath) as? CancerScreeningLinkTableViewCell
        cell?.selectionStyle = .none
        return cell
    }
}

extension CancerScreeningDetailView: CancerScreeningLinkTableViewCellDelegate {
    func linkTapped(urlString: String) {
        AppDelegate.sharedInstance?.showExternalURL(url: urlString)
    }

}

extension CancerScreeningDetailView {
    
    private func createFields() -> [TextListModel] {
        guard let model = model else {return []}
        switch model.type {
        case .cancerScreening(model: let model):
           
            let firstText = model.eventType == "Result" ? "For more information about your screening results, please contact:" : "Cervix screening (Pap test) can stop at ago 69 if your results have always been normal. Ask your health care provider if you should still be tested. To book your next Pap test, contact your health care provider or a medical clinic.\n\nRelated information"
            
            let firstLinkText = model.eventType == "Result" ? "" : ""
            
            let fields: [TextListModel] = [
                TextListModel(
                    header: TextProperties(text: firstText, bolded: false, fontSize: 15),
                    subtext: nil
                )
            ]
            return fields
        default:
            return []
        }
    }
    
    private func createLinks() -> [CancerScreeningLinks] {
        guard let model = model else {return []}
        switch model.type {
        case .cancerScreening(model: let model):
            
            let firstLink: CancerScreeningLinks = model.eventType == "Result" ? CancerScreeningLinks(text: "BC Cancer", urlString: "http://www.bccancer.bc.ca/contact") : CancerScreeningLinks(text: "What is Cervix screening", urlString: "http://www.bccancer.bc.ca/screening/cervix/get-screened/what-is-cervical-screening")
            
            var links: [CancerScreeningLinks] = [
                firstLink
            ]
            if model.eventType != "Result" {
                let secondLink = CancerScreeningLinks(text: "Find clinics offering screening", urlString: "http://www.bccancer.bc.ca/screening/cervix/clinic-locator")
                links.append(secondLink)
            }
            
            return links
        default:
            return []
        }
    }
}

struct CancerScreeningLinks {
    let text: String
    let urlString: String
}
