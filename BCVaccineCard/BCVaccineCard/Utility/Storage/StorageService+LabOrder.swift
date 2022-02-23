//
//  StorageService+LabOrder.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2022-02-18.
//

import Foundation
import BCVaccineValidator
import SwiftUI

protocol StorageLaboratoryOrderManager {
    
    // MARK: Store
    func storeLaboratoryOrders(
        patient: Patient,
        gateWayResponse: AuthenticatedLaboratoryOrdersResponseObject
    ) -> [LaboratoryOrder]
    
    func storeLaboratoryOrder(
        patient: Patient,
        gateWayObject: AuthenticatedLaboratoryOrdersResponseObject.ResourcePayload.Order
    ) -> LaboratoryOrder?
    
    func storeLaboratoryOrder(
        patient: Patient,
        id: String,
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

extension StorageService: StorageLaboratoryOrderManager {

    func storeLaboratoryOrders(patient: Patient, gateWayResponse: AuthenticatedLaboratoryOrdersResponseObject) -> [LaboratoryOrder] {
        guard let orders = gateWayResponse.resourcePayload?.orders else {return []}
        var storedOrders: [LaboratoryOrder] = []
        for order in orders {
            if let storedOrder = storeLaboratoryOrder(patient: patient, gateWayObject: order) {
                storedOrders.append(storedOrder)
            }
        }
        self.notify(event: StorageEvent(event: .Save, entity: .LaboratoryOrder, object: storedOrders))
        return storedOrders
    }
    
    func storeLaboratoryOrder(
        patient: Patient,
        gateWayObject: AuthenticatedLaboratoryOrdersResponseObject.ResourcePayload.Order) -> LaboratoryOrder? {
            let id = labOrderId(gateWayObject: gateWayObject)
            deleteLaboratoryOrder(id: id, sendDeleteEvent: false)
            var storedTests: [LaboratoryTest] = []
            if let tests = gateWayObject.laboratoryTests {
                for test in tests {
                    if let storedTest = storeLaboratoryTest(gateWayObject: test) {
                        storedTests.append(storedTest)
                    }
                }
            }
            let collectionDateTime =  Date() // TODO: gateWayObject.collectionDateTime 
            return storeLaboratoryOrder(patient: patient, id: id, laboratoryReportID: gateWayObject.laboratoryReportID, reportingSource: gateWayObject.reportingSource, reportID: gateWayObject.reportID, collectionDateTime: collectionDateTime, commonName: gateWayObject.commonName, orderingProvider:gateWayObject.orderingProvider, testStatus: gateWayObject.testStatus, reportAvailable: gateWayObject.reportAvailable ?? false, laboratoryTests: storedTests)
            
        }
    
    func storeLaboratoryOrder(patient: Patient, id: String, laboratoryReportID: String?, reportingSource: String?, reportID: String?, collectionDateTime: Date?, commonName: String?, orderingProvider: String?, testStatus: String?, reportAvailable: Bool, laboratoryTests: [LaboratoryTest]?) -> LaboratoryOrder? {
        guard let context = managedContext else {return nil}
        let labOrder = LaboratoryOrder(context: context)
        labOrder.id = id
        labOrder.patient = patient
        labOrder.laboratoryReportID = laboratoryReportID
        labOrder.reportingSource = reportingSource
        labOrder.reportID = reportID
        labOrder.collectionDateTime = collectionDateTime
        labOrder.commonName = commonName
        labOrder.orderingProvider = orderingProvider
        labOrder.reportAvailable = reportAvailable
        labOrder.laboratoryTests = laboratoryTests
        do {
            try context.save()
            return labOrder
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
            return nil
        }
    }
    
    func storeLaboratoryTest(gateWayObject: AuthenticatedLaboratoryOrdersResponseObject.ResourcePayload.Order.LaboratoryTest) -> LaboratoryTest? {
        return storeLaboratoryTest(batteryType: gateWayObject.batteryType, obxID: gateWayObject.obxID, outOfRange: gateWayObject.outOfRange, loinc: gateWayObject.loinc, testStatus: gateWayObject.testStatus)
    }
    
    func storeLaboratoryTest(batteryType: String?, obxID: String?, outOfRange: Bool?, loinc: String?, testStatus: String?) -> LaboratoryTest? {
        guard let context = managedContext else {return nil}
        let labTest = LaboratoryTest(context: context)
        labTest.batteryType = batteryType
        labTest.obxID = obxID
        labTest.outOfRange = outOfRange ?? false
        labTest.loinc = loinc
        labTest.testStatus = testStatus
        do {
            try context.save()
            return labTest
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
            return nil
        }
    }
    
    /// This function generates a hash to be used as an id without the laboratory tests.
    private func labOrderId(gateWayObject: AuthenticatedLaboratoryOrdersResponseObject.ResourcePayload.Order) -> String {
        var copy = AuthenticatedLaboratoryOrdersResponseObject.ResourcePayload.Order(laboratoryReportID: gateWayObject.reportID, reportingSource: gateWayObject.reportingSource, reportID: gateWayObject.reportID, collectionDateTime: gateWayObject.collectionDateTime,commonName: gateWayObject.commonName, orderingProvider: gateWayObject.orderingProvider, testStatus: gateWayObject.testStatus, reportAvailable: gateWayObject.reportAvailable, laboratoryTests: [])
        return copy.md5Hash() ?? UUID().uuidString
    }
    
    
    func updateLaboratoryOrder(gateWayObject: AuthenticatedLaboratoryOrdersResponseObject.ResourcePayload.Order) -> LaboratoryOrder? {
        guard let existing = fetchLaboratoryOrder(id: labOrderId(gateWayObject: gateWayObject)), let patient = existing.patient else {return nil}
        // Store function will remove existing one
        return storeLaboratoryOrder(patient: patient, gateWayObject: gateWayObject)
    }
    
    // MARK: Fetch
    func fetchLaboratoryOrders() -> [LaboratoryOrder] {
        guard let context = managedContext else {return []}
        do {
            return try context.fetch(LaboratoryOrder.fetchRequest())
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return []
        }
    }
    
    func fetchLaboratoryOrder(id: String) -> LaboratoryOrder? {
        let labOrders = fetchLaboratoryOrders()
        return labOrders.first(where: {$0.id == id})
    }
    
    // MARK: Delete
    func deleteLaboratoryOrder(id: String, sendDeleteEvent: Bool) {
        guard let object = fetchLaboratoryOrder(id: id) else {return}
        delete(object: object)
        if sendDeleteEvent {
            self.notify(event: StorageEvent(event: .Delete, entity: .LaboratoryOrder, object: object))
        }
    }
    
    
}
