//
//  AppPDFView.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2021-11-05.
//
// FIXME: NEED TO LOCALIZE 
import Foundation
import UIKit
import PDFKit

enum PDFType {
    case fedPass
    case labResults
}

class AppPDFView: UIView {
    @IBOutlet weak var pdfContainer: UIView!
    @IBOutlet weak var navContainer: UIView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var viewTitleLabel: UILabel!
    
    private var pdfView: PDFView?
    private var parent: UIViewController?
    private var pdfData: Data?
    private var id: String?
    private var type: PDFType?
 
    // Completion
    var completionHandler: ((String?) -> Void)?
    
    public func show(data: Data, in parent: UIViewController, id: String?, type: PDFType?) {
        guard let doc = PDFDocument(data: data) else {
            return
        }
        self.parent = parent
        self.pdfData = data
        self.id = id
        self.type = type
        present(in: parent.view)
        display(document: doc)
        style()
        setupAccessibility()
    }
    
    private func present(in parent: UIView) {
        self.frame = .zero
        self.alpha = 0
        parent.addSubview(self)
        self.addEqualSizeContraints(to: parent)
        UIView.animate(withDuration: 0.2) {[weak self] in
            guard let `self` = self else {return}
            self.alpha = 1
            self.parent?.view.layoutIfNeeded()
        }
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
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) { [weak self] in
            guard let `self` = self else {return}
            self.alpha = 0
            self.parent?.tabBarController?.tabBar.isHidden = false
            self.parent?.view.layoutIfNeeded()
        } completion: { [weak self] done in
            guard let `self` = self else {return}
            UIAccessibility.post(notification: .screenChanged, argument: self.parent)
            self.completionHandler?(self.id)
            self.removeFromSuperview()
        }
    }
    
    @IBAction func shareButtonTapped(_ sender: Any) {
        guard let data = pdfData else { return }
        let ac = UIActivityViewController(activityItems: [data], applicationActivities: [])
        parent?.present(ac, animated: true)
    }
    
    private func style() {
        self.parent?.tabBarController?.tabBar.isHidden = true
        pdfContainer.backgroundColor = .clear
        navContainer.backgroundColor = .clear
        closeButton.tintColor = .systemBlue
        shareButton.tintColor = .systemBlue
        shareButton.setTitle("", for: .normal)
        closeButton.setTitle("", for: .normal)
        viewTitleLabel.text = .canadianCOVID19ProofOfVaccination
        viewTitleLabel.font = UIFont.bcSansBoldWithSize(size: 17)
        closeButton.setTitle(.done, for: .normal)
    }
    
    // TODO: Put these in accessibility constants file (Amir - lol)
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
