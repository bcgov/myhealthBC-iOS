//
//  StorageService+LabOrder.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2022-02-18.
//

import Foundation
import BCVaccineValidator
import CoreData

protocol StorageLaboratoryOrderManager {
    
    // MARK: Store
    func storeLaboratoryOrders(
        patient: Patient,
        gateWayResponse: AuthenticatedLaboratoryOrdersResponseObject,
        completion: @escaping([LaboratoryOrder])->Void
    )
    
    func storeLaboratoryOrder(
        patient: Patient,
        gateWayObject: AuthenticatedLaboratoryOrdersResponseObject.ResourcePayload.Order,
        pdf: String?,
        completion: @escaping(LaboratoryOrder?)->Void
    )
    
    func storeLaboratoryOrder(
        context:  NSManagedObjectContext,
        patient: Patient,
        id: String,
        labPdfId: String?,
        reportingSource: String?,
        reportID: String?,
        collectionDateTime: Date?,
        timelineDateTime: Date?,
        commonName: String?,
        orderingProvider: String?,
        testStatus: String?,
        reportAvailable: Bool,
        laboratoryTests: [LaboratoryTest]?,
        pdf: String?,
        completion: @escaping(LaboratoryOrder?)->Void
    )
    
    func storeLaboratoryTest(
        gateWayObject: AuthenticatedLaboratoryOrdersResponseObject.ResourcePayload.Order.LaboratoryTest,
        context:  NSManagedObjectContext,
        completion: @escaping(LaboratoryTest?)->Void
    )
    
    func storeLaboratoryTest(
        batteryType: String?,
        obxID: String?,
        outOfRange: Bool?,
        loinc: String?,
        testStatus: String?,
        context:  NSManagedObjectContext,
        completion: @escaping(LaboratoryTest?)->Void
    )
    
    // MARK: Update
//    func updateLaboratoryOrder(
//        gateWayObject: AuthenticatedLaboratoryOrdersResponseObject.ResourcePayload.Order,
//        pdf: String?
//    ) -> LaboratoryOrder?
    
    // MARK: Delete
    func deleteLaboratoryOrder(id: String, sendDeleteEvent: Bool)
    
    // MARK: Fetch
    func fetchLaboratoryOrders() -> [LaboratoryOrder]
    func fetchLaboratoryOrder(id: String) -> LaboratoryOrder?
}

extension StorageService: StorageLaboratoryOrderManager {

    func storeLaboratoryOrders(patient: Patient, gateWayResponse: AuthenticatedLaboratoryOrdersResponseObject, completion: @escaping([LaboratoryOrder])->Void) {
        guard let orders = gateWayResponse.resourcePayload?.orders else {return completion([])}
        var storedOrders: [LaboratoryOrder] = []
        let queue = DispatchQueue(label: "labOrders", qos: .userInitiated)
        classQueue.async {
            let dispatchGroup = DispatchGroup()
            for order in orders {
                // Note: Currently no easy way to get PDF, so in this case, we will store nil
                dispatchGroup.enter()
                queue.async {
                    self.storeLaboratoryOrder(patient: patient, gateWayObject: order, pdf: nil, completion: { storedOrder in
                        if let result = storedOrder {
                            storedOrders.append(result)
                        }
                        dispatchGroup.leave()
                    })
                }
            }
            dispatchGroup.notify(queue: .global(qos: .userInitiated)) {
                self.notify(event: StorageEvent(event: .Save, entity: .LaboratoryOrder, object: storedOrders))
                return completion(storedOrders)
            }
        }
    }
    
    func storeLaboratoryOrder(
        patient: Patient,
        gateWayObject: AuthenticatedLaboratoryOrdersResponseObject.ResourcePayload.Order,
        pdf: String?,
        completion: @escaping(LaboratoryOrder?)->Void
    ) {
            guard let context = managedContext else {return completion(nil)}
            let id = UUID().uuidString
            var storedTests: [LaboratoryTest] = []
            let queue = DispatchQueue(label: "labOrderTests", qos: .userInitiated)
            classQueue.async {
                let dispatchGroup = DispatchGroup()
                if let tests = gateWayObject.laboratoryTests {
                    for test in tests {
                        dispatchGroup.enter()
                        queue.async {
                            self.storeLaboratoryTest(gateWayObject: test, context: context, completion: { result in
                                if let storedTest = result {
                                    storedTests.append(storedTest)
                                }
                                dispatchGroup.leave()
                            })
                        }
                        
                    }
                }
                dispatchGroup.notify(queue: .global(qos: .userInitiated)) {
                    let collectionDateTime = Date.Formatter.gatewayDateAndTime.date(from: gateWayObject.collectionDateTime ?? "") ?? Date()
                    let timelineDateTime = Date.Formatter.gatewayDateAndTime.date(from: gateWayObject.timelineDateTime ?? "") ?? Date()
                    return self.storeLaboratoryOrder(context: context, patient: patient, id: id, labPdfId: gateWayObject.labPdfId, reportingSource: gateWayObject.reportingSource, reportID: gateWayObject.reportID, collectionDateTime: collectionDateTime, timelineDateTime: timelineDateTime, commonName: gateWayObject.commonName, orderingProvider:gateWayObject.orderingProvider, testStatus: gateWayObject.testStatus, reportAvailable: gateWayObject.reportAvailable ?? false, laboratoryTests: storedTests, pdf: pdf, completion: completion)
                }
                
                
            }
           
        }
    
