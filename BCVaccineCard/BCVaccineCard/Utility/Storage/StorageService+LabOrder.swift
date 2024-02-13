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
        gateWayObject: AuthenticatedLaboratoryOrdersResponseObject.ResourcePayload.Order,
        pdf: String?
    ) -> LaboratoryOrder?
    
    func storeLaboratoryOrder(
        patient: Patient,
        id: String,
        labPdfId: String?,
        reportingSource: String?,
        reportID: String?,
        collectionDateTime: Date?,
        orderStatus: String?,
        timelineDateTime: Date?,
        commonName: String?,
        orderingProvider: String?,
        testStatus: String?,
        reportAvailable: Bool,
        laboratoryTests: [LaboratoryTest]?,
        pdf: String?
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
        gateWayObject: AuthenticatedLaboratoryOrdersResponseObject.ResourcePayload.Order,
        pdf: String?
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
            // Note: Currently no easy way to get PDF, so in this case, we will store nil
            if let storedOrder = storeLaboratoryOrder(patient: patient, gateWayObject: order, pdf: nil) {
                storedOrders.append(storedOrder)
            }
        }
        self.notify(event: StorageEvent(event: .Save, entity: .LaboratoryOrder, object: storedOrders))
        return storedOrders
    }
    
    func storeLaboratoryOrder(
        patient: Patient,
        gateWayObject: AuthenticatedLaboratoryOrdersResponseObject.ResourcePayload.Order,
        pdf: String?) -> LaboratoryOrder? {
            let id = UUID().uuidString
//            deleteLaboratoryOrder(id: id, sendDeleteEvent: false)
            var storedTests: [LaboratoryTest] = []
            if let tests = gateWayObject.laboratoryTests {
                for test in tests {
                    if let storedTest = storeLaboratoryTest(gateWayObject: test) {
                        storedTests.append(storedTest)
                    }
                }
            }
            var collectionDateTime: Date?
            var timelineDateTime: Date?
            
            collectionDateTime = gateWayObject.collectionDateTime?.getGatewayDate() ?? Date()
            timelineDateTime = gateWayObject.timelineDateTime?.getGatewayDate() ?? Date()
//            if let gatewayDate = Date.Formatter.gatewayDateAndTime.date(from: gateWayObject.collectionDateTime ?? "") {
//                collectionDateTime = gatewayDate
//            } else {
//                collectionDateTime = Date.Formatter.yearMonthDay.date(from: gateWayObject.collectionDateTime ?? "") ?? Date()
//            }
//            if let gatewayDate = Date.Formatter.gatewayDateAndTime.date(from: gateWayObject.timelineDateTime ?? "") {
//                timelineDateTime = gatewayDate
//            } else {
//                timelineDateTime = Date.Formatter.yearMonthDay.date(from: gateWayObject.timelineDateTime ?? "") ?? Date()
//            }
            
            return storeLaboratoryOrder(patient: patient, id: id, labPdfId: gateWayObject.labPdfId, reportingSource: gateWayObject.reportingSource, reportID: gateWayObject.reportID, collectionDateTime: collectionDateTime, orderStatus: gateWayObject.orderStatus, timelineDateTime: timelineDateTime, commonName: gateWayObject.commonName, orderingProvider:gateWayObject.orderingProvider, testStatus: gateWayObject.testStatus, reportAvailable: gateWayObject.reportAvailable ?? false, laboratoryTests: storedTests, pdf: pdf)
            
        }
    
    func storeLaboratoryOrder(patient: Patient, id: String, labPdfId: String?, reportingSource: String?, reportID: String?, collectionDateTime: Date?, orderStatus: String?, timelineDateTime: Date?, commonName: String?, orderingProvider: String?, testStatus: String?, reportAvailable: Bool, laboratoryTests: [LaboratoryTest]?, pdf: String?) -> LaboratoryOrder? {
        guard let context = managedContext else {return nil}
        let labOrder = LaboratoryOrder(context: context)
        labOrder.id = id
        labOrder.authenticated = true
        labOrder.patient = patient
        labOrder.labPdfId = labPdfId
        labOrder.reportingSource = reportingSource
        labOrder.reportID = reportID
        labOrder.collectionDateTime = collectionDateTime
        labOrder.timelineDateTime = timelineDateTime
        labOrder.commonName = commonName
        labOrder.orderingProvider = orderingProvider
        labOrder.reportAvailable = reportAvailable
        labOrder.pdf = pdf
        labOrder.testStatus = testStatus
        labOrder.orderStatus = orderStatus
        var labTestsArray: [LaboratoryTest] = []
        let labTests = laboratoryTests ?? []
        for test in labTests {
            if let model = storeLaboratoryTest(
                batteryType: test.batteryType,
                obxID: test.obxID,
                outOfRange: test.outOfRange,
                loinc: test.loinc,
                testStatus: test.testStatus) {
                
                labTestsArray.append(model)
                labOrder.addToLaboratoryTests(model)
            }
        }
        do {
            try context.save()
            return labOrder
        } catch let error as NSError {
            Logger.log(string: "Could not save. \(error), \(error.userInfo)", type: .storage)
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
            Logger.log(string: "Could not save. \(error), \(error.userInfo)", type: .storage)
            return nil
        }
    }
    
    /// This function generates a hash to be used as an id without the laboratory tests.
    private func labOrderId(gateWayObject: AuthenticatedLaboratoryOrdersResponseObject.ResourcePayload.Order) -> String {
        var copy = AuthenticatedLaboratoryOrdersResponseObject.ResourcePayload.Order(labPdfId: gateWayObject.labPdfId, reportingSource: gateWayObject.reportingSource, reportID: gateWayObject.reportID, collectionDateTime: gateWayObject.collectionDateTime, timelineDateTime: gateWayObject.timelineDateTime, commonName: gateWayObject.commonName, orderingProvider: gateWayObject.orderingProvider, orderStatus: gateWayObject.orderStatus, testStatus: gateWayObject.testStatus, reportAvailable: gateWayObject.reportAvailable, laboratoryTests: [])
        return copy.md5Hash() ?? UUID().uuidString
    }
    
    
    func updateLaboratoryOrder(gateWayObject: AuthenticatedLaboratoryOrdersResponseObject.ResourcePayload.Order, pdf: String?) -> LaboratoryOrder? {
        guard let existing = fetchLaboratoryOrder(id: labOrderId(gateWayObject: gateWayObject)), let patient = existing.patient else {return nil}
        // Store function will remove existing one
        return storeLaboratoryOrder(patient: patient, gateWayObject: gateWayObject, pdf: pdf)
    }
    
    // MARK: Fetch
    func fetchLaboratoryOrders() -> [LaboratoryOrder] {
        guard let context = managedContext else {return []}
        do {
            let results = try context.fetch(LaboratoryOrder.fetchRequest())
            return results
        } catch let error as NSError {
            Logger.log(string: "Could not save. \(error), \(error.userInfo)", type: .storage)
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
