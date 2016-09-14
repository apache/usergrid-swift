//
//  UsergridExtensions.swift
//  UsergridSDK
//
//  Created by Robert Walsh on 10/6/15.
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

private let kUsergrid_Milliseconds_Per_Second = 1000

/// Extension methods to help create and manipulate `NSDate` objects returned by Usergrid.
public extension Date {
    /**
     Creates a new `NSDate` object with the given milliseconds.

     - parameter milliseconds: the milliseconds

     - returns: A new `NSDate` object.
     */
    public init(milliseconds: String) {
        self.init(timeIntervalSince1970:(milliseconds as NSString).doubleValue / Double(kUsergrid_Milliseconds_Per_Second))
    }
    /**
     Converts the `NSDate` object to milliseconds.

     - returns: The number of milliseconds corresponding to the date.
     */
    public func dateAsMilliseconds() -> Int {
        return Int(self.timeIntervalSince1970 * Double(kUsergrid_Milliseconds_Per_Second))
    }
    /**
     Converts the `NSDate` object to milliseconds and returns the value as a string.

     - returns: The number of milliseconds corresponding to the date as a string.
     */
    public func dateAsMillisecondsString() -> String {
        return Date.stringFromMilleseconds(self.dateAsMilliseconds())
    }
    /**
     Converts the number of milliseconds to a string.

     - parameter milliseconds: the milliseconds to convert

     - returns: The milliseconds as a string.
     */
    public static func stringFromMilleseconds(_ milliseconds:Int) -> String {
        return NSNumber(value: Int64(milliseconds)).stringValue
    }
    /**
     Converts the `NSDate` object to the corresponding UNIX time stamp as a string.

     - returns: The UNIX time stamp as a string.
     */
    public static func unixTimeStampString() -> String {
        return Date.stringFromMilleseconds(Date.nowAsMilliseconds())
    }
    /**
     Converts the `NSDate` object to the corresponding UNIX time stamp.

     - returns: The UNIX time stamp.
     */
    public static func unixTimeStamp() -> Int {
        return Date.nowAsMilliseconds()
    }
    /**
     Converts the current date to milliseconds.

     - returns: The milliseconds of the current date.
     */
    public static func nowAsMilliseconds() -> Int {
        var tv = timeval()
        let currentMillisecondTime = withUnsafeMutablePointer(to: &tv, { (t: UnsafeMutablePointer<timeval>) -> Int in
            gettimeofday(t, nil)
            return (Int(t.pointee.tv_sec) * kUsergrid_Milliseconds_Per_Second) + (Int(t.pointee.tv_usec) / kUsergrid_Milliseconds_Per_Second)
        })
        return currentMillisecondTime
    }
}

internal extension String {
    func isUuid() -> Bool {
        return (UUID(uuidString: self) != nil) ? true : false
    }
}

internal extension Dictionary {
    mutating func update(_ other:Dictionary) {
        for (key,value) in other {
            self.updateValue(value, forKey:key)
        }
    }
}
