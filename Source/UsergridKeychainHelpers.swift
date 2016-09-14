//
//  UsergridKeychainHelpers.swift
//  UsergridSDK
//
//  Created by Robert Walsh on 12/21/15.
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

#if os(iOS) || os(tvOS) || os(watchOS)
import UIKit
#endif

private let USERGRID_KEYCHAIN_NAME = "Usergrid"
private let USERGRID_DEVICE_KEYCHAIN_SERVICE = "SharedDevice"
private let USERGRID_CURRENT_USER_KEYCHAIN_SERVICE = "CurrentUser"

private func usergridGenericKeychainItem() -> [String:Any] {
    var keychainItem: [String:Any] = [:]
    keychainItem[kSecClass as String] = kSecClassGenericPassword as String
    keychainItem[kSecAttrAccessible as String] = kSecAttrAccessibleAlways as String
    keychainItem[kSecAttrAccount as String] = USERGRID_KEYCHAIN_NAME
    return keychainItem
}

internal extension UsergridDevice {

    static func deviceKeychainItem() -> [String:Any] {
        var keychainItem = usergridGenericKeychainItem()
        keychainItem[kSecAttrService as String] = USERGRID_DEVICE_KEYCHAIN_SERVICE
        return keychainItem
    }

    static func createNewDeviceKeychainUUID() -> String {

        #if os(watchOS) || os(OSX)
            let usergridUUID = NSUUID().uuidString
        #elseif os(iOS) || os(tvOS)
            let usergridUUID = UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
        #endif

        return usergridUUID
    }

    private static func createNewSharedDevice() -> UsergridDevice {
        var deviceEntityDict = UsergridDevice.commonDevicePropertyDict()
        deviceEntityDict[UsergridEntityProperties.uuid.stringValue] = UsergridDevice.createNewDeviceKeychainUUID()
        let sharedDevice = UsergridDevice(type: UsergridDevice.DEVICE_ENTITY_TYPE, name: nil, propertyDict: deviceEntityDict)
        return sharedDevice
    }

    static func getOrCreateSharedDeviceFromKeychain() -> UsergridDevice {
        var queryAttributes = UsergridDevice.deviceKeychainItem()
        queryAttributes[kSecReturnData as String] = (kCFBooleanTrue != nil) as Bool
        queryAttributes[kSecReturnAttributes as String] = (kCFBooleanTrue != nil) as Bool
        var result: AnyObject?
        let status = withUnsafeMutablePointer(to: &result) { SecItemCopyMatching(queryAttributes as CFDictionary, UnsafeMutablePointer($0)) }
        if status == errSecSuccess {
            if let resultDictionary = result as? NSDictionary {
                if let resultData = resultDictionary[kSecValueData as String] as? Data {
                    if let sharedDevice = NSKeyedUnarchiver.unarchiveObject(with: resultData) as? UsergridDevice {
                        return sharedDevice
                    } else {
                        UsergridDevice.deleteSharedDeviceKeychainItem()
                    }
                }
            }
        }

        let sharedDevice = UsergridDevice.createNewSharedDevice()
        UsergridDevice.saveSharedDeviceKeychainItem(sharedDevice)
        return sharedDevice
    }


    static func saveSharedDeviceKeychainItem(_ device:UsergridDevice) {
        var queryAttributes = UsergridDevice.deviceKeychainItem()
        queryAttributes[kSecReturnData as String] = (kCFBooleanTrue != nil) as Bool
        queryAttributes[kSecReturnAttributes as String] = (kCFBooleanTrue != nil) as Bool

        let sharedDeviceData = NSKeyedArchiver.archivedData(withRootObject: device);

        if SecItemCopyMatching(queryAttributes as CFDictionary,nil) == errSecSuccess // Do we need to update keychain item or add a new one.
        {
            let attributesToUpdate = [kSecValueData as String:sharedDeviceData]
            let updateStatus = SecItemUpdate(UsergridDevice.deviceKeychainItem() as CFDictionary, attributesToUpdate as CFDictionary)
            if updateStatus != errSecSuccess {
                print("Error updating shared device data to keychain!")
            }
        }
        else
        {
            var keychainItem = UsergridDevice.deviceKeychainItem()
            keychainItem[kSecValueData as String] = sharedDeviceData
            let status = SecItemAdd(keychainItem as CFDictionary, nil)
            if status != errSecSuccess {
                print("Error adding shared device data to keychain!")
            }
        }
    }

