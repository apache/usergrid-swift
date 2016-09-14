//
//  UsergridAuth.swift
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

import Foundation

/// The completion block used in `UsergridAppAuth` authentication methods.
public typealias UsergridAppAuthCompletionBlock = (_ auth:UsergridAppAuth?, _ error: UsergridResponseError?) -> Void

/// The completion block used in `UsergridUserAuth` authentication methods.
public typealias UsergridUserAuthCompletionBlock = (_ auth:UsergridUserAuth?, _ user:UsergridUser?, _ error: UsergridResponseError?) -> Void

/** 
 The `UsergridAuth` class functions to create and store authentication information used by Usergrid.
 
 The `UsergridAuth` sub classes, `UsergridAppAuth` and `UsergridUserAuth`, provide different ways for authentication to be used in creating requests for access tokens through the SDK.
*/
public class UsergridAuth : NSObject, NSCoding {

    // MARK: - Instance Properties -

    /// The access token, if this `UsergridAuth` was authorized successfully.
    public var accessToken : String?

    /// The expires at date, if this `UsergridAuth` was authorized successfully and their was a expires in time stamp within the token response.
    public var expiry : Date?

    /// Determines if an access token exists.
    public var hasToken: Bool { return self.accessToken != nil }

    /// Determines if the token was set explicitly within the init method or not.
    private var usingToken: Bool = false

    /// Determines if an access token exists and if the token is not expired.
    public var isValid : Bool { return self.hasToken && !self.isExpired }

    /// Determines if the access token, if one exists, is expired.
    public var isExpired: Bool {
        var isExpired = false
        if let expires = self.expiry {
            isExpired = expires.timeIntervalSinceNow < 0.0
        } else {
            isExpired = !self.usingToken
        }
        return isExpired
    }

    /// The credentials dictionary. Subclasses must override this method and provide an actual dictionary containing the credentials to send with requests.
    var credentialsJSONDict: [String:Any] {
        return [:]
    }

    // MARK: - Initialization -

    /**
    Internal initialization method.  Note this should never be used outside of internal methods.

    - returns: A new instance of `UsergridAuth`.
    */
    override fileprivate init() {
        super.init()
    }

    /**
     Initializer for a base `UsergridAuth` object that just contains an `accessToken` and an optional `expiry` date.

     - parameter accessToken: The access token.
     - parameter expiry:      The optional expiry date.

     - returns: A new instance of `UsergridAuth`
     */
    public init(accessToken:String, expiry:Date? = nil) {
        self.usingToken = true
        self.accessToken = accessToken
        self.expiry = expiry
    }

    // MARK: - NSCoding -

    /**
    NSCoding protocol initializer.

    - parameter aDecoder: The decoder.

    - returns: A decoded `UsergridAuth` object.
    */
    required public init?(coder aDecoder: NSCoder) {
        self.accessToken = aDecoder.decodeObject(forKey: "accessToken") as? String
        self.expiry = aDecoder.decodeObject(forKey: "expiry") as? Date
    }

    /**
     NSCoding protocol encoder.

     - parameter aCoder: The encoder.
     */
    public func encode(with aCoder: NSCoder) {
        if let accessToken = self.accessToken {
            aCoder.encode(accessToken, forKey: "accessToken")
        }
        if let expiresAt = self.expiry {
            aCoder.encode(expiresAt, forKey: "expiry")
        }
    }

    // MARK: - Instance Methods -

    /**
     Destroys/removes the access token and expiry.
     */
    public func destroy() {
        self.accessToken = nil
        self.expiry = nil
    }
}

/// The `UsergridAuth` subclass used for user level authorization.
public class UsergridUserAuth : UsergridAuth {

    // MARK: - Instance Properties -

    /// The username associated with the User.
    public let username: String

    /// The password associated with the User.
    private let password: String

    /// The credentials dictionary constructed with the `UsergridUserAuth`'s `username` and `password`.
    override var credentialsJSONDict: [String:Any] {
        return ["grant_type":"password",
                "username":self.username,
                "password":self.password]
    }

    // MARK: - Initialization -

    /**
    Designated initializer for `UsergridUserAuth` objects.

    - parameter username: The username associated with the User.
    - parameter password: The password associated with the User.

    - returns: A new instance of `UsergridUserAuth`.
    */
    public init(username:String, password: String){
        self.username = username
        self.password = password
        super.init()
    }

    // MARK: - NSCoding -

    /**
    NSCoding protocol initializer.

    - parameter aDecoder: The decoder.

    - returns: A decoded `UsergridUserAuth` object.
    */
    required public init?(coder aDecoder: NSCoder) {
        guard let username = aDecoder.decodeObject(forKey: "username") as? String,
                  let password = aDecoder.decodeObject(forKey: "password") as? String
        else {
            self.username = ""
            self.password = ""
            super.init(coder: aDecoder)
            return nil
        }

        self.username = username
        self.password = password
        super.init(coder: aDecoder)
    }

    /**
     NSCoding protocol encoder.

     - parameter aCoder: The encoder.
     */
    override public func encode(with aCoder: NSCoder) {
        aCoder.encode(self.username, forKey: "username")
        aCoder.encode(self.password, forKey: "password")
        super.encode(with: aCoder)
    }
}

/// The `UsergridAuth` subclass used for application level authorization.
public class UsergridAppAuth : UsergridAuth {

    // MARK: - Instance Properties -

    /// The client identifier associated with the application.
    public let clientId: String

    /// The client secret associated with the application.
    private let clientSecret: String

    /// The credentials dictionary constructed with the `UsergridAppAuth`'s `clientId` and `clientSecret`.
    override var credentialsJSONDict: [String:Any] {
        return ["grant_type":"client_credentials",
                "client_id":self.clientId,
                "client_secret":self.clientSecret]
    }

    // MARK: - Initialization -

    /**
    Designated initializer for `UsergridAppAuth` objects.

    - parameter clientId:     The client identifier associated with the application.
    - parameter clientSecret: The client secret associated with the application.

    - returns: A new instance of `UsergridAppAuth`.
    */
    public init(clientId:String,clientSecret:String){
        self.clientId = clientId
        self.clientSecret = clientSecret
        super.init()
    }

    // MARK: - NSCoding -

    /**
    NSCoding protocol initializer.

    - parameter aDecoder: The decoder.

    - returns: A decoded `UsergridAppAuth` object.
    */
    required public init?(coder aDecoder: NSCoder) {
        guard let clientId = aDecoder.decodeObject(forKey: "clientId") as? String,
              let clientSecret = aDecoder.decodeObject(forKey: "clientSecret") as? String
        else {
            self.clientId = ""
            self.clientSecret = ""
            super.init(coder: aDecoder)
            return nil
        }
        self.clientId = clientId
        self.clientSecret = clientSecret
        super.init(coder: aDecoder)
    }

    /**
     NSCoding protocol encoder.

     - parameter aCoder: The encoder.
     */
    override public func encode(with aCoder: NSCoder) {
        aCoder.encode(self.clientId, forKey: "clientId")
        aCoder.encode(self.clientSecret, forKey: "clientSecret")
        super.encode(with: aCoder)
    }
}
