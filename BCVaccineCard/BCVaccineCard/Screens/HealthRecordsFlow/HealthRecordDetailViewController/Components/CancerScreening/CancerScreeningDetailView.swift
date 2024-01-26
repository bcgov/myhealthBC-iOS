//
//  CancerScreeningDetailView.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2024-01-25.
//
// TODO: Complete this
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
    }
    
    private var fields: [[TextListModel]] = [[]]
    
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
//        fields = createFields()
        comments = model?.comments.filter({ $0.shouldHide != true }) ?? []
    }
    
//    override func submittedComment(object: Comment) {
//        comments.append(object)
//        tableView?.reloadData()
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: { [weak self] in
//            let row = (self?.comments.count ?? 0) - 1
//            guard row >= 0, let numberOfSections = self?.numberOrSections else { return }
//            let indexPath = IndexPath(row: row, section: numberOfSections - 1)
//            self?.tableView?.scrollToRow(at: indexPath, at: .bottom, animated: true)
//        })
//    }
        
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return numberOrSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    // TODO: Clean this part up
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = Section(rawValue: indexPath.section), let model = self.model else {return UITableViewCell()}
        switch section {
        case .ViewPDF:
            guard let cell = viewPDFButtonCell(indexPath: indexPath, tableView: tableView) else { return UITableViewCell() }
            let type: AppStyleButton.ButtonType = self.model?.cancerScreen()?.eventType == "Result" ? .viewResults : .viewLetter
            cell.configure(delegateOwner: HealthRecordDetailViewController.currentInstance, style: type)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        if section == numberOrSections - 1, let model = self.model {
//            let headerView: TableSectionHeader = TableSectionHeader.fromNib()
//            guard !model.comments.isEmpty else {
//                headerView.configure(text: "")
//                return headerView
//            }
//            let commentsString = model.comments.count == 1 ? "Comment" : "Comments"
//            headerView.configure(text: "\(model.comments.count) \(commentsString)",colour: AppColours.appBlue, delegate: self)
//            headerView.backgroundColor = .white
//            return headerView
//        }
        guard section != 0 else {return nil}
        return separatorView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        if section == numberOrSections - 1, let model = self.model {
//            guard !model.comments.isEmpty else {
//                return 0
//            }
//            return "Comments".heightForView(font: TableSectionHeader.font, width: bounds.width) + 10
//        }
        guard section != 0 else {return 0}
        return separatorHeight + separatorBottomSpace
    }
}
