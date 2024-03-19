//
//  UsersListOfRecordsViewController.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-11-29.
// TODO: This will be a table view controller with editable cells (for deleting) - nav bar will have same edit/done functionality that covid 19 view controller has

import UIKit
// FIXME: NEED TO LOCALIZE 
class UsersListOfRecordsViewController: BaseViewController {
    
    class func construct(viewModel: ViewModel) -> UsersListOfRecordsViewController {
        if let vc = Storyboard.records.instantiateViewController(withIdentifier: String(describing: UsersListOfRecordsViewController.self)) as? UsersListOfRecordsViewController {
            vc.viewModel = viewModel
            return vc
        }
        return UsersListOfRecordsViewController()
    }
    
    @IBOutlet weak private var listOfRecordsSegmentedView: SegmentedView!
    
    @IBOutlet weak private var noRecordsFoundView: UIView!
    @IBOutlet weak private var noRecordsFoundImageView: UIImageView!
    @IBOutlet weak private var noRecordsFoundTitle: UILabel!
    @IBOutlet weak private var noRecordsFoundSubTitle: UILabel!
    @IBOutlet weak private var noRecordsStackViewVerticalConstraint: NSLayoutConstraint!
    @IBOutlet weak private var bcCancerInfoView: HealthRecordsLearnMoreView!
    @IBOutlet weak private var bcCancerInfoViewHeight: NSLayoutConstraint!
    @IBOutlet weak private var bcCancerInfoViewTop: NSLayoutConstraint!
    @IBOutlet weak private var bcCancerInfoViewBottom: NSLayoutConstraint!
    
    @IBOutlet weak private var clearFiltersButton: UIButton!
    @IBOutlet weak private var filterStack: UIStackView!
    @IBOutlet weak private var filterContainer: UIView!
    @IBOutlet weak private var recordsSearchBarView: RecordsSearchBarView!
    @IBOutlet weak private var tableView: UITableView!
    
    @IBOutlet weak private var createNoteButton: UIButton!

    
    @IBOutlet weak private var parentContainerStackView: UIStackView!
    
    private var refreshDebounceTimer: Timer? = nil
    
    private var viewModel: ViewModel?
    
    private let refreshControl = UIRefreshControl()
    
    private var currentSegment: SegmentType = .Timeline
    
    private var dataSource: [HealthRecordsDetailDataSource] = []
    
    private var dropDownView: NavBarDropDownView?
    private var dropDownViewGestureRecognizer: UITapGestureRecognizer?
    
    private var isDependent: Bool {
        return viewModel?.userType == .Dependent
    }
    
    private var currentFilter: RecordsFilter? = nil {
        didSet {
            if let current = currentFilter, current.exists {
                showSelectedFilters()
                if let patient = viewModel?.patient, let patientName = patient.name {
                    UserFilters.save(filter: current, for: patientName)
                }
            } else {
                hideSelectedFilters()
                if let patient = viewModel?.patient, let patientName = patient.name {
                    UserFilters.removeFilterFor(name: patientName)
                }
            }
        }
    }
    
    private var recordsLearnMoreShownBool: Bool {
//        return self.currentFilter?.recordTypes.count == 1 && ((self.currentFilter?.recordTypes.contains(.CancerScreening)) != false) ? true : false
        let showLearnMore = self.recordsLearnMoreShown(type: .CancerScreening) == .BCCancerScreening || self.recordsLearnMoreShown(type: .DiagnosticImaging) == .DiagnosticImaging
        return showLearnMore
    }
    
    private func recordsLearnMoreShown(type: RecordsFilter.RecordType) -> RecordsLearnMoreTypes {
        guard self.currentFilter?.recordTypes.count == 1 else { return .NotApplicable }
        return ((self.currentFilter?.recordTypes.contains(type)) != false) ? type.getRecordLearnMoreType : .NotApplicable
    }
    
    private var searchText: String?
    