    func storeLaboratoryOrder(context:  NSManagedObjectContext, patient: Patient, id: String, labPdfId: String?, reportingSource: String?, reportID: String?, collectionDateTime: Date?, timelineDateTime: Date?, commonName: String?, orderingProvider: String?, testStatus: String?, reportAvailable: Bool, laboratoryTests: [LaboratoryTest]?, pdf: String?, completion: @escaping(LaboratoryOrder?)->Void) {
        let contextPatientObject = context.object(with: patient.objectID)
        guard let contextPatient = contextPatientObject as? Patient else {
            return completion(nil)
        }
        let labOrder = LaboratoryOrder(context: context)
        labOrder.id = id
        labOrder.authenticated = true
        labOrder.patient = contextPatient
        labOrder.labPdfId = labPdfId
        labOrder.reportingSource = reportingSource
        labOrder.reportID = reportID
        labOrder.collectionDateTime = collectionDateTime
        labOrder.timelineDateTime = timelineDateTime
        labOrder.commonName = commonName
        labOrder.orderingProvider = orderingProvider
        labOrder.reportAvailable = reportAvailable
        labOrder.pdf = pdf
        var labTestsArray: [LaboratoryTest] = []
        let labTests = laboratoryTests ?? []
        let queue = DispatchQueue(label: "labOrderTests2", qos: .userInitiated)
        let dispatchGroup = DispatchGroup()
        classQueue.async {
            for test in labTests {
                dispatchGroup.enter()
                queue.async {
                    self.storeLaboratoryTest(
                        batteryType: test.batteryType,
                        obxID: test.obxID,
                        outOfRange: test.outOfRange,
                        loinc: test.loinc,
                        testStatus: test.testStatus, context: context, completion: { model in
                            if let model = model {
                                labTestsArray.append(model)
                            }
                            dispatchGroup.leave()
                        })
                }
            }
            dispatchGroup.notify(queue: .global(qos: .userInitiated)) {
                context.perform {
                    do {
                        labTestsArray.forEach({labOrder.addToLaboratoryTests($0)})
                        try context.save()
                        return completion(labOrder)
                    } catch let error as NSError {
                        print("Could not save. \(error), \(error.userInfo)")
                        return completion(nil)
                    }
                }
            }
        }
    }
    
    func storeLaboratoryTest(gateWayObject: AuthenticatedLaboratoryOrdersResponseObject.ResourcePayload.Order.LaboratoryTest, context:  NSManagedObjectContext, completion: @escaping(LaboratoryTest?)->Void){
        return storeLaboratoryTest(batteryType: gateWayObject.batteryType, obxID: gateWayObject.obxID, outOfRange: gateWayObject.outOfRange, loinc: gateWayObject.loinc, testStatus: gateWayObject.testStatus, context: context, completion: completion)
    }
    
    func storeLaboratoryTest(batteryType: String?, obxID: String?, outOfRange: Bool?, loinc: String?, testStatus: String?, context:  NSManagedObjectContext, completion: @escaping(LaboratoryTest?)->Void) {
        let labTest = LaboratoryTest(context: context)
        labTest.batteryType = batteryType
        labTest.obxID = obxID
        labTest.outOfRange = outOfRange ?? false
        labTest.loinc = loinc
        labTest.testStatus = testStatus
        context.perform {
            do {
                try context.save()
                return completion(labTest)
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
                return completion(nil)
            }
        }
    }
    
    /// This function generates a hash to be used as an id without the laboratory tests.
    private func labOrderId(gateWayObject: AuthenticatedLaboratoryOrdersResponseObject.ResourcePayload.Order) -> String {
        var copy = AuthenticatedLaboratoryOrdersResponseObject.ResourcePayload.Order(labPdfId: gateWayObject.labPdfId, reportingSource: gateWayObject.reportingSource, reportID: gateWayObject.reportID, collectionDateTime: gateWayObject.collectionDateTime, timelineDateTime: gateWayObject.timelineDateTime, commonName: gateWayObject.commonName, orderingProvider: gateWayObject.orderingProvider, testStatus: gateWayObject.testStatus, reportAvailable: gateWayObject.reportAvailable, laboratoryTests: [])
        return copy.md5Hash() ?? UUID().uuidString
    }
    
    
//    func updateLaboratoryOrder(gateWayObject: AuthenticatedLaboratoryOrdersResponseObject.ResourcePayload.Order, pdf: String?) -> LaboratoryOrder? {
//        guard let existing = fetchLaboratoryOrder(id: labOrderId(gateWayObject: gateWayObject)), let patient = existing.patient else {return nil}
//        // Store function will remove existing one
//        return storeLaboratoryOrder(patient: patient, gateWayObject: gateWayObject, pdf: pdf)
//    }
    
    // MARK: Fetch
    func fetchLaboratoryOrders() -> [LaboratoryOrder] {
        guard let context = managedContext else {return []}
        do {
            let results = try context.fetch(LaboratoryOrder.fetchRequest())
            return results
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
