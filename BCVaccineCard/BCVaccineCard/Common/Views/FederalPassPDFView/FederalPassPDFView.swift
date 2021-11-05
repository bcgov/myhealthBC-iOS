//
//  PDFView.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2021-11-05.
//

import Foundation
import UIKit
import PDFKit

class FederalPassPDFView: UIView {
    @IBOutlet weak var pdfContainer: UIView!
    @IBOutlet weak var navContainer: UIView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    
    private var pdfView: PDFView?
    private var parent: UIViewController?
    
    public func show(data: Data, in parent: UIViewController) {
        guard let doc = PDFDocument(data: data) else {
            return
        }
        self.parent = parent
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
    }
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        self.removeFromSuperview()
    }
    
    @IBAction func shareButtonTapped(_ sender: Any) {
        // TODO
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
