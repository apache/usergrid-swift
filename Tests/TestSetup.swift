//
//  TestSetup.swift
//  UsergridSDK
//
//  Created by Robert on 2/14/17.
//  Copyright © 2017 Apigee Inc. All rights reserved.
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

import Foundation
@testable import UsergridSDK

class TestSetup: NSObject {
    override init () {
        let config = UsergridClientConfig(orgId: "rjwalsh", appId: "sandbox")
        config.persistCurrentUserInKeychain = false
        
        Usergrid.initSharedInstance(configuration: config)
    }
}
