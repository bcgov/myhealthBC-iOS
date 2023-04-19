//
//  NetworkProtocol.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2022-09-14.
//

import Foundation
import UIKit

protocol Network {
    func request<Parameters: Encodable, T: Decodable>(with requestData: NetworkRequest<Parameters, T>)
}


enum LoaderCaller {
    case PatientService_fetchAndStoreDetails
    case PatientService_fetchAndStoreOrganDonorStatus
    case PatientService_validateProfile
    case CovidTestsService_fetchAndStore
    case VaccineCardService_fetchAndStore_Patient
    case VaccineCardService_fetchAndStore_Dependent
    case VaccineCardService_fetchAndStore_DependentsOfPatient
    case VaccineCardService_fetchAndStore_FormInfo
    case ClinicalDocumentService_fetchAndStore
    case DependentService_fetchDependents
    case DependentService_addDependent
    case FeedbackService_postFeedback
    case HealthVisitsService_fetchAndStore
    case MobileConfigService_fetchConfig
    case MedicationService_fetchAndStore
    case SpecialAuthorityDrugService_fetchAndStore
    case HospitalVisitsService_fetchAndStore
    case PDFService_fetchPDF
    case PDFService_DonorStatus
    case CommentService_submitUnsyncedComments
    case CommentService_fetchAndStore
    case LabOrderService_fetchAndStore
    case ImmnunizationsService_fetchAndStore
    case HealthRecordsService_fetchAndStore
}

extension Network {
    func addLoader(message: LoaderMessage, caller: LoaderCaller) {
        DispatchQueue.main.async {
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                appDelegate.incrementLoader(message: message, caller: caller)
            }
        }
    }
    
    func removeLoader(caller: LoaderCaller) {
        DispatchQueue.main.async {
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                appDelegate.decrementLoader(caller: caller)
            }
        }
    }
}

extension Network {
    func showToast(message: String, style: AppDelegate.ToastStyle? = .Default) {
        DispatchQueue.main.async {
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                appDelegate.showToast(message: message, style: style)
            }
        }
    }
}