    private var inEditMode = false {
        didSet {
            self.tableView.setEditing(inEditMode, animated: false)
            self.tableView.reloadData()
            navSetup(style: viewModel?.navStyle ?? .singleUser, authenticated: viewModel?.authenticated ?? false)
            self.tableView.layoutSubviews()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSegmentedControl()
        setupRefreshControl()
        self.tableView.keyboardDismissMode = .interactive
        setObservables()
        if let patient = viewModel?.patient,
           let patientName = patient.name,
           let existingFilter = UserFilters.filterFor(name: patientName)
        {
            currentFilter = existingFilter
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
        setup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        applyNotificationFilterIfNeeded()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            return UIStatusBarStyle.darkContent
        } else {
            return UIStatusBarStyle.default
        }
    }
    
    private func setup() {
        setupTableView()
        setupSearchBarView()
        updatePatientIfNecessary()
        navSetup(style: viewModel?.navStyle ?? .singleUser, authenticated: viewModel?.authenticated ?? false)
        showSelectedFilters()
        noRecordsFoundSubTitle.font = UIFont.bcSansRegularWithSize(size: 13)
        noRecordsFoundTitle.font = UIFont.bcSansBoldWithSize(size: 20)
        noRecordsFoundTitle.textColor = AppColours.appBlue
        noRecordsFoundSubTitle.textColor = AppColours.textGray
        noRecordsFoundView.isHidden = true
        configureNoRecords(recordsLearnMore: recordsLearnMoreShownBool)
        createNoteButton.isHidden = true
        fetchDataSource()
        if currentSegment == .Notes {
            // TODO: Update once we have folder structure built
            let patientRecords = fetchPatientRecords(for: .Notes)
            print("CONNOR RECORDS: Notes", patientRecords.count)
            showNotesViews(notesRecordsEmpty: patientRecords.isEmpty, searchText: self.searchText)
            if !patientRecords.isEmpty {
                show(records: patientRecords, searchText: searchText)
            }
        }
    }
    
    private func updatePatientIfNecessary() {
        if viewModel?.patient == nil {
            viewModel?.patient = StorageService.shared.fetchAuthenticatedPatient()
        }
    }
    
    @IBAction func removeFilters(_ sender: Any) {
        currentFilter = nil
        hideSelectedFilters()
        let patientRecords = fetchPatientRecords(for: currentSegment)
        print("CONNOR RECORDS: Remove filters", patientRecords.count)
        show(records: patientRecords, searchText: searchText)
    }
    
    @IBAction private func createNoteButtonTapped(_ sender: UIButton) {
        //TODO: Add to show route with proper ViewModel
        let vc = NoteViewController.construct(for: .AddNote, with: nil, existingNote: nil)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: No Records Config
extension UsersListOfRecordsViewController {
    private func configureNoRecords(recordsLearnMore show: Bool) {
        noRecordsStackViewVerticalConstraint.isActive = !show
        bcCancerInfoViewHeight.constant = show ? 156 : 0
        bcCancerInfoViewTop.constant = show ? 20 : 0
        bcCancerInfoViewBottom.isActive = show
        bcCancerInfoView.isHidden = !show
        self.noRecordsFoundView.layoutIfNeeded()
    }
}

// MARK: Observables
extension UsersListOfRecordsViewController {
    private func setObservables() {
        AppStates.shared.listenToAuth { [weak self] authenticated in
            guard let `self` = self else {return}
            self.setup()
        }
        
        AppStates.shared.listenToStorage { [weak self] event in
            guard let `self` = self else {return}
            guard event.event == .Save else {return}
            self.refreshDebounceTimer?.invalidate()
            self.refreshDebounceTimer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(self.refreshOnStorageUpdate), userInfo: nil, repeats: false)
        }
        
        AppStates.shared.listenToSyncCompletion { [weak self] in
            guard let `self` = self else {return}
            self.setup()
        }
        
        // When a user access this VC via quicklink and a filter is needed
        NotificationCenter.default.addObserver(self, selector: #selector(applyQuickLinkFilter), name: .applyQuickLinkFilter, object: nil)
        // When authentication is expired, reset filters
        Notification.Name.refreshTokenExpired.onPost(object: nil, queue: .main) {[weak self] _ in
            guard let `self` = self else {return}
            self.currentFilter = nil
            self.hideSelectedFilters()
        }
    }
}

// MARK: Refresh Logic
extension UsersListOfRecordsViewController {
    private func refreshLogic() {
        guard NetworkConnection.shared.hasConnection else {
            AppDelegate.sharedInstance?.showToast(message: "No internet connection", style: .Warn)
            refreshControl.endRefreshing()
            return
        }
        if isDependent {
            guard let patient = viewModel?.patient else { return }
            guard let dependent = patient.dependencyInfo else { return }
            HealthRecordsService(network: AFNetwork(), authManager: AuthManager(), configService: MobileConfigService(network: AFNetwork())).fetchAndStore(for: dependent) { [weak self] records, hadFails in
                let message: String = !hadFails ? "Records retrieved" : "Not all records were fetched successfully"
                // Note: Commenting this out due to client request
//                self?.showToast(message: message)
                SessionStorage.dependentRecordsFetched.append(patient)
                self?.refreshControl.endRefreshing()
            }
        } else {
            AppStates.shared.requestSync()
        }
    }
    
    @objc private func refresh(_ sender: AnyObject) {
        refreshLogic()
    }
    
    private func setupRefreshControl() {
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        tableView.isScrollEnabled = true
        tableView.alwaysBounceVertical = true
        tableView.addSubview(refreshControl)
    }
    
}

// MARK: Navigation setup
extension UsersListOfRecordsViewController {
    private func navSetup(style: NavStyle, authenticated: Bool, defaultFirstNameIfFailure: String? = nil, defaultFullNameIfFailure: String? = nil) {
        var buttons: [NavButton] = []
        
        let optionsButton = NavButton(title: nil, image: UIImage(named: "nav-options"), action: #selector(self.showDropDownOptions), accessibility: Accessibility(traits: .button, label: "", hint: ""))
        buttons.append(optionsButton)
        
        let refreshButton = NavButton(title: nil,
                                      image: UIImage(named: "refresh"), action: #selector(self.refresh(_:)),
                                     accessibility: Accessibility(traits: .button, label: "", hint: ""))
        buttons.append(refreshButton)
        
        if style == .singleUser && viewModel?.patient?.dependencyInfo == nil {
            self.navigationItem.setHidesBackButton(true, animated: false)
            
        } else {
            self.navigationItem.setHidesBackButton(false, animated: false)
        }
        
        var name = viewModel?.patient?.name?.nameCase() ?? defaultFullNameIfFailure?.nameCase() ?? ""
        if name.count >= 20 {
            name = viewModel?.patient?.name?.firstName?.nameCase() ?? defaultFirstNameIfFailure?.nameCase() ?? ""
            if name.count >= 20 {
                name = String(name.prefix(20))
            }
        }
        let showLoadingTitle = (viewModel?.patient == nil && viewModel?.authenticated == true)
        if showLoadingTitle {
            name = "Fetching User"
        }
        self.navDelegate?.setNavigationBarWith(title: name,
                                               leftNavButton: nil,
                                               rightNavButtons: buttons,
                                               navStyle: .small,
                                               navTitleSmallAlignment: style == .singleUser && viewModel?.patient?.dependencyInfo == nil ? .Left : .Center,
                                               targetVC: self,
                                               backButtonHintString: nil)
    }
    
    @objc func showDropDownOptions() {
        guard dropDownView == nil else {
            dismissDropDown()
            return
        }
        var dataSource: [NavBarDropDownViewOptions] = []
        if viewModel?.navStyle == .singleUser && viewModel?.patient?.dependencyInfo == nil {
            dataSource.append(.settings)
        } else {
            dataSource.append(.profile)
        }
        
        dropDownView = NavBarDropDownView()
        dropDownView?.addView(delegateOwner: self, dataSource: dataSource, parentView: self.view)
        
        dropDownViewGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissDropDown(_:)))
        if let tap = dropDownViewGestureRecognizer {
            self.recordsSearchBarView.isUserInteractionEnabled = false
            self.parentContainerStackView.addGestureRecognizer(tap)
        }
    }
    
    @objc func dismissDropDown(_ sender: UITapGestureRecognizer? = nil) {
        removeNavDropDownView()
    }
    
    @objc func showSettings() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        goToSettingsScreen()
    }
    
    private func goToSettingsScreen() {
        show(route: .Settings, withNavigation: true)
    }
    
    @objc func dependentSetting() {
        guard let dependent = viewModel?.patient?.dependencyInfo else {
            return
        }
        showDependentProfile(dependent: dependent)
    }
    
    @objc private func doneButton() {
        inEditMode = false
    }
    
    @objc private func editButton() {
        tableView.isEditing = false
        inEditMode = true
    }
}

// MARK: Segmented Control Delegate
extension UsersListOfRecordsViewController: SegmentedViewDelegate {
    
