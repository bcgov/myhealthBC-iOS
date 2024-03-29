//
//  DiagnosticImagingDetailView.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2023-05-23.
//
// FIXME: NEED TO LOCALIZE 
import UIKit

class DiagnosticImagingDetailView: BaseHealthRecordsDetailView, UITableViewDelegate, UITableViewDataSource {
    
    enum Section: Int, CaseIterable {
        case DownloadButton
        case Fields
        case Info
        case Comments
    }
    
    private var fields: [TextListModel] = []
    
    override func setup() {
        tableView?.dataSource = self
        tableView?.delegate = self
        tableView?.register(UINib.init(nibName: DiagnosticImagingInfoTableViewCell.getName, bundle: .main), forCellReuseIdentifier: DiagnosticImagingInfoTableViewCell.getName)
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
        case .DownloadButton:
            return showAndHideDownloadButton()
        case .Fields:
            return fields.count
        case .Info:
            return 1
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
        case .DownloadButton:
            guard let cell = viewPDFButtonCell(indexPath: indexPath, tableView: tableView) else { return UITableViewCell() }
            cell.configure(delegateOwner: HealthRecordDetailViewController.currentInstance, style: .downloadFullReport)
            return cell
        case .Info:
            guard let cell = infoCell(indexPath: indexPath, tableView: tableView) else {
                return UITableViewCell()
            }
            cell.setup(delegate: self)
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
    
    public func infoCell(indexPath: IndexPath, tableView: UITableView) -> DiagnosticImagingInfoTableViewCell? {
        let cell = tableView.dequeueReusableCell(withIdentifier: DiagnosticImagingInfoTableViewCell.getName, for: indexPath) as? DiagnosticImagingInfoTableViewCell
        cell?.selectionStyle = .none
        return cell
    }
    
}

extension DiagnosticImagingDetailView: DiagnosticImagingInfoTableViewCellDelegate {
    func openLink(type: DiagnosticImagingInfoTableViewCell.Link) {
        switch type {
        case .HealthLinkBC:
            AppDelegate.sharedInstance?.showExternalURL(url: "https://www.healthlinkbc.ca/tests-treatments-medications/medical-tests")
        case .BCRadiologicalSociety:
            AppDelegate.sharedInstance?.showExternalURL(url: "https://bcradiology.ca/patient-resources/")
        }
    }
    
    
}

extension DiagnosticImagingDetailView {
    private func showAndHideDownloadButton() -> Int {
        guard let model = model else { return 0 }
        switch model.type {
        case .diagnosticImaging(model: let model):
            if let fileID = model.fileID, !fileID.isEmpty {
                return 1
            } else  {
                return 0
            }
        default: return 0
        }
    }
    
    private func createFields() -> [TextListModel] {
        guard let model = model else {return []}
        switch model.type {
        case .diagnosticImaging(model: let model):
           
            
            let fields: [TextListModel] = [
//                TextListModel(
//                    header: TextProperties(text: "Body Part:", bolded: true),
//                    subtext: TextProperties(text: model.bodyPart ?? "", bolded: false)
//                ),
                TextListModel(
                    header: TextProperties(text: "Procedure Description:", bolded: true),
                    subtext: TextProperties(text: model.procedureDescription ?? "", bolded: false)
                ),
                TextListModel(
                    header: TextProperties(text: "Health Authority:", bolded: true),
                    subtext: TextProperties(text: model.healthAuthority ?? "", bolded: false)
                ),
                TextListModel(
                    header: TextProperties(text: "Status:", bolded: true),
                    subtext: TextProperties(text: model.examStatus ?? "", bolded: false)
                ),
//                TextListModel(
//                    header: TextProperties(text: "Facility:", bolded: true),
//                    subtext: TextProperties(text: model.organization ?? "", bolded: false)
//                )
            ]
            return fields
        default:
            return []
        }
    }
}
