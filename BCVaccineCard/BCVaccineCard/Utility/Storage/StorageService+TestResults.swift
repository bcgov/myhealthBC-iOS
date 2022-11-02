//
//  Storeage+TestResults.swift
//  BCVaccineCard
//
//  Created by Amir on 2021-11-29.
//

import Foundation

protocol StorageCovidTestResultManager {
    
    // MARK: Store
    
    func storeCovidTestResults(
        patient: Patient,
        in: AuthenticatedTestResultsResponseModel,
        authenticated: Bool,
        manuallyAdded: Bool,
        pdf: String?
    ) -> [CovidLabTestResult]
    
    func storeCovidTestResults(
        patient: Patient,
        in: AuthenticatedTestResultsResponseModel.ResourcePayload.Order,
        authenticated: Bool,
        manuallyAdded: Bool,
        pdf: String?
    ) -> CovidLabTestResult?
    
    /// Store a Test results for given patient
    /// - Parameters:
    ///   - patient: owenr of the test result
    ///   - gateWayResponse: gateway response
    ///   - authenticated: Indicating if this record is for an authenticated user
    /// - Returns: stored object
    func storeCovidTestResults(
        patient: Patient,
        gateWayResponse: GatewayTestResultResponse,
        authenticated: Bool,
        manuallyAdded: Bool,
        pdf: String?
    ) -> CovidLabTestResult?
    
    /// Store a single test result
    /// - Returns: String id of record if stored successfully
    func storeCovidTestResult(
        resultId: String,
        patientDisplayName: String?,
        lab: String?,
        reportId: String?,
        collectionDateTime: Date?,
        resultDateTime: Date?,
        testName: String?,
        testType: String?,
        testStatus: String?,
        testOutcome: String?,
        resultTitle: String?,
        resultDescription: [String]?,
        resultLink: String?) -> TestResult?
    
    // MARK: Update
    /// Update a test result from a HealthGateway response
    /// - Parameter gateWayResponse: codable response object from Health Gateway
    func updateCovidTestResult(
        gateWayResponse: GatewayTestResultResponse,
        manuallyAdded: Bool,
        pendingBackgroundRefetch: Bool,
        pdf: String?,
        completion: @escaping(CovidLabTestResult?)->Void)
    
    // MARK: Delete
    /// delete a test result for given id
    /// - Parameter id: id of record (not reportId).
    func deleteCovidTestResult(id: String, sendDeleteEvent: Bool)
    
    // MARK: Fetch
    func fetchCovidTestResults() -> [CovidLabTestResult]
    func fetchCovidTestResult(id: String) -> CovidLabTestResult?
}


extension StorageService: StorageCovidTestResultManager {
    
    func storeCovidTestResults(
        patient: Patient,
        in responseObeject: AuthenticatedTestResultsResponseModel,
        authenticated: Bool,
        manuallyAdded: Bool,
        pdf: String?
    ) -> [CovidLabTestResult] {
        guard let orders = responseObeject.resourcePayload?.orders else {return []}
        var storedObjects: [CovidLabTestResult] = []
        for order in orders {
            if let storedObject = storeCovidTestResults(patient: patient, in: order, authenticated: authenticated, manuallyAdded: manuallyAdded, pdf: pdf) {
                storedObjects.append(storedObject)
            }
            
        }
        return storedObjects
    }
    
    
    func storeCovidTestResults(
        patient: Patient,
        in responseObeject: AuthenticatedTestResultsResponseModel.ResourcePayload.Order,
        authenticated: Bool,
        manuallyAdded: Bool,
        pdf: String?
    ) -> CovidLabTestResult? {
        
        let id = responseObeject.md5Hash() ?? UUID().uuidString
        deleteCovidTestResult(id: id, sendDeleteEvent: false)
        
        guard let context = managedContext else {
            return nil
        }
        let model = CovidLabTestResult(context: context)
        model.patient = patient
        model.id = id
        model.createdAt = Date()
        model.authenticated = authenticated
        model.pdf = pdf
        model.reportAvailable = responseObeject.reportAvailable ?? false
        model.orderId = responseObeject.id
        var testResults: [TestResult] = []
        guard let records = responseObeject.labResults else {
            return nil
        }
        
        for record in records {
            let collectionDateTime = record.collectedDateTime?.getGatewayDate()
            let resultDateTime = record.resultDateTime?.getGatewayDate()
            
            if let resultModel = storeCovidTestResult(
                resultId: id,
                patientDisplayName: patient.name,
                lab: responseObeject.reportingLab,
                reportId: record.id,
                collectionDateTime: collectionDateTime,
                resultDateTime: resultDateTime,
                testName: record.loincName,
                testType: record.testType,
                testStatus: record.testStatus,
                testOutcome: record.labResultOutcome,
                resultTitle: record.loincName,
                resultDescription: record.resultDescription,
                resultLink: record.resultLink) {
                
                testResults.append(resultModel)
                model.addToResults(resultModel)
            }
            
        }
        do {
            try context.save()
            let _ = manuallyAdded == true ? self.notify(event: StorageEvent(event: .ManuallyAddedRecord, entity: .CovidLabTestResult, object: model)) : self.notify(event: StorageEvent(event: .Save, entity: .CovidLabTestResult, object: model))
            return model
        } catch let error as NSError {
            Logger.log(string: "Could not save. \(error), \(error.userInfo)", type: .storage)
            return nil
        }
    }
    