    private func setupSegmentedControl() {
        guard HealthRecordConstants.notesEnabled else {
            listOfRecordsSegmentedView.isHidden = true
            return
        }
        if (Defaults.enabledTypes?.contains(dataset: .Note) == true), viewModel?.userType != .Dependent {
            listOfRecordsSegmentedView.isHidden = false
            listOfRecordsSegmentedView.configure(delegateOwner: self, dataSource: [.Timeline, .Notes])
        } else {
            listOfRecordsSegmentedView.isHidden = true
        }
    }
    
    func segmentSelected(type: SegmentType) {
        currentSegment = type
        var patientRecords = fetchPatientRecords(for: currentSegment)
        print("CONNOR RECORDS: segment selected: ", type, patientRecords.count)
        if let searchText = searchText, searchText.trimWhiteSpacesAndNewLines.count > 0 {
            patientRecords = patientRecords.filter({ $0.title.lowercased().range(of: searchText.lowercased()) != nil })
        }
        switch type {
        case .Timeline:
            showTimelineViews(patientRecordsEmpty: patientRecords.isEmpty, searchText: searchText)
            show(records: patientRecords, filter: currentFilter, searchText: searchText)
        case .Notes:
            // TODO: Will need to have some sort of check here, basically just fetch records and filter for notes - for now, just show empty state
            showNotesViews(notesRecordsEmpty: patientRecords.isEmpty, searchText: searchText)
            show(records: patientRecords, searchText: searchText)
        }
    }
}


// MARK: Show Dependent Info
extension UsersListOfRecordsViewController {
    func showDependentProfile(dependent: Dependent) {
        let vm = ProfileDetailsViewController.ViewModel(type: .DependentProfile(dependent: dependent))
        show(route: .Profile, withNavigation: true, viewModel: vm)
    }
}

// MARK: Drop down view
extension UsersListOfRecordsViewController: NavBarDropDownViewDelegate {
    func optionSelected(_ option: NavBarDropDownViewOptions) {
        switch option {
        case .refresh:
            refreshLogic()
            
        case .profile:
            dependentSetting()
            
        case .settings:
            showSettings()
        }
        removeNavDropDownView()
    }
    
