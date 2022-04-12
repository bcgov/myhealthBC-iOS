//
//  FilterRecordsView.swift
//  BCVaccineCard
//
//  Created by Amir on 2022-03-10.
//

import UIKit

struct RecordsFilter {
    enum RecordType: String, CaseIterable {
        case Medication = "Medications"
        case Covid = "COVID-19"
        case LabTests = "Lab Tests"
        case CovidImmunization = "Immunizations"
    }
    
    var fromDate: Date?
    var toDate: Date?
    var recordTypes: [RecordType] = []
    
    var exists: Bool {
        return fromDate != nil || toDate != nil || !recordTypes.isEmpty
    }
}

protocol FilterRecordsViewDelegate {
    func selected(filter: RecordsFilter)
}

class FilterRecordsView: UIView, Theme {
    
    // MARK: Constants:
    private let datePickerDismissTime: TimeInterval = 2
    private let backdropTag = 24410001
    
    private enum SelectedDatePickerType {
        case fromDate
        case toDate
    }
    
    @IBOutlet weak var navContainer: UIView!
    @IBOutlet weak var navTitle: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var navDivider: UIView!
    
    @IBOutlet weak var chooseFilterTypeLabel: UILabel!
    @IBOutlet weak var filterChipsContainer: UIView!
    @IBOutlet weak var filterTypeDivider: UIView!
    
    @IBOutlet weak var chooseDateRangeLabel: UILabel!
    
    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var fromDateContainer: UIView!
    @IBOutlet weak var fromDateIcon: UIImageView!
    @IBOutlet weak var fromDateLabel: UILabel!
    
    @IBOutlet weak var toLabel: UILabel!
    @IBOutlet weak var toDateContainer: UIView!
    @IBOutlet weak var toDateIcon: UIImageView!
    @IBOutlet weak var toDateLabel: UILabel!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var dateDivider: UIView!
    
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var clearButton: UIButton!
    
    @IBOutlet weak var errorLabel: UILabel!
    
    // MARK: Variables
    var delegate: FilterRecordsViewDelegate? = nil
    var backDrop: UIView? = nil
    
    private var datepickerType: SelectedDatePickerType = .fromDate
    private var datePickerHideTimer: Timer? = nil
    private var currentFilter: RecordsFilter = RecordsFilter()
    private var chipsView: ChipsView? = nil
    
    // MARK: Display
    func showModally(on view: UIView, filter: RecordsFilter?) {
        view.addSubview(self)
        positionView(on: view)
        showRecordTypes()
        style()
        if let existingFilter = filter {
            currentFilter = existingFilter
            populateCurrentFilter()
        }
    }
    
