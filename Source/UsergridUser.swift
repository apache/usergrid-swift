//
//  User.swift
//  UsergridSDK
//
//  Created by Robert Walsh on 7/21/15.
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

/// The completion block used for checking email and/or username availablity for new `UsergridUser` objects.
public typealias UsergridUserAvailabilityCompletion = (_ error: UsergridResponseError?, _ available:Bool) -> Void

/// The completion block used for changing the password of `UsergridUser` objects.
public typealias UsergridUserResetPasswordCompletion = (_ error: UsergridResponseError?, _ didSucceed:Bool) -> Void

/**
`UsergridUser` is a special subclass of `UsergridEntity` that supports functions and properties unique to users.
*/
public class UsergridUser : UsergridEntity {

    static let USER_ENTITY_TYPE = "user"

    // MARK: - Instance Properties -

    /// The `UsergridUserAuth` object if this user was authenticated.
    public var auth: UsergridUserAuth?

    /** 
    Property helper method for the `UsergridUser` objects `UsergridUserProperties.Name`.
    
    Unlike `UsergridEntity` objects, `UsergridUser`'s can change their name property which is why we provide a getter here.
    */
    override public var name: String? {
        set(name) { self[UsergridUserProperties.name.stringValue] = name }
        get{ return super.name }
    }

    /// Property getter and setter helpers for the `UsergridUser` objects `UsergridUserProperties.Username`.
    public var username: String? {
        set(username) { self[UsergridUserProperties.username.stringValue] = username }
        get { return self.getUserSpecificProperty(.username) as? String }
    }

    /// Property getter and setter helpers for the `UsergridUser` objects `UsergridUserProperties.Password`.
    public var password: String? {
        set(password) { self[UsergridUserProperties.password.stringValue] = password }
        get { return self.getUserSpecificProperty(.password) as? String }
    }

    /// Property getter and setter helpers for the `UsergridUser` objects `UsergridUserProperties.Email`.
    public var email: String? {
        set(email) { self[UsergridUserProperties.email.stringValue] = email }
        get { return self.getUserSpecificProperty(.email) as? String }
    }

    /// Property getter and setter helpers for the `UsergridUser` objects `UsergridUserProperties.Age`.
    public var age: NSNumber? {
        set(age) { self[UsergridUserProperties.age.stringValue] = age }
        get { return self.getUserSpecificProperty(.age) as? NSNumber }
    }

    /// Property helper method to get the username or email of the `UsergridUser`.
    public var usernameOrEmail: String? { return self.username ?? self.email }

    /** 
    Property getter and setter helpers for the `UsergridUser` objects `UsergridUserProperties.Activated`.
    
    Indicates whether the user account has been activated or not.
    */
    public var activated: Bool {
        set(activated) { self[UsergridUserProperties.activated.stringValue] = activated }
        get { return self.getUserSpecificProperty(.activated) as? Bool ?? false }
    }

    /// Property getter and setter helpers for the `UsergridUser` objects `UsergridUserProperties.Disabled`.
    public var disabled: Bool {
        set(disabled) { self[UsergridUserProperties.disabled.stringValue] = disabled }
        get { return self.getUserSpecificProperty(.disabled) as? Bool ?? false }
    }

    /**
    Property getter and setter helpers for the `UsergridUser` objects `UsergridUserProperties.Picture`.
    
    URL path to user’s profile picture. Defaults to Gravatar for email address.
    */
    public var picture: String? {
        set(picture) { self[UsergridUserProperties.picture.stringValue] = picture }
        get { return self.getUserSpecificProperty(.picture) as? String }
    }

    /// The UUID or username property value if found.
    public var uuidOrUsername: String? { return self.uuid ?? self.username }

    // MARK: - Initialization -

    /**
    Designated initializer for `UsergridUser` objects.

    - parameter name: The name of the user.  Note this is different from the `username` property.

    - returns: A new instance of `UsergridUser`.
    */
    public init(name:String? = nil) {
        super.init(type: UsergridUser.USER_ENTITY_TYPE, name:name, propertyDict:nil)
    }

    /**
     The required public initializer for `UsergridEntity` subclasses.

     - parameter type:         The type associated with the `UsergridEntity` object.
     - parameter name:         The optional name associated with the `UsergridEntity` object.
     - parameter propertyDict: The optional property dictionary that the `UsergridEntity` object will start out with.

     - returns: A new `UsergridUser` object.
     */
    required public init(type: String, name: String?, propertyDict: [String : Any]?) {
        super.init(type: type, name: name, propertyDict: propertyDict)
    }