    static func deleteSharedDeviceKeychainItem() {
        var queryAttributes = UsergridDevice.deviceKeychainItem()
        queryAttributes[kSecReturnData as String] = (kCFBooleanFalse != nil) as Bool
        queryAttributes[kSecReturnAttributes as String] = (kCFBooleanFalse != nil) as Bool
        if SecItemCopyMatching(queryAttributes as CFDictionary,nil) == errSecSuccess {
            let deleteStatus = SecItemDelete(queryAttributes as CFDictionary)
            if deleteStatus != errSecSuccess {
                print("Error deleting shared device data to keychain!")
            }
        }
    }
}

internal extension UsergridUser {

    static func userKeychainItem(_ client:UsergridClient) -> [String:Any] {
        var keychainItem = usergridGenericKeychainItem()
        keychainItem[kSecAttrService as String] = USERGRID_CURRENT_USER_KEYCHAIN_SERVICE + "." + client.appId + "." + client.orgId
        return keychainItem
    }

    static func getCurrentUserFromKeychain(_ client:UsergridClient) -> UsergridUser? {
        var queryAttributes = UsergridUser.userKeychainItem(client)
        queryAttributes[kSecReturnData as String] = (kCFBooleanTrue != nil) as Bool
        queryAttributes[kSecReturnAttributes as String] = (kCFBooleanTrue != nil) as Bool

        var result: AnyObject?
        let status = withUnsafeMutablePointer(to: &result) { SecItemCopyMatching(queryAttributes as CFDictionary, UnsafeMutablePointer($0)) }
        if status == errSecSuccess {
            if let resultDictionary = result as? NSDictionary {
                if let resultData = resultDictionary[kSecValueData as String] as? Data {
                    if let currentUser = NSKeyedUnarchiver.unarchiveObject(with: resultData) as? UsergridUser {
                        return currentUser
                    }
                }
            }
        }
        return nil
    }

    static func saveCurrentUserKeychainItem(_ client:UsergridClient, currentUser:UsergridUser) {
        var queryAttributes = UsergridUser.userKeychainItem(client)
        queryAttributes[kSecReturnData as String] = (kCFBooleanTrue != nil) as Bool
        queryAttributes[kSecReturnAttributes as String] = (kCFBooleanTrue != nil) as Bool

        if SecItemCopyMatching(queryAttributes as CFDictionary,nil) == errSecSuccess // Do we need to update keychain item or add a new one.
        {
            let attributesToUpdate = [kSecValueData as String:NSKeyedArchiver.archivedData(withRootObject: currentUser)]
            let updateStatus = SecItemUpdate(UsergridUser.userKeychainItem(client) as CFDictionary, attributesToUpdate as CFDictionary)
            if updateStatus != errSecSuccess {
                print("Error updating current user data to keychain!")
            }
        }
        else
        {
            var keychainItem = UsergridUser.userKeychainItem(client)
            keychainItem[kSecValueData as String] = NSKeyedArchiver.archivedData(withRootObject: currentUser)
            let status = SecItemAdd(keychainItem as CFDictionary, nil)
            if status != errSecSuccess {
                print("Error adding current user data to keychain!")
            }
        }
    }

    static func deleteCurrentUserKeychainItem(_ client:UsergridClient) {
        var queryAttributes = UsergridUser.userKeychainItem(client)
        queryAttributes[kSecReturnData as String] = (kCFBooleanFalse != nil) as Bool
        queryAttributes[kSecReturnAttributes as String] = (kCFBooleanFalse != nil) as Bool
        if SecItemCopyMatching(queryAttributes as CFDictionary,nil) == errSecSuccess {
            let deleteStatus = SecItemDelete(queryAttributes as CFDictionary)
            if deleteStatus != errSecSuccess {
                print("Error deleting current user data to keychain!")
            }
        }
    }
}
