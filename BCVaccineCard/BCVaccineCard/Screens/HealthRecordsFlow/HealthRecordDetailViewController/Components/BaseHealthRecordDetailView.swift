//
//  BaseHealthRecordsDetailView.swift
//  HealthGatewayTest
//
//  Created by Amir on 2022-06-25.
//

import UIKit

class BaseHealthRecordsDetailView: UIView {
    
    public var tableView: UITableView?
    public var model: HealthRecordsDetailDataSource.Record?
    
    public var comments: [Comment] = [] {
        didSet {
            // Only show the last comment
            if comments.count > 1, let last = comments.last {
                comments = [last]
            }
        }
    }
    
    private var delegate: HealthRecordDetailDelegate?
    private var commentsEnabled: Bool = false
    private var stackViewBottomAnchor: NSLayoutConstraint? = nil
    private var stackViewBottomKeyboardAnchor: NSLayoutConstraint? = nil
    private weak var stackView: UIStackView? = nil
    
    let separatorHeight: CGFloat = 1
    let separatorBottomSpace: CGFloat = 12
    let commentFieldHeight: CGFloat = 96
    
    
    func setup(model: HealthRecordsDetailDataSource.Record, enableComments: Bool, delegate: HealthRecordDetailDelegate) {
        self.delegate = delegate
        self.model = model
        self.commentsEnabled = enableComments
        creatSubViews(enableComments: enableComments)
        setup()
        setupKeyboardListener()
    }
    
    func setup() {}
    
    func submittedComment(object: Comment){}
    