    /**
    Designated initializer for `UsergridUser` objects.

    - parameter name:         The name of the user.  Note this is different from the `username` property.
    - parameter propertyDict: The optional property dictionary that the `UsergridEntity` object will start out with.

    - returns: A new instance of `UsergridUser`.
    */
    public init(name:String,propertyDict:[String:Any]? = nil) {
        super.init(type: UsergridUser.USER_ENTITY_TYPE, name:name, propertyDict:propertyDict)
    }

    /**
     Convenience initializer for `UsergridUser` objects.

     - parameter name:     The name of the user.  Note this is different from the `username` property.
     - parameter email:    The user's email.
     - parameter password: The optional user's password.

     - returns: A new instance of `UsergridUser`.
     */
    public convenience init(name:String, email:String, password:String? = nil) {
        self.init(name:name,email:email,username:nil,password:password)
    }

    /**
     Convenience initializer for `UsergridUser` objects.

     - parameter email:    The user's email.
     - parameter password: The optional user's password.

     - returns: A new instance of `UsergridUser`.
     */
    public convenience init(email:String, password:String? = nil) {
        self.init(name:nil,email:email,username:nil,password:password)
    }

    /**
     Convenience initializer for `UsergridUser` objects.

     - parameter name:     The name of the user.  Note this is different from the `username` property.
     - parameter username: The username of the user.
     - parameter password: The optional user's password.

     - returns: A new instance of `UsergridUser`.
     */
    public convenience init(name:String, username:String, password:String? = nil) {
        self.init(name:name,email:nil,username:username,password:password)
    }

    /**
     Convenience initializer for `UsergridUser` objects.

     - parameter username: The username of the user.
     - parameter password: The optional user's password.

     - returns: A new instance of `UsergridUser`.
     */
    public convenience init(username:String, password:String? = nil) {
        self.init(name:nil,email:nil,username:username,password:password)
    }

    /**
     Convenience initializer for `UsergridUser` objects.

     - parameter name:     The optional name of the user.  Note this is different from the `username` property.
     - parameter email:    The optional user's email.
     - parameter username: The optional username of the user.
     - parameter password: The optional user's password.

     - returns: A new instance of `UsergridUser`.
     */
    public convenience init(name:String?, email:String?, username:String?, password:String? = nil) {
        self.init(name:name)
        self.email = email
        self.username = username
        self.password = password
    }

    // MARK: - NSCoding -

    /**
    NSCoding protocol initializer.

    - parameter aDecoder: The decoder.

    - returns: A decoded `UsergridUser` object.
    */
    required public init?(coder aDecoder: NSCoder) {
        self.auth = aDecoder.decodeObject(forKey: "auth") as? UsergridUserAuth
        super.init(coder: aDecoder)
    }

    /**
     NSCoding protocol encoder.

     - parameter aCoder: The encoder.
     */
    public override func encode(with aCoder: NSCoder) {
        aCoder.encode(self.auth, forKey: "auth")
        super.encode(with: aCoder)
    }

    // MARK: - Class Methods -

    /**
    Checks the given email and/or username availablity for new `UsergridUser` objects using the shared instance of `UsergridClient`.

    - parameter email:      The optional email address.
    - parameter username:   The optional username.
    - parameter completion: The completion block.
    */
    public static func checkAvailable(_ email:String?, username:String?, completion:@escaping UsergridUserAvailabilityCompletion) {
        self.checkAvailable(Usergrid.sharedInstance, email: email, username: username, completion: completion)
    }

    /**
     Checks the given email and/or username availablity for new `UsergridUser` objects using with the given `UsergridClient`.

     - parameter client:     The client to use for checking availability.
     - parameter email:      The optional email address.
     - parameter username:   The optional username.
     - parameter completion: The completion block.
     */
    public static func checkAvailable(_ client: UsergridClient, email:String?, username:String?, completion:@escaping UsergridUserAvailabilityCompletion) {
        let query = UsergridQuery(USER_ENTITY_TYPE)
        if let emailValue = email {
            query.eq(UsergridUserProperties.email.stringValue, value: emailValue)
        }
        if let usernameValue = username {
            query.or().eq(UsergridUserProperties.username.stringValue, value: usernameValue)
        }
        client.GET(query) { (response) -> Void in
            completion(response.error, response.entity == nil)
        }
    }

    // MARK: - Instance Methods -

    /**
    Creates the user object in Usergrid if the user does not already exist with the shared instance of `UsergridClient`.

    - parameter completion: The optional completion block.
    */
    public func create(_ completion: UsergridResponseCompletion? = nil) {
        self.create(Usergrid.sharedInstance, completion: completion)
    }

