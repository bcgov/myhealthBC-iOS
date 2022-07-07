//
//  AuthenticatedImmunizationsResponseObject.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2022-06-29.
//

import Foundation

// MARK: -
struct AuthenticatedImmunizationsResponseObject: Codable {
    let resourcePayload: ResourcePayload?
    let totalResultCount, pageIndex, pageSize, resultStatus: Int?
    let resultError: ResultError?
    
    // MARK: - ResourcePayload
    struct ResourcePayload: Codable {
        let loadState: LoadState?
        let immunizations: [Immunization]?
        let recommendations: [Recommendation]?
           
        // MARK: - LoadState
        struct LoadState: Codable {
            let refreshInProgress: Bool
        }
        
        // MARK: - ImmunizationElement
        struct Immunization: Codable {
            let id, dateOfImmunization, providerOrClinic, status, targetedDisease: String?
            let valid: Bool?
            let immunizationDetails: ImmunizationDetails?
            let forecast: Forecast?
            
            enum CodingKeys: String, CodingKey {
                case immunizationDetails = "immunization"
                case id, dateOfImmunization, providerOrClinic, status, targetedDisease, valid, forecast
            }
            
            // MARK: - Forecast
            struct Forecast: Codable {
                let recommendationID, createDate, status, displayName, eligibleDate, dueDate: String?

                enum CodingKeys: String, CodingKey {
                    case recommendationID = "recommendationId"
                    case createDate, status, displayName, eligibleDate, dueDate
                }
            }
        }
        
        // MARK: - Recommendation
        struct Recommendation: Codable {
            let recommendationSetID, status, diseaseEligibleDate, diseaseDueDate, agentEligibleDate, agentDueDate: String?
            let targetDiseases: [TargetDisease]?
            let immunization: ImmunizationDetails?

            enum CodingKeys: String, CodingKey {
                case recommendationSetID = "recommendationSetId"
                case diseaseEligibleDate, diseaseDueDate, agentEligibleDate, agentDueDate, status, targetDiseases, immunization
            }
            
            // MARK: - TargetDisease
            struct TargetDisease: Codable {
                let code, name: String?
            }
        }
        
        // MARK: - ImmunizationImmunization
        struct ImmunizationDetails: Codable {
            let name: String?
            let immunizationAgents: [ImmunizationAgent]?
            
            // MARK: - ImmunizationAgent
            struct ImmunizationAgent: Codable {
                let code, name, lotNumber, productName: String?
            }
        }
    }
}
