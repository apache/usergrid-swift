//
//  GET_Tests.swift
//  UsergridSDK
//
//  Created by Robert Walsh on 9/2/15.
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

class GET_Tests: XCTestCase {

    static let collectionName = "getTestEntities"
    var postedEntities: [UsergridEntity] = []

    override func setUp() {
        super.setUp()

        let exp = self.expectation(description: "\(#function)")
        POST_TEST_ENTITIES(count:20 ,completion: { response in
            self.postedEntities = response.entities!
            exp.fulfill()
        })
        waitForExpectations(timeout: 10, handler: nil)
    }

    override func tearDown() {
        super.tearDown()
        let exp = self.expectation(description: "\(#function)")
        DELETE_TEST_ENTITIES() { response in
            exp.fulfill()
        }
        waitForExpectations(timeout: 10, handler: nil)
    }

    
    func POST_TEST_ENTITIES(count: Int, completion: @escaping UsergridResponseCompletion) {
        var entitiesToPost: [UsergridEntity] = []
        for _ in (0..<count) {
            let entity = UsergridEntity(type: GET_Tests.collectionName, propertyDict: ["gettest":true])
            entitiesToPost.append(entity)
        }
        Usergrid.POST(entitiesToPost,entitiesCompletion:{response in
            completion(response)
        })
    }

    func DELETE_TEST_ENTITIES(completion: @escaping UsergridResponseCompletion) {
        Usergrid.DELETE(UsergridQuery().type(GET_Tests.collectionName).limit(100),queryCompletion:completion)
    }

    func test_GET_WITHOUT_QUERY() {

        let getExpect = self.expectation(description: "\(#function)")

        Usergrid.GET(GET_Tests.collectionName) { (response) in
            XCTAssertTrue(Thread.isMainThread)
            XCTAssertNotNil(response)
            XCTAssertTrue(response.ok)
            XCTAssertTrue(response.hasNextPage)
            XCTAssertEqual(response.count, 10)
            getExpect.fulfill()
        }

        self.waitForExpectations(timeout: 10, handler: nil)
    }

    func test_GET_WITH_QUERY() {

        let getExpect = self.expectation(description: "\(#function)")

        Usergrid.GET(UsergridQuery(GET_Tests.collectionName)) { (response) in
            XCTAssertTrue(Thread.isMainThread)
            XCTAssertNotNil(response)
            XCTAssertTrue(response.ok)
            XCTAssertEqual(response.count, 10)
            getExpect.fulfill()
        }
        self.waitForExpectations(timeout: 10, handler: nil)
    }

    func test_GET_WITH_UUID() {

        let getExpect = self.expectation(description: "\(#function)")
        let postedEntityUUID = postedEntities.first!.uuid!

        Usergrid.GET(GET_Tests.collectionName, uuidOrName:postedEntityUUID) { (response) in
            XCTAssertTrue(Thread.isMainThread)
            XCTAssertNotNil(response)
            XCTAssertTrue(response.ok)
            let entity = response.first!
            XCTAssertFalse(response.hasNextPage)
            XCTAssertEqual(response.count, 1)
            XCTAssertNotNil(entity)
            XCTAssertEqual(entity.uuid!, postedEntityUUID)
            getExpect.fulfill()
        }
        self.waitForExpectations(timeout: 10, handler: nil)
    }

    func test_GET_NEXT_PAGE_WITH_NO_QUERY() {

        let getExpect = self.expectation(description: "\(#function)")

        Usergrid.GET(GET_Tests.collectionName) { (response) in
            XCTAssertTrue(Thread.isMainThread)
            XCTAssertNotNil(response)
            XCTAssertTrue(response.ok)
            XCTAssertTrue(response.hasNextPage)
            XCTAssertEqual(response.count, 10)

            response.loadNextPage() { (nextPageResponse) in
                XCTAssertTrue(Thread.isMainThread)
                XCTAssertTrue(nextPageResponse.ok)
                XCTAssertNotNil(nextPageResponse)
                XCTAssertFalse(!nextPageResponse.hasNextPage)
                XCTAssertEqual(nextPageResponse.entities!.count, 10)
                getExpect.fulfill()
            }
        }
        self.waitForExpectations(timeout: 20, handler: nil)
    }
    
}