    /**
    Creates the user object in Usergrid if the user does not already exist with the given `UsergridClient`.

    - parameter client:     The client to use for creation.
    - parameter completion: The optional completion block.
    */
    public func create(_ client: UsergridClient, completion: UsergridResponseCompletion? = nil) {
        client.POST(self) { (response) -> Void in
            if response.ok, let createdUser = response.user {
                self.copyInternalsFromEntity(createdUser)
            }
            completion?(response)
        }
    }

    /**
    Authenticates the specified user using the provided username and password with the shared instance of `UsergridClient`.

    While functionally similar to `UsergridClient.authenticateUser(auth)`, this method does not automatically assign this user to `UsergridClient.currentUser`:

    - parameter username:   The username.
    - parameter password:   The password.
    - parameter completion: The optional completion block.
    */
    public func login(_ username:String, password:String, completion: UsergridUserAuthCompletionBlock? = nil) {
        self.login(Usergrid.sharedInstance, username: username, password: password, completion: completion)
    }

    /**
    Authenticates the specified user using the provided username and password.

    While functionally similar to `UsergridClient.authenticateUser(auth)`, this method does not automatically assign this user to `UsergridClient.currentUser`:

    - parameter client:     The client to use for login.
    - parameter username:   The username.
    - parameter password:   The password.
    - parameter completion: The optional completion block.
    */
    public func login(_ client: UsergridClient, username:String, password:String, completion: UsergridUserAuthCompletionBlock? = nil) {
        let userAuth = UsergridUserAuth(username: username, password: password)
        client.authenticateUser(userAuth,setAsCurrentUser:false) { (auth, user, error) -> Void in
            self.auth = userAuth
            completion?(userAuth, user, error)
        }
    }

     /**
     Changes the User's current password with the shared instance of `UsergridClient`.

     - parameter old:        The old password.
     - parameter new:        The new password.
     - parameter completion: The optional completion block.
     */
    public func resetPassword(_ old:String, new:String, completion:UsergridUserResetPasswordCompletion? = nil) {
        self.resetPassword(Usergrid.sharedInstance, old: old, new: new, completion: completion)
    }

    /**
     Changes the User's current password with the shared instance of `UsergridClient`.

     - parameter client:     The client to use for resetting the password.
     - parameter old:        The old password.
     - parameter new:        The new password.
     - parameter completion: The optional completion block
     */
    public func resetPassword(_ client: UsergridClient, old:String, new:String, completion:UsergridUserResetPasswordCompletion? = nil) {
        client.resetPassword(self, old: old, new: new, completion: completion)
    }

    /**
     Attmepts to reauthenticate using the user's `UsergridUserAuth` instance property with the shared instance of `UsergridClient`.

     - parameter completion: The optional completion block.
     */
    public func reauthenticate(_ completion: UsergridUserAuthCompletionBlock? = nil) {
        self.reauthenticate(Usergrid.sharedInstance, completion: completion)
    }

    /**
     Attmepts to reauthenticate using the user's `UsergridUserAuth` instance property.

     - parameter client:     The client to use for reauthentication.
     - parameter completion: The optional completion block.
     */
    public func reauthenticate(_ client: UsergridClient, completion: UsergridUserAuthCompletionBlock? = nil) {
        guard let userAuth = self.auth
            else {
                completion?(nil, self, UsergridResponseError(errorName: "Invalid UsergridUserAuth.", errorDescription: "No UsergridUserAuth found on the UsergridUser."))
                return
        }

        client.authenticateUser(userAuth, setAsCurrentUser:self.isEqualToEntity(client.currentUser), completion: completion)
    }

    /**
    Invalidates the user token locally and remotely.

    - parameter completion: The optional completion block.
    */
    public func logout(_ completion:UsergridResponseCompletion? = nil) {
        self.logout(Usergrid.sharedInstance,completion:completion)
    }

    /**
    Invalidates the user token locally and remotely.

    - parameter client:     The client to use for logout.
    - parameter completion: The optional completion block.
    */
    public func logout(_ client: UsergridClient, completion:UsergridResponseCompletion? = nil) {
        guard let uuidOrUsername = self.uuidOrUsername,
              let accessToken = self.auth?.accessToken
            else {
                completion?(UsergridResponse(client:client, errorName:"Logout Failed.", errorDescription:"UUID or Access Token not found on UsergridUser object."))
                return
        }
        
        client.logoutUser(uuidOrUsername, token: accessToken) { (response) in
            self.auth = nil
            completion?(response)
        }
    }