    private func positionView(on view: UIView) {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        self.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0).isActive = true
        self.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        self.topAnchor.constraint(greaterThanOrEqualTo: view.topAnchor, constant: 16).isActive = true
        self.layoutIfNeeded()
    }
    
    private func populateCurrentFilter() {
        if let fromDate = currentFilter.fromDate {
            let dateString = Date.Formatter.yearMonthDay.string(from: fromDate)
            fromDateLabel.text = dateString
        }
        
        if let toDate = currentFilter.toDate {
            let dateString = Date.Formatter.yearMonthDay.string(from: toDate)
            toDateLabel.text = dateString
        }
        showRecordTypes()
    }
    
    func dismiss() {
        if let backDrop = backDrop {
            backDrop.removeFromSuperview()
        }
        self.removeFromSuperview()
    }
    
    // MARK: Outlet Actions
    @IBAction func closeAction(_ sender: Any) {
        dismiss()
    }
    
    @IBAction func continueAction(_ sender: Any) {
        delegate?.selected(filter: currentFilter)
        dismiss()
    }
    
    @IBAction func clearAction(_ sender: Any) {
        currentFilter = RecordsFilter()
        showRecordTypes()
        toDateLabel.text = "yyyy-mm-dd"
        fromDateLabel.text = "yyyy-mm-dd"
        delegate?.selected(filter: currentFilter)
    }
    
    // MARK: Style
    func style() {
        
        self.alpha = 0
        datePicker.maximumDate = Date()
        navContainer.backgroundColor = .clear
        filterChipsContainer.backgroundColor = .clear
        
        navDivider.backgroundColor = AppColours.divider
        filterTypeDivider.backgroundColor = AppColours.divider
        dateDivider.backgroundColor = AppColours.divider
        
        
        navTitle.font = UIFont.bcSansBoldWithSize(size: 17)
        navTitle.textColor = AppColours.appBlue
        
        styleSectionHeading(label: chooseFilterTypeLabel)
        styleSectionHeading(label: chooseDateRangeLabel)
        
        styleFromDate()
        styleToDate()
        
        style(button: clearButton, style: .Hollow, title: "Clear all", image: nil)
        style(button: continueButton, style: .Fill, title: "Apply", image: nil)
        closeButton.setTitle("", for: .normal)
        
        errorLabel.font = UIFont.bcSansRegularWithSize(size: 13)
        errorLabel.textColor = AppColours.appRed
        errorLabel.isHidden = true
        
        let fromDateAction = UITapGestureRecognizer(target: self, action: #selector(fromDateTapped))
        fromDateContainer.isUserInteractionEnabled = true
        fromDateContainer.addGestureRecognizer(fromDateAction)
        
        let toDateAction = UITapGestureRecognizer(target: self, action: #selector(toDateTapped))
        toDateContainer.isUserInteractionEnabled = true
        toDateContainer.addGestureRecognizer(toDateAction)
        datePicker.isHidden = true
        
        self.layer.cornerRadius = 5
        self.layoutIfNeeded()
        UIView.animate(withDuration: 0.1) {[weak self] in
            self?.alpha = 1
            self?.layoutIfNeeded()
        }
        showBackDrop()
    }
    
    private func showBackDrop() {
        guard let parent = self.superview else {return}
        
        if let existing = parent.viewWithTag(backdropTag) {
            existing.removeFromSuperview()
        }
        let backdropView = UIView(frame: .zero)
        backdropView.alpha = 0
        parent.insertSubview(backdropView, belowSubview: self)
        backdropView.tag = backdropTag
        backDrop = backdropView
        backdropView.addEqualSizeContraints(to: parent)
        backdropView.backgroundColor = AppColours.backgroundGray.withAlphaComponent(0.2)
        backdropView.layoutIfNeeded()
        UIView.animate(withDuration: 0.2) {
            backdropView.backgroundColor = AppColours.backgroundGray.withAlphaComponent(0.8)
            backdropView.alpha = 1
            backdropView.layoutIfNeeded()
        }
    }
    
    private func styleSectionHeading(label: UILabel) {
        label.textColor = AppColours.appBlue
        label.font = UIFont.bcSansBoldWithSize(size: 17)
    }
    
    private func styleFromDate() {
        styleDateField(label: fromLabel, valueLabel: fromDateLabel, container: fromDateContainer, icon: fromDateIcon)
    }
    
    private func styleToDate() {
        styleDateField(label: toLabel, valueLabel: toDateLabel, container: toDateContainer, icon: toDateIcon)
    }
    
    private func styleDateField(label: UILabel, valueLabel: UILabel, container: UIView, icon: UIImageView) {
        label.font = UIFont.bcSansRegularWithSize(size: 15)
        label.textColor = AppColours.textBlack
        container.backgroundColor = .clear
        container.layer.borderWidth = 1
        container.layer.masksToBounds = true
        container.layer.borderColor = AppColours.borderGray.cgColor
        container.layer.cornerRadius = 5
        valueLabel.textColor = AppColours.textGray
        valueLabel.font = UIFont.bcSansRegularWithSize(size: 15)
        icon.image = UIImage(named: "calendar-icon")?.withRenderingMode(.alwaysTemplate)
        icon.tintColor = AppColours.borderGray
        valueLabel.isEnabled = false
    }
    
    // MARK: Date
    @objc private func toDateTapped(sender:UITapGestureRecognizer) {
        datepickerType = .toDate
        toLabel.textColor = AppColours.appBlue
        fromLabel.textColor = AppColours.textBlack
        showDatePicker()
    }
    
    @objc private func fromDateTapped(sender:UITapGestureRecognizer) {
        datepickerType = .fromDate
        fromLabel.textColor = AppColours.appBlue
        toLabel.textColor = AppColours.textBlack
        showDatePicker()
    }
    
    private func showDatePicker() {
        datePicker.isHidden = false
        UIView.animate(withDuration: 0.3) {[weak self] in
            self?.layoutIfNeeded()
        }
        resetDatePickerHideTimer()
    }
    
    @objc private func hideDatePicker() {
        datePicker.isHidden = true
        toLabel.textColor = AppColours.textBlack
        fromLabel.textColor = AppColours.textBlack
        UIView.animate(withDuration: 0.3) {[weak self] in
            self?.layoutIfNeeded()
        }
    }
    
    private func resetDatePickerHideTimer() {
        datePickerHideTimer?.invalidate()
        datePickerHideTimer = Timer.scheduledTimer(timeInterval: datePickerDismissTime, target: self, selector: #selector(hideDatePicker), userInfo: nil, repeats: true)
    }
    
    @IBAction func DatePickerEditingEnded(_ sender: Any) {
        resetDatePickerHideTimer()
    }
    @IBAction func datePickerOnTouch(_ sender: Any) {
        resetDatePickerHideTimer()
    }
    
    @IBAction func datePickerOnChange(_ sender: UIDatePicker) {
        resetDatePickerHideTimer()
        let selectedDate = sender.date
        let dateString = Date.Formatter.yearMonthDay.string(from: selectedDate)
        
        if datepickerType == .toDate {
            currentFilter.toDate = selectedDate
            toDateLabel.text = dateString
        } else {
            currentFilter.fromDate = selectedDate
            fromDateLabel.text = dateString
        }
        // Validation
        if let from = currentFilter.fromDate, let to = currentFilter.toDate {
            errorLabel.isHidden = to < from ? false : true
        } else {
            errorLabel.isHidden = true
        }
    }
    
}

// MARK: Record Types
extension FilterRecordsView: ChipsViewDelegate {
    
    private func showRecordTypes() {
        let chipsView: ChipsView = UIView.fromNib()
        filterChipsContainer.subviews.forEach { sub in
            sub.removeFromSuperview()
        }
        filterChipsContainer.addSubview(chipsView)
        chipsView.addEqualSizeContraints(to: filterChipsContainer)
        self.chipsView = chipsView
        var selectedFilters: [String] = []
        selectedFilters = currentFilter.recordTypes.map({$0.rawValue})
       
        chipsView.delegate = self
        chipsView.setup(options: RecordsFilter.RecordType.allCases.map({$0.rawValue}), selected: selectedFilters, direction: .vertical)
    }
    
    func selected(value: String) {
        guard let enumValue = RecordsFilter.RecordType.init(rawValue: value) else {return}
        if !currentFilter.recordTypes.contains(where: {$0 == enumValue}) {
            currentFilter.recordTypes.append(enumValue)
        }
    }
    
    func unselected(value: String) {
        guard let enumValue = RecordsFilter.RecordType.init(rawValue: value) else {return}
        if let existingIndex = currentFilter.recordTypes.firstIndex(of: enumValue) {
            currentFilter.recordTypes.remove(at: existingIndex)
        }
    }
    
}
