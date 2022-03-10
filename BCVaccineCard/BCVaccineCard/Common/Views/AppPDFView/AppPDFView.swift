//
//  AppPDFView.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2021-11-05.
//

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
    private let temporaryPath = "MyHealthPDFFile.pdf"
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
        let img = formatPDFAsImageForFirstPage(pdfData: data)
        let activityItem = CustomActivityItemProvider(placeholderItem: "")
        activityItem.pdfItem = data
        activityItem.imageItem = img
        let ac = UIActivityViewController(activityItems: [activityItem], applicationActivities: [])
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
    
    private func formatPDFAsImageForFirstPage(pdfData: Data) -> UIImage? {
        guard let doc = PDFDocument(data: pdfData) else { return nil }
        let numberOfPages = doc.pageCount
        guard let page = doc.page(at: 0) else { return nil }
        let pageRect = page.bounds(for: .mediaBox)
        let renderer = UIGraphicsImageRenderer(size: pageRect.size)
        let img = renderer.image { ctx in
            // Set and fill the background color.
            UIColor.white.set()
            ctx.fill(CGRect(x: 0, y: 0, width: pageRect.width, height: pageRect.height))
            
            // Translate the context so that we only draw the `cropRect`.
            ctx.cgContext.translateBy(x: -pageRect.origin.x, y: pageRect.size.height - pageRect.origin.y)
            
            // Flip the context vertically because the Core Graphics coordinate system starts from the bottom.
            ctx.cgContext.scaleBy(x: 1.0, y: -1.0)
            
            // Draw the PDF page.
            page.draw(with: .mediaBox, to: ctx.cgContext)
        }
        return img
    }
    
    // TODO: Play around with this some more
//    private func formatPDFAsImages(pdfData: Data) -> [UIImage]? {
//        guard let doc = PDFDocument(data: pdfData) else { return nil }
//        let numberOfPages = doc.pageCount
//        guard numberOfPages > 0 else { return nil }
//        var imageArray: [UIImage] = []
//        for i in 0...(numberOfPages - 1) {
//            if let page = doc.page(at: i) {
//                let pageRect = page.bounds(for: .mediaBox)
//                let renderer = UIGraphicsImageRenderer(size: pageRect.size)
//                let img = renderer.image { ctx in
//                    // Set and fill the background color.
//                    UIColor.white.set()
//                    ctx.fill(CGRect(x: 0, y: 0, width: pageRect.width, height: pageRect.height))
//
//                    // Translate the context so that we only draw the `cropRect`.
//                    ctx.cgContext.translateBy(x: -pageRect.origin.x, y: pageRect.size.height - pageRect.origin.y)
//
//                    // Flip the context vertically because the Core Graphics coordinate system starts from the bottom.
//                    ctx.cgContext.scaleBy(x: 1.0, y: -1.0)
//
//                    // Draw the PDF page.
//                    page.draw(with: .mediaBox, to: ctx.cgContext)
//                }
//                imageArray.append(img)
//            }
//        }
//        return imageArray
//    }
}

class CustomActivityItemProvider: UIActivityItemProvider {
    
    var pdfItem: Any?
    var imageItem: Any?

    override var item: Any {
        guard let type = self.activityType else { return "" }
        switch type {
        case UIActivity.ActivityType.mail, UIActivity.ActivityType.message:
            guard let pdfItem = pdfItem else { return "" }
            return pdfItem
        default:
            guard let imageItem = imageItem else { return "" }
            return imageItem
        }
        
    }
}
