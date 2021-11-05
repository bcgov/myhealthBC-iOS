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
        self.frame = .zero
        parent.view.addSubview(self)
        self.addEqualSizeContraints(to: parent.view)
        let pdfView = PDFView()
        self.pdfView = pdfView
        pdfView.frame = .zero
        pdfContainer.addSubview(pdfView)
        pdfView.addEqualSizeContraints(to: pdfContainer)
        pdfView.document = doc
        style()
        self.parent?.tabBarController?.tabBar.isHidden = true
    }
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        self.delegate?.viewDismissed()
        self.removeFromSuperview()
    }
    
    @IBAction func shareButtonTapped(_ sender: Any) {
        let ac = UIActivityViewController(activityItems: [pdfData], applicationActivities: nil)
        parent?.present(ac, animated: true)

    }
    
    private func style() {
        pdfContainer.backgroundColor = .clear
        navContainer.backgroundColor = .clear
        closeButton.tintColor = .systemBlue
        shareButton.tintColor = .systemBlue
        shareButton.setTitle("", for: .normal)
        closeButton.setTitle("", for: .normal)
    }
}
