//
//  HemlockTests.swift
//  HemlockTests
//
//  Created by Sylvan Martin on 7/25/24.
//

import XCTest
@testable import Hemlock

final class HemlockTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testHeaders() {
        HLCore.Web.testHeaderConstants()
    }
    
    func testUserDownload() {
        HLCore.Web.testDownloadUser()
    }

    func testUserCreation() {
        HLCore.Web.createUser(email: "test@email.org") { result, userID, masterKey in
            print("Result: \(result)")
            print("User ID: \(userID)")
            print("Master key: \(masterKey.hexString)")
        }
        
        // Just so we have time to view the result
        do {
            sleep(3)
        }
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
