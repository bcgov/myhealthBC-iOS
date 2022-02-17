//
//  NetworkLayerTests.swift
//  BCVaccineCard
//
//  Created by Mohamed Fawzy on 15/02/2022.
//

import XCTest
@testable import BCVaccineCard
@testable import Alamofire

class NetworkLayerTests: XCTestCase {

    var sut: APIClient!
    var vc: UIViewController!
    var interceptor: InterceptorStub?
    
    var request: URLRequest? {
        return interceptor?.urlRequest
    }

    override func setUp() {
        self.vc = UIViewController()
        let interceptor = InterceptorStub()
        sut = APIClient(delegateOwner: vc, interceptor: interceptor)
        self.interceptor = interceptor
    }

    override func tearDown() {
        self.sut = nil
        self.vc = nil
        self.interceptor = nil
    }
    
    func testGetVaccineCard() {
        // given
        let token = "1t_3G"
        let phn = "123321"
        let dateOfBirth = "1977-02-21"
        let dateOfVaccine = "2021-11-12"
        let card = GatewayVaccineCardRequest(phn: phn, dateOfBirth: dateOfBirth, dateOfVaccine: dateOfVaccine)
        // when
        let exp = expectation(description: "getVaccineCard expectation")
        interceptor?.expectation = exp
        sut.getVaccineCard(card, token: token, executingVC: vc, includeQueueItUI: true) { _,_  in }
        waitForExpectations(timeout: 1)
        // then
        let headers = request?.headers
        let pathComponents = request?.url?.pathComponents
        let query = request?.url?.query
        XCTAssertEqual(request?.method?.rawValue, "GET")
        XCTAssertEqual(headers?["phn"], phn)
        XCTAssertEqual(headers?["dateOfBirth"], dateOfBirth)
        XCTAssertEqual(headers?["dateOfVaccine"], dateOfVaccine)
        XCTAssertEqual(headers?["x-queueit-ajaxpageurl"], request?.url?.absoluteString)
        XCTAssertEqual(pathComponents![2],"immunizationservice")
        XCTAssertEqual(pathComponents![5],"PublicVaccineStatus")
        XCTAssertEqual(query, "queueittoken=\(token)")
    }
    
    func testGetTestResult() {
        // given
        let token = "2t_4D"
        let phn = "123321"
        let dateOfBirth = "1981-02-22"
        let collectionDate = "2022-01-12"
        let testResult = GatewayTestResultRequest.init(phn: phn, dateOfBirth: dateOfBirth, collectionDate: collectionDate)
        // when
        let exp = expectation(description: "getTestResult expectation")
        interceptor?.expectation = exp
        sut.getTestResult(testResult, token: token, executingVC: vc, includeQueueItUI: true) { _,_ in }
        waitForExpectations(timeout: 1)
        // then
        let headers = request?.headers
        let pathComponents = request?.url?.pathComponents
        let query = request?.url?.query
        XCTAssertEqual(headers?["phn"], phn)
        XCTAssertEqual(headers?["dateOfBirth"], dateOfBirth)
        XCTAssertEqual(headers?["collectionDate"], collectionDate)
        XCTAssertEqual(pathComponents![2],"laboratoryservice")
        XCTAssertEqual(pathComponents![5],"PublicLaboratory")
        XCTAssertEqual(request?.method?.rawValue, "GET")
        XCTAssertEqual(query, "queueittoken=\(token)")
        XCTAssertEqual(headers?["x-queueit-ajaxpageurl"], request?.url?.absoluteString)
    }
    
    func testGetAuthenticatedVaccineCard() {
        // given
        let token = "eyJhbGciOiJSUzI1N..."
        let hdid = "RD33Y2LJEUZCY2TCMO..."
        let authenticationRequest = AuthenticationRequestObject(authToken: token, hdid: hdid)
        // when
        let exp = expectation(description: "getAuthenticatedVaccineCard expectation")
        interceptor?.expectation = exp
        sut.getAuthenticatedVaccineCard(authenticationRequest, token: nil, executingVC: vc, includeQueueItUI: false) { _,_ in }
        waitForExpectations(timeout: 1)
        // then
        let headers = request?.headers
        let pathComponents = request?.url?.pathComponents
        let query = request?.url?.query
        XCTAssertEqual(request?.method?.rawValue, "GET")
        XCTAssertEqual(headers?["x-queueit-ajaxpageurl"], request?.url?.absoluteString)
        XCTAssertEqual(headers?["Authorization"], "Bearer \(token)")
        XCTAssertEqual(pathComponents![2],"immunizationservice")
        XCTAssertEqual(pathComponents![5],"AuthenticatedVaccineStatus")
        XCTAssertEqual(query, "hdid=\(hdid)")
    }
    