    private func removeNavDropDownView() {
        if let tap = dropDownViewGestureRecognizer {
            self.parentContainerStackView.removeGestureRecognizer(tap)
        }
        dropDownViewGestureRecognizer = nil
        dropDownView?.removeView()
        dropDownView = nil
        self.recordsSearchBarView.isUserInteractionEnabled = true
    }
    
    
}

// MARK: Search Bar
extension UsersListOfRecordsViewController: RecordsSearchBarViewDelegate {
    func setupSearchBarView() {
        recordsSearchBarView.configure(delegateOwner: self)
    }
    
    func searchButtonTapped(text: String) {
        let patientRecords = fetchPatientRecords(for: currentSegment)
        print("CONNOR RECORDS: Search button tapped", patientRecords.count)
        self.recordsSearchBarView.endEditing(true)
        show(records: patientRecords, filter: currentFilter, searchText: searchText)
    }
    
    func textDidChange(text: String?) {
        searchText = text
        if searchText == nil || searchText?.trimWhiteSpacesAndNewLines.count == 0 {
            let patientRecords = fetchPatientRecords(for: currentSegment)
            print("CONNOR RECORDS: Search text did change", patientRecords.count)
            show(records: patientRecords, filter: currentFilter, searchText: searchText)
        }
    }
    
    func filterButtonTapped() {
        showFilters()
    }
}

// MARK: Filters
extension UsersListOfRecordsViewController: FilterRecordsViewDelegate {
    
    @objc func showFilters() {
        let allFilters = RecordsFilter.RecordType.avaiableFilters
        let dependentFilters: [RecordsFilter.RecordType] = RecordsFilter.RecordType.dependentFilters

        let vm = FilterRecordsViewController.ViewModel(currentFilter: currentFilter, availableFilters: isDependent ? dependentFilters : allFilters, delegateOwner: self)        
        show(route: .FilterRecordsView, withNavigation: true, viewModel: vm)
    }
    
    func selected(filter: RecordsFilter) {
        let patientRecords = fetchPatientRecords(for: currentSegment)
        print("CONNOR RECORDS: Filter selected", patientRecords.count)
        currentFilter = filter
        show(records: patientRecords, filter:filter, searchText: searchText)
    }
    
    func dismiss() {
        // ignore - should find a better way to do this
    }
    
