//
//  UsergridEnums.swift
//  UsergridSDK
//
//  Created by Robert Walsh on 10/21/15.
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

/**
An enumeration that is used to determine what the `UsergridClient` will use for authorization.
*/
@objc public enum UsergridAuthMode : Int {

    static let defaultMode: UsergridAuthMode = .user

    // MARK: - Values -

    /**
    If the API call fails, the activity is treated as a failure with an appropriate HTTP status code.
    */
    case none

    /**
     If a non-expired `UsergridUserAuth` exists in `UsergridClient.currentUser`, this token is used to authenticate all API calls.

     If the API call fails, the activity is treated as a failure with an appropriate HTTP status code (This behavior is identical to authMode=.None).
     */
    case user

    /**
    If a non-expired `UsergridAppAuth` exists in `UsergridClient.appAuth`, this token is used to authenticate all API calls.

    If the API call fails, the activity is treated as a failure with an appropriate HTTP status code (This behavior is identical to authMode=.None).
    */
    case app
}

/**
`UsergridEntity` specific properties keys.  Note that trying to mutate the values of these properties will not be allowed in most cases.
*/
@objc public enum UsergridEntityProperties : Int {

    // MARK: - Values -

    /// Corresponds to the property 'type'
    case type
    /// Corresponds to the property 'uuid'
    case uuid
    /// Corresponds to the property 'name'
    case name
    /// Corresponds to the property 'created'
    case created
    /// Corresponds to the property 'modified'
    case modified
    /// Corresponds to the property 'location'
    case location

    // MARK: - Methods -

    /**
    Gets the corresponding `UsergridEntityProperties` from a string if it's valid.

    - parameter stringValue: The string value to convert.

    - returns: The corresponding `UsergridEntityProperties` or nil.
    */
    public static func fromString(_ stringValue: String) -> UsergridEntityProperties? {
        switch stringValue.lowercased() {
            case ENTITY_TYPE: return .type
            case ENTITY_UUID: return .uuid
            case ENTITY_NAME: return .name
            case ENTITY_CREATED: return .created
            case ENTITY_MODIFIED: return .modified
            case ENTITY_LOCATION: return .location
            default: return nil
        }
    }

    /// Returns the string value.
    public var stringValue: String {
        switch self {
            case .type: return ENTITY_TYPE
            case .uuid: return ENTITY_UUID
            case .name: return ENTITY_NAME
            case .created: return ENTITY_CREATED
            case .modified: return ENTITY_MODIFIED
            case .location: return ENTITY_LOCATION
        }
    }

    /**
    Determines if the `UsergridEntityProperties` is mutable for the given entity.

    - parameter entity: The entity to check.

    - returns: If the `UsergridEntityProperties` is mutable for the given entity
    */
    public func isMutableForEntity(_ entity:UsergridEntity) -> Bool {
        switch self {
            case .type,.uuid,.created,.modified: return false
            case .location: return true
            case .name: return entity.isUser
        }
    }
}

/**
`UsergridDeviceProperties` specific properties keys.  Note that trying to mutate the values of these properties will not be allowed in most cases.
*/
@objc public enum UsergridDeviceProperties : Int {

    // MARK: - Values -

    /// Corresponds to the property 'deviceModel'
    case model
    /// Corresponds to the property 'devicePlatform'
    case platform
    /// Corresponds to the property 'deviceOSVersion'
    case osVersion

    // MARK: - Methods -

    /**
    Gets the corresponding `UsergridDeviceProperties` from a string if it's valid.

    - parameter stringValue: The string value to convert.

    - returns: The corresponding `UsergridDeviceProperties` or nil.
    */
    public static func fromString(_ stringValue: String) -> UsergridDeviceProperties? {
        switch stringValue.lowercased() {
            case DEVICE_MODEL: return .model
            case DEVICE_PLATFORM: return .platform
            case DEVICE_OSVERSION: return .osVersion
            default: return nil
        }
    }

    /// Returns the string value.
    public var stringValue: String {
        switch self {
            case .model: return DEVICE_MODEL
            case .platform: return DEVICE_PLATFORM
            case .osVersion: return DEVICE_OSVERSION
        }
    }
}

/**
`UsergridUser` specific properties keys.
*/
@objc public enum UsergridUserProperties: Int {

    // MARK: - Values -

    /// Corresponds to the property 'name'
    case name
    /// Corresponds to the property 'username'
    case username
    /// Corresponds to the property 'password'
    case password
    /// Corresponds to the property 'email'
    case email
    /// Corresponds to the property 'age'
    case age
    /// Corresponds to the property 'activated'
    case activated
    /// Corresponds to the property 'disabled'
    case disabled
    /// Corresponds to the property 'picture'
    case picture

    // MARK: - Methods -

    /**
    Gets the corresponding `UsergridUserProperties` from a string if it's valid.

    - parameter stringValue: The string value to convert.

    - returns: The corresponding `UsergridUserProperties` or nil.
    */
    public static func fromString(_ stringValue: String) -> UsergridUserProperties? {
        switch stringValue.lowercased() {
            case ENTITY_NAME: return .name
            case USER_USERNAME: return .username
            case USER_PASSWORD: return .password
            case USER_EMAIL: return .email
            case USER_AGE: return .age
            case USER_ACTIVATED: return .activated
            case USER_DISABLED: return .disabled
            case USER_PICTURE: return .picture
            default: return nil
        }
    }

