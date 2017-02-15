//
//  CONNECTION_Tests.swift
//  UsergridSDK
//
//  Created by Robert Walsh on 10/5/15.
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

class CONNECTION_Tests: XCTestCase {

    static let collectionName = "connectionTestEntity"
    let clientAuth = UsergridAppAuth(clientId: "YXA68al98dLWEeahpA7sJBXz3w", clientSecret: "YXA6-CUpuVaNE3X_f6qDZuXskk_CdQw")

    let connectionEntities = [UsergridEntity(type:collectionName),
                              UsergridEntity(type:collectionName),
                              UsergridEntity(type:collectionName),
                              UsergridEntity(type:collectionName),
                              UsergridEntity(type:collectionName)]

    func test_CLIENT_AUTH() {

        let authExpect = self.expectation(description: "\(#function)")
        Usergrid.authMode = .app
        Usergrid.authenticateApp(clientAuth) { auth,error in
            XCTAssertTrue(Thread.isMainThread)
            XCTAssertNil(error)
            XCTAssertNotNil(Usergrid.appAuth)

            if let appAuth = Usergrid.appAuth {

                XCTAssertNotNil(appAuth.accessToken)
                XCTAssertNotNil(appAuth.expiry)
                Usergrid.POST(self.connectionEntities) { (response) in

                    XCTAssertTrue(Thread.isMainThread)
                    XCTAssertNotNil(response)
                    XCTAssertTrue(response.ok)
                    XCTAssertEqual(response.entities!.count, self.connectionEntities.count)

                    let entity = response.first!
                    let entityToConnect = response.entities![1]
                    XCTAssertEqual(entity.type, CONNECTION_Tests.collectionName.lowercased())

                    entity.connect("likes", toEntity: entityToConnect) { (response) -> Void in
                        XCTAssertTrue(Thread.isMainThread)
                        XCTAssertNotNil(response)
                        XCTAssertTrue(response.ok)

                        entity.getConnections(.out, relationship: "likes", query:nil) { (response) -> Void in
                            XCTAssertTrue(Thread.isMainThread)
                            XCTAssertNotNil(response)
                            XCTAssertTrue(response.ok)

                            let connectedEntity = response.first!
                            XCTAssertNotNil(connectedEntity)
                            XCTAssertEqual(connectedEntity.uuidOrName, entityToConnect.uuidOrName)

                            entity.disconnect("likes", fromEntity: connectedEntity) { (response) -> Void in
                                XCTAssertTrue(Thread.isMainThread)
                                XCTAssertNotNil(response)
                                XCTAssertTrue(response.ok)

                                entity.getConnections(.out, relationship: "likes", query:nil) { (response) -> Void in
                                    XCTAssertTrue(Thread.isMainThread)
                                    XCTAssertNotNil(response)
                                    XCTAssertTrue(response.ok)

                                    Usergrid.DELETE(UsergridQuery().type(CONNECTION_Tests.collectionName)) { response in
                                        XCTAssertTrue(response.ok)
                                        XCTAssertEqual(response.entities?.count, self.connectionEntities.count)
                                        authExpect.fulfill()
                                    }
                                }
                            }
                        }
                    }
                }
            } else {
                authExpect.fulfill()
            }
        }
        self.waitForExpectations(timeout: 20, handler: nil)
    }
}
