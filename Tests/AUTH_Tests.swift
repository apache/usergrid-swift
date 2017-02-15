//
//  AUTH_Tests.swift
//  UsergridSDK
//
//  Created by Robert Walsh on 9/17/15.
//
/*
 *
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  The ASF licenses this file to You
 * under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.  For additional information regarding
 * copyright in this work, please see the NOTICE file in the top level
 * directory of this distribution.
 *
 */

import XCTest
@testable import UsergridSDK

class AUTH_Tests: XCTestCase {

    func test_CLIENT_AUTH() {

        let authExpect = self.expectation(description: "\(#function)")

        Usergrid.authMode = .app
        let appAuth = UsergridAppAuth(clientId: "YXA6-zvnTdLWEeaGGwrYgfQDvw", clientSecret: "YXA64tQ5qQAW_IZYUAOn_tDRKz0HrAU")

        Usergrid.authenticateApp(appAuth) { auth,error in
            XCTAssertTrue(Thread.isMainThread)
            XCTAssertNil(error)
            XCTAssertNotNil(Usergrid.appAuth)

            if let appAuth = Usergrid.appAuth {
                XCTAssertNotNil(appAuth.accessToken)
                XCTAssertNotNil(appAuth.expiry)
                XCTAssertNotNil(appAuth.isValid)
            }
            authExpect.fulfill()
        }
        self.waitForExpectations(timeout: 1000, handler: nil)
    }

    func test_DESTROY_AUTH() {

        let auth = UsergridAuth(accessToken: "YWMt91Q2YtWaEeW_Ki2uDueMEwAAAVMUTVSPeOdX-oradxdqirEFz5cPU3GWybs")

        XCTAssertTrue(auth.isValid)
        XCTAssertNotNil(auth.accessToken)
        XCTAssertNil(auth.expiry)

        auth.destroy()

        XCTAssertFalse(auth.isValid)
        XCTAssertNil(auth.accessToken)
        XCTAssertNil(auth.expiry)
    }

    func test_APP_AUTH_NSCODING() {

        let appAuth = UsergridAppAuth(clientId: "YXA6-zvnTdLWEeaGGwrYgfQDvw", clientSecret: "YXA64tQ5qQAW_IZYUAOn_tDRKz0HrAU")
        appAuth.accessToken = "YWMt91Q2YtWaEeW_Ki2uDueMEwAAAVMUTVSPeOdX-oradxdqirEFz5cPU3GWybs"
        appAuth.expiry = Date.distantFuture

        let authCodingData = NSKeyedArchiver.archivedData(withRootObject: appAuth)
        let newInstanceFromData = NSKeyedUnarchiver.unarchiveObject(with: authCodingData) as? UsergridAppAuth

        XCTAssertNotNil(newInstanceFromData)

        if let newInstance = newInstanceFromData {
            XCTAssertTrue(appAuth.isValid)
            XCTAssertTrue(newInstance.isValid)
            XCTAssertEqual(appAuth.clientId,newInstance.clientId)
            XCTAssertEqual(appAuth.accessToken,newInstance.accessToken)
            XCTAssertEqual(appAuth.expiry,newInstance.expiry)
        }
    }

    func test_USER_AUTH_NSCODING() {

        let userAuth: UsergridUserAuth = UsergridUserAuth(username: "username", password: "password")
        userAuth.accessToken = "YWMt91Q2YtWaEeW_Ki2uDueMEwAAAVMUTVSPeOdX-oradxdqirEFz5cPU3GWybs"
        userAuth.expiry = Date.distantFuture

        let authCodingData = NSKeyedArchiver.archivedData(withRootObject: userAuth)
        let newInstanceFromData = NSKeyedUnarchiver.unarchiveObject(with: authCodingData) as? UsergridUserAuth

        XCTAssertNotNil(newInstanceFromData)

        if let newInstance = newInstanceFromData {
            XCTAssertTrue(userAuth.isValid)
            XCTAssertTrue(newInstance.isValid)
            XCTAssertEqual(userAuth.username,newInstance.username)
            XCTAssertEqual(userAuth.accessToken,newInstance.accessToken)
            XCTAssertEqual(userAuth.expiry,newInstance.expiry)
        }
    }
}