    /// Returns the string value.
    public var stringValue: String {
        switch self {
            case .name: return ENTITY_NAME
            case .username: return USER_USERNAME
            case .password: return USER_PASSWORD
            case .email: return USER_EMAIL
            case .age: return USER_AGE
            case .activated: return USER_ACTIVATED
            case .disabled: return USER_DISABLED
            case .picture: return USER_PICTURE
        }
    }
}

/**
`UsergridQuery` specific operators.
*/
@objc public enum UsergridQueryOperator: Int {

    // MARK: - Values -

    /// '='
    case equal
    /// '>'
    case greaterThan
    /// '>='
    case greaterThanEqualTo
    /// '<'
    case lessThan
    /// '<='
    case lessThanEqualTo

    // MARK: - Methods -

    /**
    Gets the corresponding `UsergridQueryOperator` from a string if it's valid.

    - parameter stringValue: The string value to convert.

    - returns: The corresponding `UsergridQueryOperator` or nil.
    */
    public static func fromString(_ stringValue: String) -> UsergridQueryOperator? {
        switch stringValue.lowercased() {
            case UsergridQuery.EQUAL: return .equal
            case UsergridQuery.GREATER_THAN: return .greaterThan
            case UsergridQuery.GREATER_THAN_EQUAL_TO: return .greaterThanEqualTo
            case UsergridQuery.LESS_THAN: return .lessThan
            case UsergridQuery.LESS_THAN_EQUAL_TO: return .lessThanEqualTo
            default: return nil
        }
    }

    /// Returns the string value.
    public var stringValue: String {
        switch self {
            case .equal: return UsergridQuery.EQUAL
            case .greaterThan: return UsergridQuery.GREATER_THAN
            case .greaterThanEqualTo: return UsergridQuery.GREATER_THAN_EQUAL_TO
            case .lessThan: return UsergridQuery.LESS_THAN
            case .lessThanEqualTo: return UsergridQuery.LESS_THAN_EQUAL_TO
        }
    }
}

/**
`UsergridQuery` specific sort orders.
*/
@objc public enum UsergridQuerySortOrder: Int {

    // MARK: - Values -

    /// Sort order is ascending.
    case asc
    /// Sort order is descending.
    case desc

    // MARK: - Methods -

    /**
    Gets the corresponding `UsergridQuerySortOrder` from a string if it's valid.

    - parameter stringValue: The string value to convert.

    - returns: The corresponding `UsergridQuerySortOrder` or nil.
    */
    public static func fromString(_ stringValue: String) -> UsergridQuerySortOrder? {
        switch stringValue.lowercased() {
            case UsergridQuery.ASC: return .asc
            case UsergridQuery.DESC: return .desc
            default: return nil
        }
    }

    /// Returns the string value.
    public var stringValue: String {
        switch self {
            case .asc: return UsergridQuery.ASC
            case .desc: return UsergridQuery.DESC
        }
    }
}

/**
`UsergridAsset` image specific content types.
*/
@objc public enum UsergridImageContentType : Int {

    // MARK: - Values -

    /// Content type: 'image/png'
    case png
    /// Content type: 'image/jpeg'
    case jpeg

    // MARK: - Methods -

    /// Returns the string value.
    public var stringValue: String {
        switch self {
            case .png: return ASSET_IMAGE_PNG
            case .jpeg: return ASSET_IMAGE_JPEG
        }
    }
}

/**
 An enumeration that is used when getting connections to entity objects. Used to determine which the direction of the connection is wanted.
 */
@objc public enum UsergridDirection : Int {

    // MARK: - Values -

    /// To get the entities that have created a connection to an entity. aka `connecting`
    case `in`

    /// To get the entities an entity has connected to. aka `connections`
    case out

    // MARK: - Methods -

    /// Returns the connection value.
    public var connectionValue: String {
        switch self {
            case .in: return CONNECTION_TYPE_IN
            case .out: return CONNECTION_TYPE_OUT
        }
    }
}

/**
 An enumeration for defining the HTTP methods used by Usergrid.
 */
@objc public enum UsergridHttpMethod : Int {

    /// GET
    case get

    /// PUT
    case put

    /// POST
    case post

    /// DELETE
    case delete

    /// Returns the string value.
    public var stringValue: String {
        switch self {
            case .get: return "GET"
            case .put: return "PUT"
            case .post: return "POST"
            case .delete: return "DELETE"
        }
    }
}

let ENTITY_TYPE = "type"
let ENTITY_UUID = "uuid"
let ENTITY_NAME = "name"
let ENTITY_CREATED = "created"
let ENTITY_MODIFIED = "modified"
let ENTITY_LOCATION = "location"
let ENTITY_LATITUDE = "latitude"
let ENTITY_LONGITUDE = "longitude"

let USER_USERNAME = "username"
let USER_PASSWORD = "password"
let USER_EMAIL = "email"
let USER_AGE = "age"
let USER_ACTIVATED = "activated"
let USER_DISABLED = "disabled"
let USER_PICTURE = "picture"

let DEVICE_MODEL = "deviceModel"
let DEVICE_PLATFORM = "devicePlatform"
let DEVICE_OSVERSION = "deviceOSVersion"

let ASSET_IMAGE_PNG = "image/png"
let ASSET_IMAGE_JPEG = "image/jpeg"

let CONNECTION_TYPE_IN = "connecting"
let CONNECTION_TYPE_OUT = "connections"
