//
//  StorageServiceTests.swift
//  BCVaccineCardTests
//
//  Created by Mohamed Fawzy on 26/01/2022.
//

import XCTest
import CoreData
@testable import BCVaccineCard

class StorageServiceTests: XCTestCase {
    var storageService: StorageService!
    var coreDataStack: CoreDataStackProtocol!
    
    override func setUp() {
        super.setUp()
        coreDataStack = TestCoreDataStack()
        storageService = StorageService(managedContext: coreDataStack.managedContext)
    }

    override func tearDown() {
        super.tearDown()
        storageService = nil
        coreDataStack = nil
    }
    
    // Patient Test Cases
    
    func testNoPatientExistOnLunch() {
        // when
        let patients = storageService.fetchPatients()
        // then
        XCTAssertTrue(patients.isEmpty)
    }
    
    func testAddingOnePatient() {
        // given
        let name = "Adam"
        let birthday = Date()
        let phn = "12qw131"
        let storedPatient = storageService.storePatient(name: name, birthday: birthday, phn: phn)
        // when
        let patients = storageService.fetchPatients()
        let patientOne = patients.first
        // then
        XCTAssertEqual(patients.count, 1)
        XCTAssertNotNil(patientOne)
        XCTAssertEqual(storedPatient, patientOne)
        XCTAssertEqual(patientOne?.name, name)
        XCTAssertEqual(patientOne?.birthday, birthday)
        XCTAssertEqual(patientOne?.phn, phn)
    }
    
    func testFetchingPatientByPHN() {
        // given
        let phn = "d"
        let storedPatient = storageService.storePatient(name: "Any", birthday: Date(), phn: phn)
        // when
        let patient = storageService.fetchPatient(phn: phn)
        // then
        XCTAssertEqual(patient?.phn, phn)
        XCTAssertEqual(patient, storedPatient)
    }
    
    func testAddingMultiplePatientaWithSameNameAndPassword() {
        // given
        let name = "adam"
        let birthday = Date()
        // when
        (1...3).forEach { _ in
            _ = storageService.storePatient(name: name, birthday: birthday)
        }
        // then
        let patients = storageService.fetchPatients()
        XCTAssertEqual(patients.count, 1)
    }
    
    func testAddingMultiplePatiensWithDifferentNameAndPasswordButSamePHN() {
        // given
        let names = ["adam", "John", "James"]
        let birthdays = [Date(), Date(timeIntervalSinceNow: 60*20), Date(timeIntervalSinceNow: 60*30)]
        let phn = "1A2B3C4D"
        // when
        names.enumerated().forEach { i, name in
            _ = storageService.storePatient(name: name, birthday: birthdays[i], phn: phn)
        }
        // then
        let patients = storageService.fetchPatients()
        XCTAssertEqual(patients.count, 1)
    }
    
    func testUpdatePatientWhileNoPatientsExist() {
        // given
        let name = "John"
        let birthday = Date() // not exist date
        let phn = "1A2B3C4D"
        // when
        let storedPatient = storageService.updatePatient(phn: phn, name: name, birthday: birthday)
        let patient = storageService.fetchPatients().first
        // then
        XCTAssertNil(storedPatient)
        XCTAssertNil(patient)
    }
    
    func testUpdatePatientWithDateNotEqualToStoredOne() {
        // given
        let oldName = ""
        let oldBirthday = Date()
        let newName = "John"
        let newBirthday = Date(timeIntervalSinceNow: 11.0 * 60.0) // different date
        let phn = "1A2B3C4D"
        // when
        let storedPatient = storageService.storePatient(name: oldName, birthday: oldBirthday)
        let updatedPatient = storageService.updatePatient(phn: phn, name: newName, birthday: newBirthday)
        let patients = storageService.fetchPatients()
        // then
        XCTAssertNotNil(storedPatient)
        XCTAssertNil(updatedPatient)
        XCTAssertEqual(patients.count, 1)
    }
    
    func testUpdatePatientPhnByNameAndBirthday() {
        // given
        let name = "Nil"
        let birthday = Date()
        let phn = "1A2B3C4D"
        // when
        let storedPatient = storageService.storePatient(name: name, birthday: birthday)
        let updatedPatient = storageService.updatePatient(phn: phn, name: name, birthday: birthday)
        let allPatients = storageService.fetchPatients()
        let fetchedPatient = allPatients.first
        // then
        XCTAssertNotNil(storedPatient)
        XCTAssertNotNil(updatedPatient)
        XCTAssertEqual(allPatients.count, 1)
        XCTAssertEqual(fetchedPatient?.name, name)
        XCTAssertEqual(fetchedPatient?.phn, phn)
    }
    