    func showSelectedFilters() {
        clearFiltersButton.setImage(UIImage(named: "close-circle"), for: .normal)
        guard let current = currentFilter, current.exists else {
            hideSelectedFilters()
            return
        }
        
        let chipsView: ChipsView = UIView.fromNib()
        filterContainer.subviews.forEach { sub in
            sub.removeFromSuperview()
        }
        filterStack.isHidden = false
        filterContainer.addSubview(chipsView)
        chipsView.addEqualSizeContraints(to: filterContainer)
        var selectedFilters: [String] = []
        
        
        var fromDateText = ""
        if let startDate = current.fromDate {
            fromDateText = startDate.issuedOnDate
        }
        
        var toDateText = ""
        if let endDate = current.toDate {
            toDateText = endDate.issuedOnDate
        }
        
        var dateFilter = ""
        if current.fromDate != nil || current.toDate != nil {
            if current.fromDate != nil && current.toDate != nil {
                dateFilter = "\(fromDateText) - \(toDateText)"
            } else if current.fromDate == nil && current.toDate != nil {
                dateFilter = "\(toDateText) and before"
            } else if current.fromDate != nil && current.toDate == nil {
                dateFilter = "\(fromDateText) and after"
            }
            
            selectedFilters.append(dateFilter)
        }
        
        selectedFilters += current.recordTypes.map({$0.rawValue})
        
        chipsView.setup(options: selectedFilters, selected: [], direction: .horizontal, selectable: false)
    }
    
    func hideSelectedFilters() {
        filterContainer.subviews.forEach { sub in
            sub.removeFromSuperview()
        }
        filterStack.isHidden = true
    }
    
    @objc private func applyQuickLinkFilter(_ notification: Notification) {
        guard let userInfo = notification.userInfo as? [String: RecordsFilter] else { return }
        guard let filter = userInfo["filter"] else { return }
        currentSegment = filter.recordTypes.contains(.Notes) ? .Notes : .Timeline
        let patientRecords = fetchPatientRecords(for: currentSegment)
        print("CONNOR RECORDS: apply quick link filter", patientRecords.count)
        currentFilter = filter
        if filter.recordTypes.contains(.Notes) {
            listOfRecordsSegmentedView.setSegmentedControl(forType: .Notes)
            showNotesViews(notesRecordsEmpty: patientRecords.isEmpty, searchText: nil)
        } else {
            listOfRecordsSegmentedView.setSegmentedControl(forType: .Timeline)
            showTimelineViews(patientRecordsEmpty: patientRecords.isEmpty, searchText: nil)
        }
        show(records: patientRecords, filter:filter, searchText: nil)
        
    }
    
    private func applyNotificationFilterIfNeeded() {
        guard let category = SessionStorage.notificationCategoryFilter
        else {
            return
        }
        let filterType = category.toLocalFilter()
        
        SessionStorage.notificationCategoryFilter = nil
        self.selected(filter: RecordsFilter(recordTypes: [filterType]))
    }
}

// MARK: Data Source Setup
extension UsersListOfRecordsViewController {
    
    private func fetchDataSource(initialProtectedMedFetch: Bool = false) {
        guard let vm = self.viewModel else {
            return
        }
        switch vm.state {
        case .AuthExpired:
            showAuthExpired()
            recordsSearchBarView.isHidden = true
            listOfRecordsSegmentedView.isHidden = true
        case .authenticated:
            setupSegmentedControl()
            // TODO: Maybe remove this, and just fetch patient records anyways?
            guard self.dataSource.count == 0 else {
                print("CONNOR RECORDS: Records not fetched here due to records already existing", self.dataSource.count)
                show(records: self.dataSource, filter: currentFilter, searchText: searchText)
                return
            }
            let patientRecords = fetchPatientRecords(for: currentSegment)
            print("CONNOR RECORDS: fetch data source", patientRecords.count)
            show(records: patientRecords, filter: currentFilter, searchText: searchText)
        }
    }
    
    private func fetchPatientRecords(for segment: SegmentType) -> [HealthRecordsDetailDataSource] {
        guard let patient = viewModel?.patient else {return []}
        let records = StorageService.shared.getRecords(for: patient)
        // TODO: Add filter here for displaying
        var patientRecords = records.detailDataSource(patient: patient).filter { $0.mainRecord?.displayable == true }
        if segment == .Timeline {
            patientRecords = patientRecords.filter({ dataSource in
                switch dataSource.type {
                case .note(model: let model):
                    return model.addedToTimeline == true
                default: return true
                }
            })
        } else if segment == .Notes {
            patientRecords = patientRecords.filter({ dataSource in
                switch dataSource.type {
                case .note: return true
                default: return false
                }
            })
        }
        return patientRecords
    }
    
    func showAuthExpired() {
        tableView.reloadData()
    }
    
