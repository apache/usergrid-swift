//
//  ClientCreationTests.swift
//  UsergridSDK
//
//  Created by Robert Walsh on 7/31/15.
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

class ClientCreationTests: XCTestCase {

    static let orgId = "rjwalsh"
    static let appId = "sdk.demo"
    let client = UsergridClient(orgId:ClientCreationTests.orgId, appId: ClientCreationTests.appId)

    func test_CLIENT_PROPERTIES() {
        XCTAssertEqual(client.appId, ClientCreationTests.appId)
        XCTAssertEqual(client.orgId, ClientCreationTests.orgId)
        XCTAssertEqual(client.authMode, UsergridAuthMode.user)
        XCTAssertEqual(client.persistCurrentUserInKeychain, true)
        XCTAssertEqual(client.baseUrl, UsergridClient.DEFAULT_BASE_URL)
        XCTAssertEqual(client.clientAppURL, "\(UsergridClient.DEFAULT_BASE_URL)/\(ClientCreationTests.orgId)/\(ClientCreationTests.appId)" )
        XCTAssertNil(client.currentUser)
        XCTAssertNil(client.userAuth)
    }

    func test_CLIENT_NSCODING() {
        let sharedInstanceAsData = NSKeyedArchiver.archivedData(withRootObject: client)
        let newInstanceFromData = NSKeyedUnarchiver.unarchiveObject(with: sharedInstanceAsData) as? UsergridClient

        XCTAssertNotNil(newInstanceFromData)

        if let newInstance = newInstanceFromData {
            XCTAssertEqual(client.appId, newInstance.appId)
            XCTAssertEqual(client.orgId, newInstance.orgId)
            XCTAssertEqual(client.authMode, newInstance.authMode)
            XCTAssertEqual(client.baseUrl, newInstance.baseUrl)
        }
    }
}
