//
//  Storeage+TestResults.swift
//  BCVaccineCard
//
//  Created by Amir on 2021-11-29.
//

import Foundation

extension StorageService {
    
    
    /// Store a test result from a HealthGateway response
    /// - Parameter gateWayResponse: codable response object from Health Gateway
    /// - Returns: String id of record if stored successfully
    public func saveTestResult(phn: String, birthdate: Date, gateWayResponse: GatewayTestResultResponse) -> String? {
        let id = gateWayResponse.md5Hash() ?? UUID().uuidString
        
        guard let context = managedContext else {return nil}
        let model = CovidLabTestResult(context: context)
        
        model.id = gateWayResponse.md5Hash()
        model.phn = phn
        model.birthday = birthdate
        model.user = fetchUser()
        
        var testResults: [TestResult] = []
        
        for record in gateWayResponse.records {
            if let resultModel = saveTestResult(
                   resultId: id,
                   patientDisplayName: record.patientDisplayName,
                   lab: record.lab,
                   reportId: record.reportId,
                   collectionDateTime: record.collectionDateTime,
                   resultDateTime: record.resultDateTime,
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
            return id
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
            return nil
        }
    }
    
    
    /// Store a test result
    /// - Returns: String id of record if stored successfully
    private func saveTestResult(
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
        resultDescription: String?,
        resultLink: String?) -> TestResult? {
            guard let context = managedContext else {return nil}
            let testResult = TestResult(context: context)
            testResult.id = reportId
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
                return testResult
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
                return nil
            }
    }
    
    
    /// delete a test result for given id
    /// - Parameter id: id of record. this can be the report id or the id generated by during storage (TestResult.id)
    func deleteTestResult(id: String) {
        guard let context = managedContext else {return}
        do {
            let tests = try context.fetch(CovidLabTestResult.fetchRequest())
            guard let item = tests.filter({ ($0.id == id) }).first else {return}
            context.delete(item)
            try context.save()
        } catch let error as NSError {
            print("Could not delete. \(error), \(error.userInfo)")
            return
        }
    }
    
    /// Returns all test results stored for user
    /// - Parameter userId: User id. if left empty, the results results for the currently authenticated user.
    /// - Returns: All Test results stored for the given user
    func fetchTestResults(for userId: String? = AuthManager().userId()) -> [CovidLabTestResult] {
        guard let context = managedContext else {return []}
        do {
            let users = try context.fetch(User.fetchRequest())
            guard let current = users.filter({$0.userId == userId}).first else {return []}
            return current.testResultArray
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return []
        }
    }
    
}