    private func show(records: [HealthRecordsDetailDataSource], filter: RecordsFilter? = nil, searchText: String?) {
        var patientRecords: [HealthRecordsDetailDataSource] = records
        if let searchText = searchText, searchText.trimWhiteSpacesAndNewLines.count > 0 {
            patientRecords = patientRecords.filter({ $0.title.lowercased().range(of: searchText.lowercased()) != nil })
        }
        if let filter = filter {
            patientRecords = patientRecords.filter({ item in
                var showItem = true
                // Filter by type
                if !filter.recordTypes.isEmpty {
                    switch item.type {
                    case .covidImmunizationRecord:
                        showItem = filter.recordTypes.contains(.Immunizations)
                    case .covidTestResultRecord:
                        showItem = filter.recordTypes.contains(.Covid)
                    case .medication:
                        showItem = filter.recordTypes.contains(.Medication)
                    case .laboratoryOrder:
                        showItem = filter.recordTypes.contains(.LabTests)
                    case .immunization:
                        showItem = filter.recordTypes.contains(.Immunizations)
                    case .healthVisit:
                        showItem = filter.recordTypes.contains(.HeathVisits)
                    case .specialAuthorityDrug:
                        showItem = filter.recordTypes.contains(.SpecialAuthorityDrugs)
                    case .hospitalVisit:
                        showItem = filter.recordTypes.contains(.HospitalVisits)
                    case .clinicalDocument:
                        showItem = filter.recordTypes.contains(.ClinicalDocuments)
                    case .diagnosticImaging:
                        showItem = filter.recordTypes.contains(.DiagnosticImaging)
                    case .cancerScreening:
                        showItem = filter.recordTypes.contains(.CancerScreening)
                    case .note:
                        showItem = filter.recordTypes.contains(.Notes)
                    }
                }
                // Filter by date
                if let dateString = item.mainRecord?.date,
                   let recordDate = Date.Formatter.monthDayYearDate.date(from: dateString),
                   let timeNeutralDate = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: recordDate)
                {
                    if let fromDate = filter.fromDate, timeNeutralDate < fromDate {
                        showItem = false
                    }
                    if let toDate = filter.toDate, timeNeutralDate > toDate {
                        showItem = false
                    }
                    
                }
                
                return showItem
            })
            tableView.reloadData()
        }
        
        if viewModel?.protectiveWordRequired == true {
            dataSource = patientRecords.filter({!$0.containsProtectedWord})
        } else {
            dataSource = patientRecords
        }
        
        navSetup(style: viewModel?.navStyle ?? .singleUser, authenticated: viewModel?.authenticated ?? false)
        
        tableView.reloadData()
        noRecordsFoundView.isHidden = !patientRecords.isEmpty
        if patientRecords.isEmpty {
            configureNoRecords(recordsLearnMore: self.recordsLearnMoreShownBool)
        }
        tableView.isHidden = patientRecords.isEmpty
        recordsSearchBarView.isHidden = (((patientRecords.isEmpty || !HealthRecordConstants.searchRecordsEnabled) && !(searchText?.trimWhiteSpacesAndNewLines.count ?? 0 > 0)))
    }
    
    private func configureNoRecordsFoundView(for segment: SegmentType) {
        let isTimeline = segment == .Timeline
        noRecordsFoundImageView.image = isTimeline ? UIImage(named: "no-records-found") : UIImage(named: "no-notes")
        noRecordsFoundTitle.text = isTimeline ? "No records found" : "No Note Yet?"
        noRecordsFoundSubTitle.text = isTimeline ? "Clear all filters and start over" : "Start adding a note by tapping\n the 'Note' button below"
    }
    
    // MARK: Use these functions to switch between the view types, health records and notes
    private func showTimelineViews(patientRecordsEmpty: Bool, searchText: String?) {
        configureNoRecordsFoundView(for: .Timeline)
        noRecordsFoundView.isHidden = !patientRecordsEmpty
        if patientRecordsEmpty {
            configureNoRecords(recordsLearnMore: self.recordsLearnMoreShownBool)
        }
        tableView.isHidden = patientRecordsEmpty
        recordsSearchBarView.hideFilterSection = false
        recordsSearchBarView.isHidden = (((patientRecordsEmpty || !HealthRecordConstants.searchRecordsEnabled) && !(searchText?.trimWhiteSpacesAndNewLines.count ?? 0 > 0)))
        createNoteButton.isHidden = true
    }
    
    private func showNotesViews(notesRecordsEmpty: Bool, searchText: String?) {
        configureNoRecordsFoundView(for: .Notes)
        noRecordsFoundView.isHidden = notesRecordsEmpty
        if !notesRecordsEmpty {
            configureNoRecords(recordsLearnMore: self.recordsLearnMoreShownBool)
        }
        tableView.isHidden = !notesRecordsEmpty
        recordsSearchBarView.endEditing(true)
        recordsSearchBarView.isHidden = (((notesRecordsEmpty || !HealthRecordConstants.searchRecordsEnabled) && !(searchText?.trimWhiteSpacesAndNewLines.count ?? 0 > 0)))
        if !notesRecordsEmpty {
            recordsSearchBarView.hideFilterSection = true
        }
        createNoteButton.isHidden = false
    }
    