    public func storeCovidTestResults(patient: Patient, gateWayResponse: GatewayTestResultResponse, authenticated: Bool, manuallyAdded: Bool, pdf: String?) -> CovidLabTestResult? {
        let id = gateWayResponse.md5Hash() ?? UUID().uuidString
        deleteCovidTestResult(id: id, sendDeleteEvent: false)
        guard let context = managedContext else {return nil}
        let model = CovidLabTestResult(context: context)
        model.patient = patient
        model.id = id
        model.createdAt = Date()
        model.authenticated = authenticated
        model.pdf = pdf
        model.reportAvailable = gateWayResponse.resourcePayload?.reportAvailable ?? false
        model.orderId = gateWayResponse.resourcePayload?.id
        var testResults: [TestResult] = []
        guard let records = gateWayResponse.resourcePayload?.records else { return nil }
        for record in records {
            // Note: For Amir - Adding this here as a fallback for computed propertied
            // FIXME: Remove the next two lines once we decide on how we are going to handle the new authenticated test result core data model
            let collectionDateTime = record.collectionDateTimeDate ?? Date.Formatter.gatewayDateAndTimeWithTimeZone.date(from: record.collectionDateTime ?? "")
            let resultDateTime = record.resultDateTimeDate ?? Date.Formatter.gatewayDateAndTimeWithTimeZone.date(from: record.resultDateTime ?? "")
            if let resultModel = storeCovidTestResult(
                resultId: id,
                patientDisplayName: record.patientDisplayName,
                lab: record.lab,
                reportId: record.reportId,
                collectionDateTime: collectionDateTime,
                resultDateTime: resultDateTime,
                testName: record.testName,
                testType: record.testType,
                testStatus: record.testStatus,
                testOutcome: record.testOutcome,
                resultTitle: record.resultTitle,
                resultDescription: record.resultDescription,
                resultLink: record.resultLink) {
                
                testResults.append(resultModel)
                model.addToResults(resultModel)
            }
            
        }
        do {
            try context.save()
            let _ = manuallyAdded == true ? self.notify(event: StorageEvent(event: .ManuallyAddedRecord, entity: .CovidLabTestResult, object: model)) : self.notify(event: StorageEvent(event: .Save, entity: .CovidLabTestResult, object: model))
            return model
        } catch let error as NSError {
            Logger.log(string: "Could not save. \(error), \(error.userInfo)", type: .storage)
            return nil
        }
    }
    