    /**
     A special convenience function that connects a `UsergridDevice` to this `UsergridUser` using the shared instance of `UsergridClient`.

     - parameter device:     The device to connect to.  If nil it will use the `UsergridDevice.sharedDevice` instance.
     - parameter completion: The optional completion block.
     */
    public func connectToDevice(_ device:UsergridDevice? = nil, completion:UsergridResponseCompletion? = nil) {
        self.connectToDevice(Usergrid.sharedInstance, device: device, completion: completion)
    }

    /**
     A special convenience function that connects a `UsergridDevice` to this `UsergridUser`.

     - parameter client:     The `UsergridClient` object to use for connecting.
     - parameter device:     The device to connect to.  If nil it will use the `UsergridDevice.sharedDevice` instance.
     - parameter completion: The optional completion block.
     */
    public func connectToDevice(_ client:UsergridClient, device:UsergridDevice? = nil, completion:UsergridResponseCompletion? = nil) {
        let deviceToConnect = device ?? UsergridDevice.sharedDevice
        guard let _ = deviceToConnect.uuidOrName
            else {
            completion?(UsergridResponse(client: client, errorName: "Device cannot be connected to User.", errorDescription: "Device has neither an UUID or name specified."))
            return
        }

        self.connect(client, relationship: "", toEntity: deviceToConnect, completion: completion)
    }

    /**
     Gets the connected device using the shared instance of `UsergridClient`.

     - parameter completion: The optional completion block.
     */
    public func getConnectedDevice(_ completion:UsergridResponseCompletion? = nil) {
        self.getConnectedDevice(Usergrid.sharedInstance, completion: completion)
    }

    /**
     Gets the connected device.

     - parameter client:     The `UsergridClient` object to use for connecting.
     - parameter completion: The optional completion block.
     */
    public func getConnectedDevice(_ client:UsergridClient, completion:UsergridResponseCompletion? = nil) {
        client.getConnections(.out, entity: self, relationship: "device", completion: completion)
    }

    /**
     A special convenience function that disconnects a `UsergridDevice` from this `UsergridUser` using the shared instance of `UsergridClient`.

     - parameter device:     The device to connect to.  If nil it will use the `UsergridDevice.sharedDevice` instance.
     - parameter completion: The optional completion block.
     */
    public func disconnectFromDevice(_ device:UsergridDevice? = nil, completion:UsergridResponseCompletion? = nil) {
        self.disconnectFromDevice(Usergrid.sharedInstance, device: device, completion: completion)
    }

    /**
     A special convenience function that disconnects a `UsergridDevice` from this `UsergridUser`.

     - parameter client:     The `UsergridClient` object to use for connecting.
     - parameter device:     The device to connect to.
     - parameter completion: The optional completion block.
     */
    public func disconnectFromDevice(_ client:UsergridClient, device:UsergridDevice? = nil, completion:UsergridResponseCompletion? = nil) {
        let deviceToDisconnectFrom = device ?? UsergridDevice.sharedDevice
        guard let _ = deviceToDisconnectFrom.uuidOrName
            else {
                completion?(UsergridResponse(client: client, errorName: "Device cannot be disconnected from User.", errorDescription: "Device has neither an UUID or name specified."))
                return
        }

        self.disconnect(client, relationship: "", fromEntity: deviceToDisconnectFrom, completion: completion)
    }

    private func getUserSpecificProperty(_ userProperty: UsergridUserProperties) -> Any? {
        var propertyValue: Any? = super[userProperty.stringValue]
        switch userProperty {
            case .activated,.disabled :
                propertyValue = (propertyValue as AnyObject) as? Bool ?? false
            case .age :
                propertyValue = (propertyValue as AnyObject) as? Int ?? 0 // TODO: Check these conversions
            case .name,.username,.password,.email,.picture :
                break
        }
        return propertyValue
    }

    /**
    Subscript for the `UsergridUser` class.

    - Warning: When setting a properties value must be a valid JSON object.

    - Example usage:
     
        ```
        let someName = usergridUser["name"]
        usergridUser["name"] = someName
        ```
    */
    override public subscript(propertyName: String) -> Any? {
        get {
            if let userProperty = UsergridUserProperties.fromString(propertyName) {
                return self.getUserSpecificProperty(userProperty)
            } else {
                return super[propertyName]
            }
        }
        set(propertyValue) {
            super[propertyName] = propertyValue
        }
    }
}
