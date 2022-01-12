//
//  PagingIndicatorView.swift
//  BCVaccineCard
//
//  Created by Amir on 2021-12-13.
//

import Foundation
import UIKit

/// Usage :
/// let view = PagingIndicatorView()
/// pagingIndicator.display(in: container, count: count, selected: 0)
/// then call  .select(index: currentPage) to change the selected bullet
class PagingIndicatorView: UIView {
    
    static let bulletSize: CGFloat = 12
    static let butlletSpacing: CGFloat = 9
    static let bulletStartTag: Int = 555511110
    static let selectedColour: UIColor = AppColours.appBlue
    static let unselectedColour: UIColor = AppColours.appBlueLight
    
    private var count: Int = 0
    private var selected: Int = 0
    
    private var bullets: [UIView] = []
    private var stackView: UIStackView?
    
    
    /// create and display bullet points in container
    /// - Parameters:
    ///   - container: container to place PagingIndicatorView in
    ///   - count: number of bullets
    ///   - selected: index of selected bullet
    public func display(in container: UIView, count: Int, selected: Int) {
        self.frame = .zero
        container.addSubview(self)
        addEqualSizeContraints(to: container)
        
        self.count = count
        createBullets()
        select(index: selected)
    }
    
    
    /// Change the currenrly selected index
    /// - Parameter index: Selected index
    public func select(index: Int) {
        guard bullets.indices.contains(index) else {return}
        if bullets.indices.contains(selected) {
            bullets[selected].backgroundColor = PagingIndicatorView.unselectedColour
        }
        self.selected = index
        bullets[index].backgroundColor = PagingIndicatorView.selectedColour
        
    }
    
    private func createBullets() {
        if bullets.count == count { return }
        for i in 0...count {
            let bullet = createBullet(index: i)
            bullets.append(bullet)
        }
        createStackView()
        
    }
    
    private func createStackView() {
        let stackTag = 9812495
        if let existing = self.viewWithTag(stackTag) {
            existing.removeFromSuperview()
        }
        let stackView = UIStackView(arrangedSubviews: bullets)
        stackView.tag = stackTag
        self.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
        stackView.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 0).isActive = true
        stackView.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0).isActive = true
        self.stackView = stackView
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.axis = .horizontal
        stackView.spacing = PagingIndicatorView.butlletSpacing
    }
    
    private func createBullet(index: Int) -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: PagingIndicatorView.bulletSize, height: PagingIndicatorView.bulletSize))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: PagingIndicatorView.bulletSize).isActive = true
        view.widthAnchor.constraint(equalToConstant: PagingIndicatorView.bulletSize).isActive = true
        view.backgroundColor = PagingIndicatorView.unselectedColour
        view.layer.cornerRadius = PagingIndicatorView.bulletSize/2
        view.tag = index + PagingIndicatorView.bulletStartTag
        return view
    }
}