    private func performBCSCLogin() {
        showLogin(initialView: .Auth)
    }
    
    @objc private func patientAPIFetched(_ notification: Notification) {
        let userInfo = notification.userInfo as? [String: String]
        let firstName = userInfo?["firstName"]
        let fullName = userInfo?["fullName"]
        guard viewModel?.patient == nil else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.viewModel?.patient = StorageService.shared.fetchAuthenticatedPatient()
            self?.navSetup(style: self?.viewModel?.navStyle ?? .singleUser, authenticated: self?.viewModel?.authenticated ??  false, defaultFirstNameIfFailure: firstName, defaultFullNameIfFailure: fullName)
        }
    }
}

// MARK: TableView setup
extension UsersListOfRecordsViewController: UITableViewDelegate, UITableViewDataSource {
    private func setupTableView() {
        tableView.register(UINib.init(nibName: UserRecordListTableViewCell.getName, bundle: .main), forCellReuseIdentifier: UserRecordListTableViewCell.getName)
        tableView.register(UINib.init(nibName: HiddenRecordsTableViewCell.getName, bundle: .main), forCellReuseIdentifier: HiddenRecordsTableViewCell.getName)
        tableView.register(UINib.init(nibName: HealthRecordsLearnMoreTableViewCell.getName, bundle: .main), forCellReuseIdentifier: HealthRecordsLearnMoreTableViewCell.getName)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 84
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // Auth expired dialog
        if viewModel?.state == .AuthExpired {
            return 1
        }
        
        let protectiveWordCount: Int = viewModel?.showProtectiveWordPrompt == true ? 1 : 0
        let recordsLearnMoreCount: Int = self.recordsLearnMoreShownBool == true ? 1 : 0
//        // Protective word not entered
//        if viewModel?.showProtectiveWordPrompt == true {
//            return 2
//        }
        
        return 1 + protectiveWordCount + recordsLearnMoreCount
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Auth expired dialog
        if viewModel?.state == .AuthExpired {
            return 1
        }
        
        if viewModel?.state == .authenticated,
           viewModel?.showProtectiveWordPrompt == true,
           section == 0 {
           return 1
        }
    
        if viewModel?.state == .authenticated,
           recordsLearnMoreShownBool == true {
            if viewModel?.showProtectiveWordPrompt == true,
               section == 1 {
                return 1
            }
            if viewModel?.showProtectiveWordPrompt == false,
               section == 0 {
                return 1
            }
        }

        
        // Records
        return dataSource.count
    }
    
    private func recordCell(indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: UserRecordListTableViewCell.getName, for: indexPath) as? UserRecordListTableViewCell else {
            return UITableViewCell()
        }
        cell.configure(record: dataSource[indexPath.row])
        return cell
    }
    
    private func getProtectiveWordCell(indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HiddenRecordsTableViewCell.getName, for: indexPath) as? HiddenRecordsTableViewCell else {
            return UITableViewCell()
        }
        cell.configure(forRecordType: .medicalRecords) { [weak self] _ in
            guard let `self` = self else { return }
            self.promoptProtectedWord()
        }
        return cell
    }
    
    private func getLoginCell(indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HiddenRecordsTableViewCell.getName, for: indexPath) as? HiddenRecordsTableViewCell else {
            return UITableViewCell()
        }
        cell.configure(forRecordType: .loginToAccesshealthRecords(hiddenRecords: 0)) { [weak self] _ in
            guard let `self` = self else { return }
            self.performBCSCLogin()
        }
        return cell
    }
    
    private func getRecordsLearnMoreCell(indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: HealthRecordsLearnMoreTableViewCell.getName, for: indexPath) as? HealthRecordsLearnMoreTableViewCell else {
            return UITableViewCell()
        }
        if let type = self.currentFilter?.recordTypes.first {
            let learnMoreType = recordsLearnMoreShown(type: type)
            cell.configure(type: learnMoreType)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if viewModel?.state == .AuthExpired {
            return getLoginCell(indexPath: indexPath)
        }
        if viewModel?.showProtectiveWordPrompt == true, indexPath.section == 0 {
            return getProtectiveWordCell(indexPath: indexPath)
        }
        
        if (viewModel?.showProtectiveWordPrompt == true && recordsLearnMoreShownBool && indexPath.section == 1) || (viewModel?.showProtectiveWordPrompt == false && recordsLearnMoreShownBool && indexPath.section == 0) {
            return getRecordsLearnMoreCell(indexPath: indexPath)
        }
        return recordCell(indexPath: indexPath)
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (viewModel?.showProtectiveWordPrompt == true && indexPath.section == 0) ||
            (viewModel?.showProtectiveWordPrompt == true && recordsLearnMoreShownBool && indexPath.section == 1) || (viewModel?.showProtectiveWordPrompt == false && recordsLearnMoreShownBool && indexPath.section == 0) {
            return
        }
        guard dataSource.count > indexPath.row else {return}
        let ds = dataSource[indexPath.row]
        let vm = HealthRecordDetailViewController.ViewModel(dataSource: ds,
                                                            authenticatedRecord: ds.isAuthenticated,
                                                            userNumberHealthRecords: dataSource.count,
                                                            patient: viewModel?.patient)
        switch ds.type {
        case .note(model: let model):
            let note = PostNote(title: model.title ?? "", text: model.text ?? "", journalDate: model.journalDate?.yearMonthDayString ?? Date().yearMonthDayString, addedToTimeline: model.addedToTimeline)
            let vc = NoteViewController.construct(for: .ViewNote, with: note, existingNote: model)
            self.navigationController?.pushViewController(vc, animated: true)
        default:
            show(route: .HealthRecordDetail, withNavigation: true, viewModel: vm)
        }
        
    }
    
}