    public func creatSubViews(enableComments: Bool) {
        let tableView = UITableView(frame: .zero)
        addSubview(tableView)
        
        let stackView = UIStackView(frame: .zero)
        self.stackView = stackView
        addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
        stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0).isActive = true
        stackView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        
        let bottomAnchor = stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0)
        stackViewBottomAnchor = bottomAnchor
        bottomAnchor.isActive = true
        
        stackView.distribution = .fill
        stackView.spacing = 0
        stackView.alignment = .fill
        stackView.axis = .vertical
        
        // Tableview needs padding, so we have to add it in a subview
        let tableContainer = UIView(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height))
        stackView.addArrangedSubview(tableContainer)
        
        tableContainer.addSubview(tableView)
        tableView.addEqualSizeContraints(to: tableContainer, paddingVertical: 0, paddingHorizontal: 20)
        
        // Add comment field if needed
        if enableComments {
            let commentTextField: CommentTextFieldView = CommentTextFieldView.fromNib()
            commentTextField.heightAnchor.constraint(equalToConstant: commentFieldHeight).isActive = true
            stackView.addArrangedSubview(commentTextField)
            commentTextField.setup()
            commentTextField.delegate = self
        }
        
        self.tableView = tableView
        setupTableView()
    }
    
    public func separatorView() -> UIView {
        let separatorContainer = UIView()
        let separator = UIView()
        separatorContainer.addSubview(separator)
        separator.place(in: separatorContainer, paddingBottom: separatorBottomSpace, height: separatorHeight)
        separator.backgroundColor = UIColor(red: 0.812, green: 0.812, blue: 0.812, alpha: 1)
        separator.layer.cornerRadius = 4
        return separatorContainer
    }
    
    private func setupTableView() {
        guard let tableView = tableView else {
            return
        }
        
        tableView.register(UINib.init(nibName: MessageBannerTableViewCell.getName, bundle: .main), forCellReuseIdentifier: MessageBannerTableViewCell.getName)
        
        tableView.register(UINib.init(nibName: HealthRecordDetailFieldTableViewCell.getName, bundle: .main), forCellReuseIdentifier: HealthRecordDetailFieldTableViewCell.getName)
        
        tableView.register(UINib.init(nibName: CommentViewTableViewCell.getName, bundle: .main), forCellReuseIdentifier: CommentViewTableViewCell.getName)
        
        tableView.register(UINib.init(nibName: SectionDescriptionTableViewCell.getName, bundle: .main), forCellReuseIdentifier: SectionDescriptionTableViewCell.getName)
        
        tableView.register(UINib.init(nibName: ViewPDFTableViewCell.getName, bundle: .main), forCellReuseIdentifier: ViewPDFTableViewCell.getName)
        
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.showsVerticalScrollIndicator = false
        if Device.IS_IPHONE_5 || Device.IS_IPHONE_4 {
            tableView.estimatedRowHeight = 1000
        } else {
            tableView.estimatedRowHeight = 600
        }
        
        tableView.allowsSelection = false
        tableView.separatorStyle = .none
        tableView.separatorInset = .zero
        self.tableView = tableView
    }
    
    
    public func messageHeaderCell(indexPath: IndexPath, tableView: UITableView) -> MessageBannerTableViewCell? {
        return tableView.dequeueReusableCell(withIdentifier: MessageBannerTableViewCell.getName, for: indexPath) as? MessageBannerTableViewCell
    }
    
    public func viewPDFButtonCell(indexPath: IndexPath, tableView: UITableView) -> ViewPDFTableViewCell? {
        return tableView.dequeueReusableCell(withIdentifier: ViewPDFTableViewCell.getName, for: indexPath) as? ViewPDFTableViewCell
    }
    
    public func commentCell(indexPath: IndexPath, tableView: UITableView) -> CommentViewTableViewCell? {
        return tableView.dequeueReusableCell(withIdentifier: CommentViewTableViewCell.getName, for: indexPath) as? CommentViewTableViewCell
    }
    
    public func sectionDescriptionCell(indexPath: IndexPath, tableView: UITableView) -> SectionDescriptionTableViewCell? {
        return tableView.dequeueReusableCell(withIdentifier: SectionDescriptionTableViewCell.getName, for: indexPath) as? SectionDescriptionTableViewCell
    }
    
    public func textCell(indexPath: IndexPath, tableView: UITableView) -> HealthRecordDetailFieldTableViewCell? {
        return tableView.dequeueReusableCell(withIdentifier: HealthRecordDetailFieldTableViewCell.getName, for: indexPath) as? HealthRecordDetailFieldTableViewCell
    }
    
    // MARK: Keyboard Manager
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func setupKeyboardListener() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardNotification(notification:)),
                                               name: UIResponder.keyboardWillChangeFrameNotification,
                                               object: nil)
    }
    
    @objc func keyboardNotification(notification: NSNotification) {
        
        guard let userInfo = notification.userInfo else { return }

        let endFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        let endFrameY = endFrame?.origin.y ?? 0
        let duration:TimeInterval = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
        let animationCurveRawNSN = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
        let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIView.AnimationOptions.curveEaseInOut.rawValue
        let animationCurve:UIView.AnimationOptions = UIView.AnimationOptions(rawValue: animationCurveRaw)
        
        
        var keyboardHeight: CGFloat = endFrame?.size.height ?? 0
        
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                let keyboardRectangle = keyboardFrame.cgRectValue
                keyboardHeight = keyboardRectangle.height
        }
        

        if endFrameY >= UIScreen.main.bounds.size.height {
            if let keyboardConstraint = stackViewBottomKeyboardAnchor {
                stackViewBottomKeyboardAnchor?.isActive = false
                stackView?.removeConstraint(keyboardConstraint)
            }
            
            
            let bottomAnchor = stackView?.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0)
            stackViewBottomAnchor = bottomAnchor
            bottomAnchor?.isActive = true
            self.layoutIfNeeded()

        } else {
            if let bottomConstraint = stackViewBottomAnchor {
                stackViewBottomAnchor?.isActive = false
                stackView?.removeConstraint(bottomConstraint)
            }
            
            if let tabBarController = findTabBarParent() {
                let tabHeight = tabBarController.tabBar.frame.height
                keyboardHeight -= tabHeight
            }
            
            let constraintConstant =  0 - (keyboardHeight)
            let bottomAnchor = stackView?.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: constraintConstant)
            bottomAnchor?.priority = UILayoutPriority.defaultLow
            stackViewBottomKeyboardAnchor = bottomAnchor
            bottomAnchor?.isActive = true
            self.layoutIfNeeded()
        }

        UIView.animate(
            withDuration: duration,
            delay: 0,
            options: animationCurve,
            animations: { self.layoutIfNeeded() },
            completion: nil)
    }
    
    
}

// MARK: Comment Field delegate
extension BaseHealthRecordsDetailView: CommentTextFieldViewDelegate, TableSectionHeaderDelegate {
    func textChanged(text: String?) {
        print(text)
    }
    
    func submit(text: String) {
        print("Submit")
        print(text)
        guard let record = model, let hdid = AuthManager().hdid else {return}
        record.submitComment(text: text, hdid: hdid, completion: { [weak self] result in
            DispatchQueue.main.async { [weak self] in
                guard let self = self, let commentObject = result else {
                    return
                }
                self.submittedComment(object: commentObject)
            }
        })
    }
    
    func tappedHeader(title: String) {
        guard let model = self.model else {return}
        delegate?.showComments(for: model)
    }
}

extension UIView {
    func findTabBarParent() -> UITabBarController? {
        let parentVc = self.parentContainerViewController()
        return parentVc?.tabBarController
    }
}
