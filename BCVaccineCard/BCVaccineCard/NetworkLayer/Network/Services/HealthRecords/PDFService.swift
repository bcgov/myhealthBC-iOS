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
    let configService: MobileConfigService
    
    private var endpoints: UrlAccessor {
        return UrlAccessor()
    }
    
    public func fetchPDF(record: HealthRecordsDetailDataSource, patient: Patient, completion: @escaping (String?)->Void) {
        guard let id = getID(record: record),
              let type = record.getPDFType()
        else {
            return completion(nil)
        }
        network.addLoader(message: .empty, caller: .PDFService_fetchPDF)
        fetchPDF(fileID: id, type: type, isCovid: type == .Covid19, patient: patient, completion: {response in
            network.removeLoader(caller: .PDFService_fetchPDF)
            return completion(response?.data)
        })
    }
    
    public func fetchPDF(donorStatus: OrganDonorStatus, patient: Patient, completion: @escaping (Data?)->Void) {
        guard let fileId = donorStatus.fileId else {
            return completion(nil)
        }
        network.addLoader(message: .empty, caller: .PDFService_DonorStatus)
        fetchPDFV2(fileID: fileId, type: .OrganDonor, isCovid: false, patient: patient, completion: {response in
            network.removeLoader(caller: .PDFService_DonorStatus)
            guard let response = response,
                  let content = response.content
            else {
                return completion(nil)
            }
            let uint = content.map({UInt8($0)})
            let data = Data(uint)
            return completion(data)
        })
    }
    
    public func fetchPDFDiagnostic(diagnosticImaging: DiagnosticImaging, patient: Patient, completion: @escaping (Data?)->Void) {
        guard let fileID = diagnosticImaging.fileID else {
            return completion(nil)
        }
        network.addLoader(message: .empty, caller: .PDFService_DiagnosticImaging)
        fetchPDFV2(fileID: fileID, type: .DiagnosticImaging, isCovid: false, patient: patient, completion: {response in
            network.removeLoader(caller: .PDFService_DiagnosticImaging)
            guard let response = response,
                  let content = response.content
            else {
                return completion(nil)
            }
            let uint = content.map({UInt8($0)})
            let data = Data(uint)
            return completion(data)
        })
    }
    
    func toUint(signed: Int) -> UInt8 {
        return UInt8(signed)
    }
    
    private func getID(record: HealthRecordsDetailDataSource) -> String? {
        switch record.type {
        case.clinicalDocument(let clinicalDoc):
            return clinicalDoc.fileID
        case .laboratoryOrder(model: let labOrder):
            return labOrder.labPdfId
        case .covidTestResultRecord(model: let covidTestOrder):
            return covidTestOrder.orderId
        case .diagnosticImaging(model: let diagnosticImaging):
            return diagnosticImaging.fileID
        default:
            return nil
        }
    }
    
    private func getURL(type: FetchType, baseURL: URL, hdid: String, fileID: String) -> URL {
        switch type {
        case .ClinialDocument:
            return endpoints.clinicalDocumentPDF(fileID: fileID, base: baseURL, hdid: hdid)
        case .LabOrder:
            return endpoints.labTestPDF(base: baseURL, reportID: fileID)
        case .Covid19:
            return endpoints.labTestPDF(base: baseURL, reportID: fileID)
        case .OrganDonor:
            return endpoints.patientDataPDF(base: baseURL, hdid: hdid, fileID: fileID)
        case .DiagnosticImaging:
            return endpoints.patientDataPDF(base: baseURL, hdid: hdid, fileID: fileID)
        }
    }
    
}

// MARK: Network requests
extension PDFService {
    private func fetchPDF(fileID: String, type: FetchType, isCovid: Bool, patient: Patient, completion: @escaping(_ response: AuthenticatedPDFResponseObject.ResourcePayload?) -> Void) {
        guard let token = authManager.authToken,
              let hdid = patient.hdid,
              NetworkConnection.shared.hasConnection
        else { return completion(nil)}
        
        configService.fetchConfig { response in
            guard let config = response,
                  config.online,
                  let baseURLString = config.baseURL,
                  let baseURL = URL(string: baseURLString)
            else {
                return completion(nil)
            }
            
            let url = getURL(type: type, baseURL: baseURL, hdid: hdid, fileID: fileID)
            let headers = [
                Constants.AuthenticationHeaderKeys.authToken: "Bearer \(token)"
            ]
            
            let parameters: AuthenticatedPDFRequestObject = AuthenticatedPDFRequestObject(hdid: hdid, isCovid19: isCovid ? "true" : "false", apiVersion: "1")
            let requestModel = NetworkRequest<AuthenticatedPDFRequestObject, AuthenticatedPDFResponseObject>(url: url, type: .Get, parameters: parameters, encoder: .urlEncoder, headers: headers)
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
    
    private func fetchPDFV2(fileID: String, type: FetchType, isCovid: Bool, patient: Patient, completion: @escaping(_ response: PDFResponseV2?) -> Void) {
        guard let token = authManager.authToken,
              let hdid = patient.hdid,
              NetworkConnection.shared.hasConnection
        else { return completion(nil)}
        
        configService.fetchConfig { response in
            guard let config = response,
                  config.online,
                  let baseURLString = config.baseURL,
                  let baseURL = URL(string: baseURLString)
            else {
                return completion(nil)
            }
            
            let url = getURL(type: type, baseURL: baseURL, hdid: hdid, fileID: fileID)
            let headers = [
                Constants.AuthenticationHeaderKeys.authToken: "Bearer \(token)"
            ]
            
            let parameters = AuthenticatedPDFRequestObject(hdid: hdid, isCovid19: "false", apiVersion: "2")
            let requestModel = NetworkRequest<AuthenticatedPDFRequestObject, PDFResponseV2>(url: url, type: .Get, parameters: parameters, encoder: .urlEncoder, headers: headers)
            { result in
                return completion(result)
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
        case OrganDonor
        case DiagnosticImaging
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
        case .diagnosticImaging:
            return .DiagnosticImaging
        default:
            return nil
        }
    }
}