// MARK: Protected word
extension UsersListOfRecordsViewController: ProtectiveWordPromptDelegate {
    
    private func promoptProtectedWord() {
        let firstFetch = AuthManager().protectiveWord == nil
        self.showProtectedWordDialog(delegate: self, purpose: firstFetch ? .initialFetch : .viewingRecords)
    }
    
    func protectiveWordProvided(string: String) {
        let firstFetch = AuthManager().protectiveWord == nil
        SessionStorage.protectiveWordEnteredThisSession = string
        if !firstFetch {
            viewProtectedRecords(protectiveWord: string)
        } else {
            fetchProtectedRecords(protectiveWord: string)
        }
    }
    
    private func protectedWordFailedPromptAgain() {
        alert(title: .error, message: .protectedWordAlertError, buttonOneTitle: .yes, buttonOneCompletion: {
            self.promoptProtectedWord()
        }, buttonTwoTitle: .no) {}
    }
    
    private func viewProtectedRecords(protectiveWord: String) {
        if protectiveWord.lowercased() == AuthManager().protectiveWord?.lowercased() {
            SessionStorage.protectiveWordEnteredThisSession = protectiveWord
            let patientRecords = fetchPatientRecords(for: currentSegment)
            print("CONNOR RECORDS: view protected records", patientRecords.count)
            show(records: patientRecords, filter: currentFilter, searchText: searchText)
        } else {
            alert(title: .error, message: .protectedWordAlertError, buttonOneTitle: .yes, buttonOneCompletion: {
                self.promoptProtectedWord()
            }, buttonTwoTitle: .no) {
                // Do nothing
            }
        }
    }
    
    private func fetchProtectedRecords(protectiveWord: String) {
        guard let patient = viewModel?.patient else {return}
        MedicationService(network: AFNetwork(), authManager: AuthManager(), configService: MobileConfigService(network: AFNetwork())).fetchAndStore(for: patient, protectiveWord: protectiveWord) { records, protectiveWordRequird  in
            guard let records = records else {
                return
            }
            if protectiveWordRequird {
                self.protectedWordFailedPromptAgain()
            } else if !records.isEmpty {
                CommentService(network: AFNetwork(), authManager: AuthManager(), configService: MobileConfigService(network: AFNetwork())).fetchAndStore(for: patient) { _ in
                }
                AuthManager().storeProtectiveWord(protectiveWord: protectiveWord)
            }
        }
    }
}

// MARK: Sync completed, reload data
extension UsersListOfRecordsViewController {
    @objc private func refreshOnStorageUpdate() {
        let patientRecords = fetchPatientRecords(for: currentSegment)
        print("CONNOR RECORDS: Refresh on storage update called", patientRecords.count)
        show(records: patientRecords, filter: currentFilter, searchText: searchText)
        if currentSegment == .Notes {
            showNotesViews(notesRecordsEmpty: patientRecords.isEmpty, searchText: self.searchText)
            show(records: patientRecords, filter: nil, searchText: searchText)
        }
    }
}