    internal func storeCovidTestResult(
        resultId: String,
        patientDisplayName: String?,
        lab: String?,
        reportId: String?,
        collectionDateTime: Date?,
        resultDateTime: Date?,
        testName: String?,
        testType: String?,
        testStatus: String?,
        testOutcome: String?,
        resultTitle: String?,
        resultDescription: [String]?,
        resultLink: String?) -> TestResult?
    {
        guard let context = managedContext else {return nil}
        let testResult = TestResult(context: context)
        testResult.id = UUID().uuidString
        testResult.patientDisplayName = patientDisplayName
        testResult.lab = lab
        testResult.reportId = reportId
        testResult.collectionDateTime = collectionDateTime
        testResult.resultDateTime = resultDateTime
        testResult.testName = testName
        testResult.testType = testType
        testResult.testStatus = testStatus
        testResult.testOutcome = testOutcome
        testResult.resultTitle = resultTitle
        testResult.resultDescription = resultDescription
        testResult.resultLink = resultLink
        do {
            try context.save()
            self.notify(event: StorageEvent(event: .Save, entity: .TestResult, object: testResult))
            return testResult
        } catch let error as NSError {
            Logger.log(string: "Could not save. \(error), \(error.userInfo)", type: .storage)
            return nil
        }
    }
    
    
    // MARK: Update
    func updateCovidTestResult(gateWayResponse: GatewayTestResultResponse, manuallyAdded: Bool, pendingBackgroundRefetch: Bool, pdf: String?, completion: @escaping(CovidLabTestResult?)->Void) {
        guard
            let existing = findExistingResult(gateWayResponse: gateWayResponse),
            let existingId = existing.id,
            let existingPatient = existing.patient
        else {return completion(nil)}
        
        let authStatus = existing.authenticated
        
        // Delete existing
         deleteCovidTestResult(id: existingId, sendDeleteEvent: false)
        // Store the new one.
        if let object = storeCovidTestResults(patient: existingPatient, gateWayResponse: gateWayResponse, authenticated: authStatus, manuallyAdded: manuallyAdded, pdf: pdf) {
            let _ = manuallyAdded == true ? notify(event: StorageEvent(event: .ManuallyAddedRecord, entity: .CovidLabTestResult, object: object)) : pendingBackgroundRefetch == true ? notify(event: StorageEvent(event: .ManuallyAddedPendingTestBackgroundRefetch, entity: .CovidLabTestResult, object: object)) : notify(event: StorageEvent(event: .Update, entity: .CovidLabTestResult, object: object))
            return completion(object)
        }
        return completion(nil)
        
    }
    
    // MARK: Delete
    func deleteCovidTestResult(id: String, sendDeleteEvent: Bool) {
        guard let object = fetchCovidTestResult(id: id) else {return}
        delete(object: object)
        if sendDeleteEvent {
            notify(event: StorageEvent(event: .Delete, entity: .CovidLabTestResult, object: object))
        }
    }
    
    // MARK: Fetch
    func fetchCovidTestResults() -> [CovidLabTestResult] {
        guard let context = managedContext else {return []}
        do {
            let patients = try context.fetch(Patient.fetchRequest())
            let tests = patients.map({$0.testResultArray})
            return Array(tests.joined())
        } catch let error as NSError {
            Logger.log(string: "Could not save. \(error), \(error.userInfo)", type: .storage)
            return []
        }
    }
    
    func fetchCovidTestResult(id: String) -> CovidLabTestResult? {
        guard let context = managedContext else {return nil}
        do {
            let tests = try context.fetch(CovidLabTestResult.fetchRequest())
            return tests.filter({ ($0.id == id) }).first
        } catch let error as NSError {
            Logger.log(string: "Could not save. \(error), \(error.userInfo)", type: .storage)
            return nil
        }
    }
    
    // MARK: Hekpers
    func covidTestExists(from gateWayResponse: GatewayTestResultResponse) -> Bool {
        guard let id = gateWayResponse.md5Hash() else {return false}
        return !fetchCovidTestResults().filter({$0.id == id}).isEmpty
    }
    
    /// Find the stored test record that is likely the one from the response:
    /// - Parameter gateWayResponse: gateway test result response
    /// - Returns: Stored CovidLabTestResult object that matches the response
    func findExistingResult(gateWayResponse: GatewayTestResultResponse) -> CovidLabTestResult? {
        let tests = fetchCovidTestResults()
        guard let responseTestIds = gateWayResponse.resourcePayload?.records.map({$0.reportId}) else {
            return nil
        }
        // Loop through stored tests
        for test in tests {
            let results = test.resultArray
            // Cache ids of stored results in this test
            var storedTestIds = results.map({$0.reportId})
            // Loop through the ids in the gateway response
            // and remove ids in storedTestIds that are also in responseTestIds
            for recordId in responseTestIds {
                if let index = storedTestIds.firstIndex(of: recordId) {
                    storedTestIds.remove(at: index)
                }
            }
            
            // now if responseTestIds is empty, they were all contained in the response.
            if storedTestIds.isEmpty && !responseTestIds.isEmpty {
                return test
            }
        }
        return nil
    }
}

fileprivate extension String {
    func vaxDate() -> Date? {
        let dateFormatter = Date.Formatter.yearMonthDay
        return dateFormatter.date(from:self)
    }
}
