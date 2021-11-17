//
//  PDFView.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2021-11-05.
//

import Foundation
import UIKit
import PDFKit

protocol FederalPassPDFViewDelegate: AnyObject {
    func viewDismissed()
}

class FederalPassPDFView: UIView {
    @IBOutlet weak var pdfContainer: UIView!
    @IBOutlet weak var navContainer: UIView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var viewTitleLabel: UILabel!
    
    private var pdfView: PDFView?
    private var parent: UIViewController?
    private var pdfData: Data?
    var delegate: FederalPassPDFViewDelegate?
    
    public func show(data: Data, in parent: UIViewController) {
        guard let doc = PDFDocument(data: data) else {
            return
        }
        self.parent = parent
        self.pdfData = data
        present(in: parent.view)
        display(document: doc)
        style()
        setupAccessibility()
    }
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        UIAccessibility.post(notification: .screenChanged, argument: self.parent)
        self.delegate?.viewDismissed()
        self.removeFromSuperview()
    }
    
    @IBAction func shareButtonTapped(_ sender: Any) {
        guard let data = pdfData else {return}
        let ac = UIActivityViewController(activityItems: [data], applicationActivities: nil)
        parent?.present(ac, animated: true)
    }
    
    private func present(in parent: UIView) {
        self.frame = .zero
        parent.addSubview(self)
        self.addEqualSizeContraints(to: parent)
    }
    
    private func display(document: PDFDocument) {
        let pdfView = PDFView()
        self.pdfView = pdfView
        pdfView.frame = .zero
        pdfContainer.subviews.forEach({$0.removeFromSuperview()})
        pdfContainer.addSubview(pdfView)
        pdfView.addEqualSizeContraints(to: pdfContainer)
        pdfView.document = document
        pdfView.minScaleFactor = pdfView.scaleFactorForSizeToFit
        pdfView.autoScales = true
    }
    
    private func style() {
        self.parent?.tabBarController?.tabBar.isHidden = true
        pdfContainer.backgroundColor = .clear
        navContainer.backgroundColor = .clear
        closeButton.tintColor = .systemBlue
        shareButton.tintColor = .systemBlue
        shareButton.setTitle("", for: .normal)
        closeButton.setTitle("", for: .normal)
        viewTitleLabel.text = .travelPass
        viewTitleLabel.font = UIFont.bcSansBoldWithSize(size: 17)
        closeButton.setTitle(.done, for: .normal)
    }
    
    private func setupAccessibility() {
        closeButton.accessibilityLabel = "Done"
        closeButton.accessibilityHint = "Tapping this closes your federal proof of vaccination"
        closeButton.accessibilityTraits = [.selected]
        
        shareButton.accessibilityLabel = "Share"
        shareButton.accessibilityHint = "share federal pass"
        shareButton.accessibilityTraits = [.selected]
        
        viewTitleLabel.isAccessibilityElement = false
        pdfView?.accessibilityLabel = "Federal Proof of vaccination"
        
        self.accessibilityElements = [shareButton, closeButton, pdfView, closeButton]
        UIAccessibility.post(notification: .screenChanged, argument: self)
        UIAccessibility.setFocusTo(pdfView)
        
        
    }
    
}
