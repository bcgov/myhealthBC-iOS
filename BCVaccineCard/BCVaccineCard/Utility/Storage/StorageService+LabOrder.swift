//
//  StorageService+LabOrder.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2022-02-18.
//

import Foundation

protocol StorageLaboratoryOrderManager {
    
    // MARK: Store
    func storeLaboratoryOrders(
        patient: Patient,
        gateWayResponse: AuthenticatedLaboratoryOrdersResponseObject
    ) -> [LaboratoryOrder]
    
    func storeLaboratoryOrder(
        gateWayObject: AuthenticatedLaboratoryOrdersResponseObject.ResourcePayload.Order
    ) -> LaboratoryOrder?
    
    func storeLaboratoryOrder(
        id: String?,
        patient: Patient?,
        laboratoryReportID: String?,
        reportingSource: String?,
        reportID: String?,
        collectionDateTime: Date?,
        commonName: String?,
        orderingProvider: String?,
        testStatus: String?,
        reportAvailable: Bool,
        laboratoryTests: [LaboratoryTest]?
    ) -> LaboratoryOrder?
    
    func storeLaboratoryTest(
        gateWayObject: AuthenticatedLaboratoryOrdersResponseObject.ResourcePayload.Order.LaboratoryTest
    ) -> LaboratoryTest?
    
    func storeLaboratoryTest(
        id: String?,
        batteryType: String?,
        obxID: String?,
        outOfRange: Bool?,
        loinc: String?,
        testStatus: String?
    ) -> LaboratoryTest?
    
    // MARK: Update
    func updateLaboratoryOrder(
        gateWayObject: AuthenticatedLaboratoryOrdersResponseObject.ResourcePayload.Order
    ) -> LaboratoryOrder?
    
    // MARK: Delete
    func deleteLaboratoryOrder(id: String, sendDeleteEvent: Bool)
    
    // MARK: Fetch
    func fetchLaboratoryOrders() -> [LaboratoryOrder]
    func fetchLaboratoryOrder(id: String) -> LaboratoryOrder?
}
