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
        let vaccineQR = "QR"
        let name = "Sam"
        let issueDate = Date()
        let hash = "Hash"
        let birthday = Date()
        let phn = "AnyPHN"
        let authenticated = false
        // when storing card and fetching it back
        guard let patient = storageService.storePatient(name: name, birthday: birthday, phn: phn) else {
            XCTFail() // failed to create patient entity
            return
        }
        let storeExp = expectation(description: "store vaccine card")
        storageService.storeVaccineVard(vaccineQR: vaccineQR, name: name, issueDate: issueDate, hash: hash, patient: patient, authenticated: authenticated) { _ in
            storeExp.fulfill()
        }
        waitForExpectations(timeout: 2)
        let cardsList = storageService.fetchVaccineCards()
        let card = storageService.fetchVaccineCard(code: vaccineQR)
        // then
        XCTAssertEqual(cardsList.count, 1)
        XCTAssertEqual(card?.code, vaccineQR)
        XCTAssertEqual(card?.name, name)
        XCTAssertEqual(card?.issueDate, issueDate)
        XCTAssertEqual(card?.firHash, hash)
        XCTAssertEqual(card?.authenticated, authenticated)
        XCTAssertEqual(card?.authenticated, authenticated)
        XCTAssertEqual(card?.sortOrder, 0)
        XCTAssertEqual(card?.patient, patient)
    }
    
    func testUpdateVaccinCcard() {
        // given
        let vaccineQR = "QR"
        let name = "Sam"
        let issueDate = Date()
        let hash = "Hash"
        let birthday = Date()
        let phn = "AnyPHN"
        let authenticated = false
        // when storing card and fetching it back
        guard let patient = storageService.storePatient(name: name, birthday: birthday, phn: phn) else {
            XCTFail("failed to create patient entity")
            return
        }
        let storeExp = expectation(description: "store vaccine card")
        storageService.storeVaccineVard(vaccineQR: vaccineQR, name: name, issueDate: issueDate, hash: hash, patient: patient, authenticated: authenticated) { _ in
            storeExp.fulfill()
        }
        waitForExpectations(timeout: 2)
        let cardsList = storageService.fetchVaccineCards()
        var card = storageService.fetchVaccineCard(code: vaccineQR)
        // when updating the existing card
        let federalPass = "Test federal Pass"
        let updatExp = expectation(description: "update vaccine card")
        storageService.updateVaccineCard(card: card!, federalPass: federalPass) { _ in
            updatExp.fulfill()
        }
        waitForExpectations(timeout: 2)
        card = storageService.fetchVaccineCard(code: vaccineQR)
        // then
        XCTAssertEqual(cardsList.count, 1)
        XCTAssertEqual(card?.federalPass, federalPass)
        XCTAssertEqual(card?.code, vaccineQR)
        XCTAssertEqual(card?.name, name)
        XCTAssertEqual(card?.issueDate, issueDate)
        XCTAssertEqual(card?.firHash, hash)
        XCTAssertEqual(card?.authenticated, authenticated)
        XCTAssertEqual(card?.authenticated, authenticated)
        XCTAssertEqual(card?.sortOrder, 0)
        XCTAssertEqual(card?.patient, patient)

    }
    
    func testDeleteVaccineCard() {
        // given
        let vaccineQR = "QR"
        let name = "Sam"
        let issueDate = Date()
        let hash = "Hash"
        let birthday = Date()
        let phn = "AnyPHN"
        let authenticated = false
        // when storing card and fetching it back
        guard let patient = storageService.storePatient(name: name, birthday: birthday, phn: phn) else {
            XCTFail("failed to create patient entity")
            return
        }
        let storeExp = expectation(description: "store vaccine card")
        storageService.storeVaccineVard(vaccineQR: vaccineQR, name: name, issueDate: issueDate, hash: hash, patient: patient, authenticated: authenticated) { _ in
            storeExp.fulfill()
        }
        waitForExpectations(timeout: 2)
        // when deleting card and fetch all cards back
        storageService.deleteVaccineCard(vaccineQR: vaccineQR)
        let cardsList = storageService.fetchVaccineCards()
        // then
        XCTAssertTrue(cardsList.isEmpty)
        // when fetching patients after deleting vaccine cards
        let patients = storageService.fetchPatients()
        // then
        XCTAssertEqual(patients.count, 1)
    }
}
