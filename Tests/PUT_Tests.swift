//
//  PUT_Tests.swift
//  UsergridSDK
//
//  Created by Robert Walsh on 9/11/15.
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

class PUT_Tests: XCTestCase {

    static let putCollectionName = "putTestEntities"

    var entityToPutOn: UsergridEntity!

    override func setUp() {
        super.setUp()

        let exp = expectation(description: "\(#function)\(#line)")
        Usergrid.POST(UsergridEntity(type: PUT_Tests.putCollectionName)) { (response) in
            self.entityToPutOn = response.entity!
            exp.fulfill()
        }

        waitForExpectations(timeout: 20, handler: nil)
    }

    override func tearDown() {
        super.tearDown()
        entityToPutOn.remove()
    }

    func test_PUT_BY_SPECIFYING_UUID_AS_PARAMETER() {

        let propertyNameToUpdate = "\(#function)"
        let propertiesNewValue = "\(propertyNameToUpdate)_VALUE"
        let putExpect = self.expectation(description: propertyNameToUpdate)

        Usergrid.PUT(PUT_Tests.putCollectionName, uuidOrName: self.entityToPutOn.uuid!, jsonBody:[propertyNameToUpdate : propertiesNewValue]) { (response) in
            XCTAssertTrue(Thread.isMainThread)
            XCTAssertNotNil(response)
            XCTAssertTrue(response.ok)
            XCTAssertEqual(response.entities!.count, 1)
            let entity = response.first!

            XCTAssertNotNil(entity)
            XCTAssertEqual(entity.uuid!, self.entityToPutOn.uuid!)

            let updatedPropertyValue = entity[propertyNameToUpdate] as? String
            XCTAssertNotNil(updatedPropertyValue)
            XCTAssertEqual(updatedPropertyValue!,propertiesNewValue)

            putExpect.fulfill()
        }

        self.waitForExpectations(timeout: 10, handler: nil)
    }

    func test_PUT_BY_SPECIFYING_UUID_WITHIN_JSON_BODY() {

        let propertyNameToUpdate = "\(#function)"
        let propertiesNewValue = "\(propertyNameToUpdate)_VALUE"
        let putExpect = self.expectation(description: propertyNameToUpdate)

        let jsonDictToPut = [UsergridEntityProperties.uuid.stringValue : self.entityToPutOn.uuid!, propertyNameToUpdate : propertiesNewValue]
        Usergrid.PUT(PUT_Tests.putCollectionName, jsonBody: jsonDictToPut) { (response) in
            XCTAssertTrue(Thread.isMainThread)
            XCTAssertNotNil(response)
            XCTAssertTrue(response.ok)
            XCTAssertEqual(response.entities!.count, 1)
            let entity = response.first!

            XCTAssertNotNil(entity)
            XCTAssertEqual(entity.uuid!, self.entityToPutOn.uuid!)

            let updatedPropertyValue = entity[propertyNameToUpdate] as? String
            XCTAssertNotNil(updatedPropertyValue)
            XCTAssertEqual(updatedPropertyValue!,propertiesNewValue)
            putExpect.fulfill()
        }

        self.waitForExpectations(timeout: 10, handler: nil)
    }

    func test_PUT_WITH_ENTITY_OBJECT() {

        let propertyNameToUpdate = "\(#function)"
        let propertiesNewValue = "\(propertyNameToUpdate)_VALUE"
        let putExpect = self.expectation(description: propertyNameToUpdate)

        self.entityToPutOn[propertyNameToUpdate] = propertiesNewValue

        Usergrid.PUT(self.entityToPutOn) { (putResponse) in
            XCTAssertTrue(Thread.isMainThread)
            XCTAssertNotNil(putResponse)
            XCTAssertTrue(putResponse.ok)
            XCTAssertEqual(putResponse.entities!.count, 1)

            let responseEntity = putResponse.first!

            XCTAssertNotNil(responseEntity)
            XCTAssertEqual(responseEntity.uuid!, self.entityToPutOn.uuid!)

            let updatedPropertyValue = responseEntity[propertyNameToUpdate] as? String
            XCTAssertNotNil(updatedPropertyValue)
            XCTAssertEqual(updatedPropertyValue!,propertiesNewValue)
            putExpect.fulfill()
        }

        self.waitForExpectations(timeout: 20, handler: nil)
    }

    func test_PUT_WITH_QUERY() {
        sleep(20)

        let propertyNameToUpdate = "\(#function)"
        let propertiesNewValue = "\(propertyNameToUpdate)_VALUE"
        let putExpect = self.expectation(description: propertyNameToUpdate)

        let query = UsergridQuery(PUT_Tests.putCollectionName).eq("uuid", value: self.entityToPutOn.uuid!)

        Usergrid.PUT(query, jsonBody: [propertyNameToUpdate : propertiesNewValue]) { (putResponse) in
            XCTAssertTrue(Thread.isMainThread)
            XCTAssertNotNil(putResponse)
            XCTAssertTrue(putResponse.ok)
            XCTAssertEqual(putResponse.entities!.count, 1)

            let responseEntity = putResponse.first!
            XCTAssertNotNil(responseEntity)

            let updatedPropertyValue = responseEntity[propertyNameToUpdate] as? String
            XCTAssertNotNil(updatedPropertyValue)
            XCTAssertEqual(updatedPropertyValue!,propertiesNewValue)
            putExpect.fulfill()
        }

        self.waitForExpectations(timeout: 10, handler: nil)
    }
}
