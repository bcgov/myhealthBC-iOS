//
//  AuthenticatedImmunizationsResponseObject.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2022-06-29.
//

import Foundation

// MARK: - Welcome
struct AuthenticatedImmunizationsResponseObject: Codable {
    let resourcePayload: ResourcePayload?
    let totalResultCount, pageIndex, pageSize, resultStatus: Int?
    let resultError: ResultError?
    
    // MARK: - ResourcePayload
    struct ResourcePayload: Codable {
        let loadState: LoadState?
        let immunizations: [ImmunizationElement]?
        let recommendations: [Recommendation]?
        
        // MARK: - ImmunizationImmunization
        struct ImmunizationImmunization: Codable {
            let name: String?
            let immunizationAgents: [ImmunizationAgent]?
            
            // MARK: - ImmunizationAgent
            struct ImmunizationAgent: Codable {
                let code, name, lotNumber, productName: String?
            }
        }
        
        // MARK: - TargetDisease
        struct TargetDisease: Codable {
            let code, name: String?
        }
        
        // MARK: - ImmunizationElement
        struct ImmunizationElement: Codable {
            let id, dateOfImmunization, providerOrClinic: String?
            let status: Status?
            let valid: Bool?
            let targetedDisease: TargetedDisease?
            let immunization: ImmunizationImmunization?
            let forecast: Forecast?
            
            // MARK: - Forecast
            struct Forecast: Codable {
                let recommendationID, createDate, status, displayName, eligibleDate, dueDate: String?

                enum CodingKeys: String, CodingKey {
                    case recommendationID = "recommendationId"
                    case createDate, status, displayName, eligibleDate, dueDate
                }
            }
            
            enum Status: String, Codable {
                case completed = "Completed"
            }
            
            enum TargetedDisease: String, Codable {
                case covid19 = "COVID19"
                case notset = "NOTSET"
            }
        }
        
        // MARK: - LoadState
        struct LoadState: Codable {
            let refreshInProgress: Bool
        }
        
        // MARK: - Recommendation
        struct Recommendation: Codable {
            let recommendationSetID, status, diseaseEligibleDate, diseaseDueDate, agentEligibleDate, agentDueDate: String?
            let targetDiseases: [TargetDisease]?
            let immunization: ImmunizationImmunization?

            enum CodingKeys: String, CodingKey {
                case recommendationSetID = "recommendationSetId"
                case diseaseEligibleDate, diseaseDueDate, agentEligibleDate, agentDueDate, status, targetDiseases, immunization
            }
        }

    }
}