    func testGetAuthenticatedTestResults() {
        // given
        let token = "eyJhbGciOia2lkI"
        let hdid =  "L6Q553IHHBI3AWQ"
        let authenticationRequest = AuthenticationRequestObject(authToken: token, hdid: hdid)
        // when
        let exp = expectation(description: "getAuthenticatedTestResults expectation")
        interceptor?.expectation = exp
        sut.getAuthenticatedTestResults(authenticationRequest, token: nil, executingVC: vc, includeQueueItUI: false) { _,_ in }
        waitForExpectations(timeout: 1)
        // then
        let headers = request?.headers
        let query = request?.url?.query
        XCTAssertEqual(headers?["Authorization"], "Bearer \(token)")
        XCTAssertEqual(request?.url?.path, "/api/laboratoryservice/v1/api/Laboratory/Covid19Orders")
        XCTAssertEqual(query, "hdid=\(hdid)")
        XCTAssertEqual(request?.method?.rawValue, "GET")
        XCTAssertEqual(headers?["x-queueit-ajaxpageurl"], request?.url?.absoluteString)
    }
    
    func testGetAuthenticatedPatientDetails() {
        // given
        let token = "AiSldUIiwia2lkIiA6IC"
        let hdid  = "MEQ62CSUL6Q553IHHBI3"
        let authenticationRequest = AuthenticationRequestObject(authToken: token, hdid: hdid)
        // when
        let exp = expectation(description: "getAuthenticatedPatientDetails expectation")
        interceptor?.expectation = exp
        sut.getAuthenticatedPatientDetails(authenticationRequest, token: nil, executingVC: vc, includeQueueItUI: false) { _,_ in }
        waitForExpectations(timeout: 1)
        // then
        let headers = request?.headers
        let path = request?.url?.path
        XCTAssertEqual(headers?["x-queueit-ajaxpageurl"], request?.url?.absoluteString)
        XCTAssertEqual(headers?["Authorization"], "Bearer \(token)")
        XCTAssertEqual(path, "/api/patientservice/v1/api/Patient/\(hdid)")
        XCTAssertNil(request?.url?.query)
        XCTAssertEqual(request?.method?.rawValue, "GET")
    }
    
    func testGetAuthenticatedMedicationStatement() {
        // given
        let token = "iOiJSUzI1NiIsInR5cCIgOiAi"
        let hdid  = "JECY2TCMOIECUTKS3E62MEQ62"
        let authenticationRequest = AuthenticationRequestObject(authToken: token, hdid: hdid)
        // when
        let exp = expectation(description: "getAuthenticatedMedicationStatement expectation")
        interceptor?.expectation = exp
        sut.getAuthenticatedMedicationStatement(authenticationRequest, token: nil, executingVC: vc, includeQueueItUI: false) { _,_ in }
        waitForExpectations(timeout: 1)
        // then
        let headers = request?.headers
        let path = request?.url?.path
        XCTAssertEqual(headers?["Authorization"], "Bearer \(token)")
        XCTAssertEqual(headers?["x-queueit-ajaxpageurl"], request?.url?.absoluteString)
        XCTAssertEqual(path, "/api/medicationservice/v1/api/MedicationStatement/\(hdid)")
        XCTAssertEqual(request?.method?.rawValue, "GET")
        XCTAssertNil(request?.url?.query)
    }
}

class InterceptorStub: NetworkRequestInterceptor {
    var urlRequest: URLRequest?
    var expectation: XCTestExpectation?
    
    override func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        super.adapt(urlRequest, for: session, completion: { result in
            if case let .success(urlRequest) = result {
                self.urlRequest = urlRequest
                self.expectation?.fulfill()
            }
        })
    }
}
