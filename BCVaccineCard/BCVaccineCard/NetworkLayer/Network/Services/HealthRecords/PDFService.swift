//
//  PDFService.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2023-01-23.
//

import Foundation

struct PDFService {
    
    let network: Network
    let authManager: AuthManager
    
    private var endpoints: UrlAccessor {
        return UrlAccessor()
    }
    
    public func fetchPDF(record: HealthRecordsDetailDataSource, patient: Patient, completion: @escaping (String?)->Void) {
        guard let hdid = patient .hdid,
              let id = getID(record: record),
              let type = record.getPDFType()
        else {
            return completion(nil)
        }
        let url = getURL(type: type, hdid: hdid, fileID: id)
        network.addLoader(message: .FetchingRecords)
        fetchPDF(url: url, isCovid: type == .Covid19, patient: patient, completion: {response in
            network.removeLoader()
            return completion(response?.data)
        })
    }
    
    private func getID(record: HealthRecordsDetailDataSource) -> String? {
        switch record.type {
        case.clinicalDocument(let clinicalDoc):
            return clinicalDoc.fileID
        case .laboratoryOrder(model: let labOrder):
            return labOrder.labPdfId
        case .covidTestResultRecord(model: let covidTestOrder):
            return covidTestOrder.orderId
        default:
            return nil
        }
    }
    
    private func getURL(type: FetchType, hdid: String, fileID: String) -> URL {
        switch type {
        case .ClinialDocument:
            return endpoints.authenticatedClinicalDocumentPDF(hdid: hdid, fileID: fileID)
        case .LabOrder:
            return endpoints.getAuthenticatedLabTestPDF(repordId: fileID)
        case .Covid19:
            return endpoints.getAuthenticatedLabTestPDF(repordId: fileID)
        }
    }
    
}

// MARK: Network requests
extension PDFService {
    private func fetchPDF(url: URL, isCovid: Bool, patient: Patient, completion: @escaping(_ response: AuthenticatedPDFResponseObject.ResourcePayload?) -> Void) {
        guard let token = authManager.authToken,
              let hdid = patient .hdid,
              NetworkConnection.shared.hasConnection
        else { return completion(nil)}
        
        BaseURLWorker.shared.setBaseURL {
            guard BaseURLWorker.shared.isOnline == true else { return completion(nil) }
            
            let headers = [
                Constants.AuthenticationHeaderKeys.authToken: "Bearer \(token)"
            ]
            
            let parameters: AuthenticatedPDFRequestObject = AuthenticatedPDFRequestObject(hdid: hdid, isCovid19: isCovid ? "true" : "false")
            
            let requestModel = NetworkRequest<AuthenticatedPDFRequestObject, AuthenticatedPDFResponseObject>(url: url,
                                                                                                             type: .Get,
                                                                                                             parameters: parameters,
                                                                                                             encoder: .urlEncoder,
                                                                                                             headers: headers)
            { result in
                if let docs = result?.resourcePayload {
                    // return result
                    return completion(docs)
                } else {
                    return completion(nil)
                }
            }
            
            network.request(with: requestModel)
        }
    }
}
extension PDFService {
    fileprivate enum FetchType {
        case ClinialDocument
        case LabOrder
        case Covid19
    }
}

extension HealthRecordsDetailDataSource {
    fileprivate func getPDFType() -> PDFService.FetchType? {
        switch self.type {
        case.clinicalDocument:
            return .ClinialDocument
        case .laboratoryOrder:
            return .LabOrder
        case .covidTestResultRecord:
            return .Covid19
        default:
            return nil
        }
    }
}