    func testUpdatePatientNameAndBirthdayByPHN() {
        // given
        let name = "Nil"
        let birthday = Date()
        let phn = "1A2B3C4D"
        // when
        _ = storageService.storePatient(phn: phn)
        let patientWithOnlyPHN = storageService.fetchPatients().first
        let updatedPatient = storageService.updatePatient(phn: phn, name: name, birthday: birthday)
        let allPatients = storageService.fetchPatients()
        let fetchedPatient = allPatients.first
        // then
        XCTAssertNotNil(patientWithOnlyPHN)
        XCTAssertNotNil(updatedPatient)
        XCTAssertEqual(allPatients.count, 1)
        XCTAssertEqual(fetchedPatient?.name, name)
        XCTAssertEqual(fetchedPatient?.birthday, birthday)
    }
    
    func testDeletePatientByPHN() {
        // given
        let phn = "1A2B3C4D"
        // when
        _ = storageService.storePatient(phn: phn)
        let patientWithOnlyPHN = storageService.fetchPatients().first
        storageService.deletePatient(phn: phn)
        let allPatients = storageService.fetchPatients()
        // then
        XCTAssertNotNil(patientWithOnlyPHN)
        XCTAssertEqual(allPatients.count, 0)
    }
    
    func testDeletePatientByNameAndBirthday() {
        // given
        let name = "David"
        let birthday = Date()
        // when
        _ = storageService.storePatient(name: name, birthday: birthday)
        let patientsListWithOneRecord = storageService.fetchPatients()
        storageService.deletePatient(name: name, birthday: birthday)
        let emptyPatientsList = storageService.fetchPatients()
        // then
        XCTAssertEqual(patientsListWithOneRecord.count, 1)
        XCTAssertEqual(emptyPatientsList.count, 0)
    }

    // Vaccine Card Test Cases
    
    func testStoreFetchVaccineCard() {
        // given
        let model = SampleVaxCard()
        // when storing card and fetching it back
        guard let patient = storePatient() else {
            XCTFail() // failed to create patient entity
            return
        }
        let storeExp = expectation(description: "store vaccine card")
        storageService.storeVaccineCard(vaccineQR: model.vaccineQR, name: model.name, issueDate: model.issueDate, hash: model.hash, patient: patient, authenticated: model.authenticated) { _ in
            storeExp.fulfill()
        }
        waitForExpectations(timeout: 2)
        let cardsList = storageService.fetchVaccineCards()
        let card = storageService.fetchVaccineCard(code: model.vaccineQR)
        // then
        XCTAssertEqual(cardsList.count, 1)
        XCTAssertEqual(card?.code, model.vaccineQR)
        XCTAssertEqual(card?.name, model.name)
        XCTAssertEqual(card?.issueDate, model.issueDate)
        XCTAssertEqual(card?.firHash, model.hash)
        XCTAssertEqual(card?.authenticated, model.authenticated)
        XCTAssertEqual(card?.authenticated, model.authenticated)
        XCTAssertEqual(card?.sortOrder, 0)
        XCTAssertEqual(card?.patient, patient)
    }
    
    func testUpdateVaccinCcard() {
        // given
        let model = SampleVaxCard()
        // when storing card and fetching it back
        guard let patient = storePatient() else {
            XCTFail("failed to create patient entity")
            return
        }
        let storeExp = expectation(description: "store card")
        storageService.storeVaccineCard(vaccineQR: model.vaccineQR, name: model.name, issueDate: model.issueDate, hash: model.hash, patient: patient, authenticated: model.authenticated) { _ in
            storeExp.fulfill()
        }
        waitForExpectations(timeout: 2)
        let cardsList = storageService.fetchVaccineCards()
        var card = storageService.fetchVaccineCard(code: model.vaccineQR)
        // when updating the existing card
        let federalPass = "Test federal Pass"
        let updatExp = expectation(description: "update vaccine card")
        storageService.updateVaccineCard(card: card!, federalPass: federalPass) { _ in
            updatExp.fulfill()
        }
        waitForExpectations(timeout: 2)
        card = storageService.fetchVaccineCard(code: model.vaccineQR)
        // then
        XCTAssertEqual(cardsList.count, 1)
        XCTAssertEqual(card?.federalPass, federalPass)
        XCTAssertEqual(card?.code, model.vaccineQR)
        XCTAssertEqual(card?.name, model.name)
        XCTAssertEqual(card?.issueDate, model.issueDate)
        XCTAssertEqual(card?.firHash, model.hash)
        XCTAssertEqual(card?.authenticated, model.authenticated)
        XCTAssertEqual(card?.sortOrder, 0)
        XCTAssertEqual(card?.patient, patient)

    }
    
    func testDeleteVaccineCard() {
        // given
        let model = SampleVaxCard()
        // when storing card and fetching it back
        guard let patient = storePatient() else {
            XCTFail()
            return
        }
        let storeExp = expectation(description: "store vaccine card")
        storageService.storeVaccineCard(vaccineQR: model.vaccineQR, name: model.name, issueDate: model.issueDate, hash: model.hash, patient: patient, authenticated: model.authenticated) { _ in
            storeExp.fulfill()
        }
        waitForExpectations(timeout: 2)
        // when deleting card and fetch all cards back
        storageService.deleteVaccineCard(vaccineQR: model.vaccineQR)
        let cardsList = storageService.fetchVaccineCards()
        // then
        XCTAssertTrue(cardsList.isEmpty)
        // when fetching patients after deleting vaccine cards
        let patients = storageService.fetchPatients()
        // then
        XCTAssertEqual(patients.count, 1)
    }
    
    func testAddingTestResult() {
        // giving
        let patietName = "Donald"
        let bday = Date(timeIntervalSinceNow: -60*60*24*365*30)
        let reportId = "1"
        let phn = "123253"
        let authenticated = true
        let gatewayTestResult = self.sampleTestResult(patietName: patietName, reportId: reportId)
        // when
        let patient = self.storageService.storePatient(name: patietName, birthday: bday, phn: phn)!
        _ = storageService.storeTestResults(patient: patient, gateWayResponse: gatewayTestResult, authenticated: authenticated)
        let testResults = storageService.fetchTestResults()
        let patients = storageService.fetchPatients()
        let testResult = testResults.first
        let testExists = storageService.testExists(from: gatewayTestResult)
        // then
        XCTAssertEqual(patients.count,1)
        XCTAssertEqual(testResults.count,1)
        XCTAssertTrue(testExists)
        XCTAssertEqual(testResult?.results?.count, 1)
        XCTAssertEqual(testResult?.authenticated,authenticated)
        XCTAssertEqual(testResult?.patient?.name, patietName)
        XCTAssertEqual(testResult?.patient?.birthday, bday)
        XCTAssertEqual(testResult?.patient?.phn, phn)
        XCTAssertEqual(patient.phn, phn)
        XCTAssertEqual(patient.name, patietName)
    }
    
    func testAddingImmunizationRecord() {
        // given
        let vaxCard = SampleVaxCard()
        // when storing card and fetching it back
        guard let patient = storePatient() else {
            XCTFail() // failed to create patient entity
            return
        }
        let storeExp = expectation(description: "store vaccine card")
        storageService.storeVaccineCard(vaccineQR: vaxCard.vaccineQR, name: vaxCard.name, issueDate: vaxCard.issueDate, hash: vaxCard.hash, patient: patient, authenticated: vaxCard.authenticated) { _ in
            storeExp.fulfill()
        }
        waitForExpectations(timeout: 2)
        let card = storageService.fetchVaccineCard(code: vaxCard.vaccineQR)!
        // when create immunization records
        storageService.createImmunizationRecords(for: card) { _  in }
        let healthRecords = storageService.getHeathRecords()
        let record = healthRecords.first
        // then
        XCTAssertEqual(healthRecords.count,1)
        XCTAssertEqual(record?.patientName, vaxCard.name)
        XCTAssertEqual(record?.patient.name, patient.name)
        XCTAssertEqual(record?.patient.phn, patient.phn)
        XCTAssertEqual(record?.patient.birthday, patient.birthday)
    }
}

extension StorageServiceTests {
    func storePatient(name: String? = "Any Name", birthday: Date? = Date(), phn: String? = "Any PHN") -> BCVaccineCard.Patient? {
        return storageService.storePatient(name: name, birthday: birthday, phn: phn)
    }
    
    struct SampleVaxCard {
        let vaccineQR = "QR"
        let name = "Sam"
        let issueDate = Date()
        let hash = "Hash"
        let birthday = Date()
        let phn = "AnyPHN"
        let authenticated = false
    }
    
    func sampleTestResult(patietName: String, reportId: String) -> GatewayTestResultResponse {
        let record = GatewayTestResultResponseRecord(patientDisplayName: patietName, lab: nil, reportId: reportId, collectionDateTime: "2022-01-01", resultDateTime: nil, testName: nil, testType: nil, testStatus: nil, testOutcome: nil, resultTitle: nil, resultDescription: nil, resultLink: nil)
        let resourcePayload = GatewayTestResultResponse.ResourcePayload(loaded: true, retryin: 1, records: [record])
        return GatewayTestResultResponse(resourcePayload: resourcePayload, totalResultCount: 1, pageIndex: nil, pageSize: nil, resultStatus: nil, resultError: nil)
    }
}
