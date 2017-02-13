//
//  UsergridEntity.swift
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
import CoreLocation

/**
`UsergridEntity` is the base class that contains a single Usergrid entity. 

`UsergridEntity` maintains a set of accessor properties for standard Usergrid schema properties (e.g. name, uuid), and supports helper methods for accessing any custom properties that might exist.
*/
open class UsergridEntity: NSObject, NSCoding {

    static private var subclassMappings: [String:UsergridEntity.Type] = [UsergridUser.USER_ENTITY_TYPE:UsergridUser.self,UsergridDevice.DEVICE_ENTITY_TYPE:UsergridDevice.self]

    // MARK: - Instance Properties -

    /// The property dictionary that stores the properties values of the `UsergridEntity` object.
    private var properties: [String : Any] {
        didSet {
            if let fileMetaData = properties.removeValue(forKey: UsergridFileMetaData.FILE_METADATA) as? [String:Any] {
                self.fileMetaData = UsergridFileMetaData(fileMetaDataJSON: fileMetaData)
            } else {
                self.fileMetaData = nil
            }
        }
    }

    /// The `UsergridAsset` that contains the asset data.
    internal(set) public var asset: UsergridAsset?

    /// The `UsergridFileMetaData` of this `UsergridEntity`.
    internal(set) public var fileMetaData : UsergridFileMetaData?

    /// Property helper method for the `UsergridEntity` objects `UsergridEntityProperties.type`.
    public var type: String { return self.getEntitySpecificProperty(.type) as! String }

    /// Property helper method for the `UsergridEntity` objects `UsergridEntityProperties.uuid`.
    public var uuid: String? { return self.getEntitySpecificProperty(.uuid) as? String }

    /// Property helper method for the `UsergridEntity` objects `UsergridEntityProperties.name`.
    public var name: String? { return self.getEntitySpecificProperty(.name) as? String }

    /// Property helper method for the `UsergridEntity` objects `UsergridEntityProperties.created`.
    public var created: Date? { return self.getEntitySpecificProperty(.created) as? Date }

    /// Property helper method for the `UsergridEntity` objects `UsergridEntityProperties.modified`.
    public var modified: Date? { return self.getEntitySpecificProperty(.modified) as? Date }

    /// Property helper method for the `UsergridEntity` objects `UsergridEntityProperties.location`.
    public var location: CLLocation? {
        get { return self.getEntitySpecificProperty(.location) as? CLLocation }
        set(newLocation) { self[UsergridEntityProperties.location.stringValue] = newLocation }
    }

    /// Property helper method to get the UUID or name of the `UsergridEntity`.
    public var uuidOrName: String? { return self.uuid ?? self.name }

    /// Tells you if this `UsergridEntity` has a type of `user`.
    public var isUser: Bool { return self is UsergridUser || self.type == UsergridUser.USER_ENTITY_TYPE }

    /// Tells you if there is an asset associated with this entity.
    public var hasAsset: Bool { return self.asset != nil || (self.fileMetaData?.contentLength ?? 0) > 0 }

    /// The JSON object value.
    public var jsonObjectValue : [String:Any] { return self.properties }

    /// The string value.
    public var stringValue : String { return NSString(data: try! JSONSerialization.data(withJSONObject: self.jsonObjectValue, options: .prettyPrinted), encoding: String.Encoding.utf8.rawValue) as! String }

    /// The description.
    open override var description : String {
        return "Properties of Entity: \(stringValue)."
    }

    /// The debug description.
    open override var debugDescription : String {
        return "Properties of Entity: \(stringValue)."
    }

    // MARK: - Initialization -

    /**
    Designated initializer for `UsergridEntity` objects

    - parameter type:         The type associated with the `UsergridEntity` object.
    - parameter name:         The optional name associated with the `UsergridEntity` object.
    - parameter propertyDict: The optional property dictionary that the `UsergridEntity` object will start out with.

    - returns: A new `UsergridEntity` object.
    */
    required public init(type:String, name:String? = nil, propertyDict:[String:Any]? = nil) {
        self.properties = propertyDict ?? [:]
        super.init()

        if self is UsergridUser {
            self.properties[UsergridEntityProperties.type.stringValue] = UsergridUser.USER_ENTITY_TYPE
        } else if self is UsergridDevice {
            self.properties[UsergridEntityProperties.type.stringValue] = UsergridDevice.DEVICE_ENTITY_TYPE
        } else {
            self.properties[UsergridEntityProperties.type.stringValue] = type
        }

        if let entityName = name {
            self.properties[UsergridEntityProperties.name.stringValue] = entityName
        }

        if let fileMetaData = self.properties.removeValue(forKey: UsergridFileMetaData.FILE_METADATA) as? [String:Any] {
            self.fileMetaData = UsergridFileMetaData(fileMetaDataJSON: fileMetaData)
        }
    }

    internal func copyInternalsFromEntity(_ entity:UsergridEntity) {
        self.properties = entity.properties
    }

    /**
     Used for custom mapping subclasses to a given `Usergrid` type.

     - parameter type:       The type of the `Usergrid` object.
     - parameter toSubclass: The subclass `UsergridEntity.Type` to map it to.
     */
    public static func mapCustomType(_ type:String,toSubclass:UsergridEntity.Type) {
        UsergridEntity.subclassMappings[type] = toSubclass
    }

    /**
    Class convenience constructor for creating `UsergridEntity` objects dynamically.

    - parameter jsonDict: A valid JSON dictionary which must contain at the very least a value for the `type` key.

    - returns: A `UsergridEntity` object provided that the `type` key within the dictionay exists. Otherwise nil.
    */
    public class func entity(jsonDict: [String:Any]) -> UsergridEntity? {
        guard let type = jsonDict[UsergridEntityProperties.type.stringValue] as? String
            else {
                return nil
        }

        let mapping = UsergridEntity.subclassMappings[type] ?? UsergridEntity.self
        return mapping.init(type: type, propertyDict: jsonDict)
    }

    /**
    Class convenience constructor for creating multiple `UsergridEntity` objects dynamically.

    - parameter entitiesJSONArray: An array which contains dictionaries that are used to create the `UsergridEntity` objects.

    - returns: An array of `UsergridEntity`.
    */
    public class func entities(jsonArray entitiesJSONArray: [[String:Any]]) -> [UsergridEntity] {
        var entityArray : [UsergridEntity] = []
        for entityJSONDict in entitiesJSONArray {
            if let entity = UsergridEntity.entity(jsonDict:entityJSONDict) {
                entityArray.append(entity)
            }
        }
        return entityArray
    }

    // MARK: - NSCoding -

    /**
    NSCoding protocol initializer.

    - parameter aDecoder: The decoder.

    - returns: A decoded `UsergridEntity` object.
    */
    required public init?(coder aDecoder: NSCoder) {
        guard let properties = aDecoder.decodeObject(forKey: "properties") as? [String:Any]
            else {
                self.properties = [:]
                super.init()
                return nil
        }
        self.properties = properties
        self.fileMetaData = aDecoder.decodeObject(forKey: "fileMetaData") as? UsergridFileMetaData
        self.asset = aDecoder.decodeObject(forKey: "asset") as? UsergridAsset
        super.init()
    }

    /**
     NSCoding protocol encoder.

     - parameter aCoder: The encoder.
     */
    open func encode(with aCoder: NSCoder) {
        aCoder.encode(self.properties, forKey: "properties")
        aCoder.encode(self.fileMetaData, forKey: "fileMetaData")
        aCoder.encode(self.asset, forKey: "asset")
    }

    // MARK: - Property Manipulation -

    /**
    Subscript for the `UsergridEntity` class.
    
    - Example usage:
        ```
        let propertyValue = usergridEntity["propertyName"]
        usergridEntity["propertyName"] = propertyValue
        ```
    */
    public subscript(propertyName: String) -> Any? {
        get {
            if let entityProperty = UsergridEntityProperties.fromString(propertyName) {
                return self.getEntitySpecificProperty(entityProperty)
            } else {
                let propertyValue = self.properties[propertyName]
                if propertyValue is NSNull { // Let's just return nil for properties that have been removed instead of NSNull
                    return nil
                } else {
                    return propertyValue
                }
            }
        }
        set(propertyValue) {
            if let value = propertyValue {
                if let entityProperty = UsergridEntityProperties.fromString(propertyName) {
                    if entityProperty.isMutableForEntity(self) {
                        if entityProperty == .location {
                            if let location = value as? CLLocation {
                                properties[propertyName] = [ENTITY_LATITUDE:location.coordinate.latitude,
                                                            ENTITY_LONGITUDE:location.coordinate.longitude]
                            } else if let location = value as? CLLocationCoordinate2D {
                                properties[propertyName] = [ENTITY_LATITUDE:location.latitude,
                                                            ENTITY_LONGITUDE:location.longitude]
                            } else if let location = value as? [String:Double] {
                                if let lat = location[ENTITY_LATITUDE], let long = location[ENTITY_LONGITUDE] {
                                    properties[propertyName] = [ENTITY_LATITUDE:lat,
                                                                ENTITY_LONGITUDE:long]
                                }
                            }
                        } else {
                            properties[propertyName] = value
                        }
                    }
                } else {
                    properties[propertyName] = value
                }
            } else { // If the property value is nil we assume they wanted to remove the property.

                // We set the value for this property to Null so that when a PUT is performed on the entity the property will actually be removed from the Entity on Usergrid
                if let entityProperty = UsergridEntityProperties.fromString(propertyName){
                    if entityProperty.isMutableForEntity(self) {
                        properties[propertyName] = NSNull()
                    }
                } else {
                    properties[propertyName] = NSNull()
                }
            }
        }
    }

    /**
    Updates a properties value for the given property name.

    - parameter name:  The name of the property.
    - parameter value: The value to update to.
    */
    public func putProperty(_ name:String,value:Any?) {
        self[name] = value
    }

    /**
    Updates a set of properties that are within the given properties dictionary.

    - parameter properties: The property dictionary containing the properties names and values.
    */
    public func putProperties(_ properties:[String:Any]) {
        for (name,value) in properties {
            self.putProperty(name, value: value)
        }
    }

    /**
    Removes the property for the given property name.

    - parameter name: The name of the property.
    */
    public func removeProperty(_ name:String) {
        self[name] = nil
    }

    /**
    Removes the properties with the names within the propertyNames array

    - parameter propertyNames: An array of property names.
    */
    public func removeProperties(_ propertyNames:[String]) {
        for name in propertyNames {
            self.removeProperty(name)
        }
    }

    /**
    Appends the given value to the end of the properties current value.

    - parameter name:  The name of the property.
     - parameter value: The value or an array of values to append.
    */
    public func append(_ name:String, value:Any) {
        self.insertArray(name, values:value as? [Any] ?? [value], index: Int.max)
    }

    /**
    Inserts the given value at the given index within the properties current value.

    - parameter name:  The name of the property.
    - parameter index: The index to insert at.
    - parameter value: The value or an array of values to insert.
    */
    public func insert(_ name:String, value:Any, index:Int = 0) {
        self.insertArray(name, values:value as? [Any] ?? [value], index: index)
    }

    /**
    Inserts an array of property values at a given index within the properties current value.

    - parameter name:   The name of the property
    - parameter index:  The index to insert at.
    - parameter values: The values to insert.
    */
    private func insertArray(_ name:String,values:[Any], index:Int = 0) {
        if let propertyValue = self[name] {
            if let arrayValue = propertyValue as? [Any] {
                var arrayOfValues = arrayValue
                if  index > arrayValue.count {
                    arrayOfValues.append(contentsOf: values)
                } else {
                    arrayOfValues.insert(contentsOf: values, at: index)
                }
                self[name] = arrayOfValues
            } else {
                if index > 0 {
                    self[name] = [propertyValue] + values
                } else {
                    self[name] = values + [propertyValue]
                }
            }
        } else {
            self[name] = values
        }
    }

    /**
    Removes the last value of the properties current value.

    - parameter name: The name of the property.
    */
    public func pop(_ name:String) {
        if let arrayValue = self[name] as? [Any] , arrayValue.count > 0 {
            var arrayOfValues = arrayValue
            arrayOfValues.removeLast()
            self[name] = arrayOfValues
        }
    }

    /**
    Removes the first value of the properties current value.

    - parameter name: The name of the property.
    */
    public func shift(_ name:String) {
        if let arrayValue = self[name] as? [Any] , arrayValue.count > 0 {
            var arrayOfValues = arrayValue
            arrayOfValues.removeFirst()
            self[name] = arrayOfValues
        }
    }

    private func getEntitySpecificProperty(_ entityProperty: UsergridEntityProperties) -> Any? {
        var propertyValue: Any? = nil
        switch entityProperty {
            case .uuid,.type,.name :
                propertyValue = self.properties[entityProperty.stringValue]
            case .created,.modified :
                if let milliseconds = self.properties[entityProperty.stringValue] as? Int {
                    propertyValue = Date(milliseconds: milliseconds.description)
                }
            case .location :
                if let locationDict = self.properties[entityProperty.stringValue] as? [String:Double], let lat = locationDict[ENTITY_LATITUDE], let long = locationDict[ENTITY_LONGITUDE] {
                    propertyValue = CLLocation(latitude: lat, longitude: long)
                }
            }
        return propertyValue
    }

    // MARK: - CRUD Convenience Methods -

    /**
    Performs a GET on the `UsergridEntity` using the shared instance of `UsergridClient`.

    - parameter completion: An optional completion block that, if successful, will contain the reloaded `UsergridEntity` object.
    */
    public func reload(_ completion: UsergridResponseCompletion? = nil) {
        self.reload(Usergrid.sharedInstance, completion: completion)
    }

    /**
    Performs a GET on the `UsergridEntity`.

    - parameter client:     The client to use when reloading.
    - parameter completion: An optional completion block that, if successful, will contain the reloaded `UsergridEntity` object.
    */
    public func reload(_ client:UsergridClient, completion: UsergridResponseCompletion? = nil) {
        guard let uuidOrName = self.uuidOrName
            else {
                completion?(UsergridResponse(client: client, errorName: "Entity cannot be reloaded.", errorDescription: "Entity has neither an UUID or name specified."))
                return
        }

        client.GET(self.type, uuidOrName: uuidOrName) { response in
            if let responseEntity = response.entity {
                self.copyInternalsFromEntity(responseEntity)
            }
            completion?(response)
        }
    }

    /**
    Performs a PUT (or POST if no UUID is found) on the `UsergridEntity` using the shared instance of `UsergridClient`.

    - parameter completion: An optional completion block that, if successful, will contain the updated/saved `UsergridEntity` object.
    */
    public func save(_ completion: UsergridResponseCompletion? = nil) {
        self.save(Usergrid.sharedInstance, completion: completion)
    }

    /**
    Performs a PUT (or POST if no UUID is found) on the `UsergridEntity`.

    - parameter client:     The client to use when saving.
    - parameter completion: An optional completion block that, if successful, will contain the updated/saved `UsergridEntity` object.
    */
    public func save(_ client:UsergridClient, completion: UsergridResponseCompletion? = nil) {
        if let _ = self.uuid { // If UUID exists we PUT otherwise POST
            client.PUT(self) { response in
                if let responseEntity = response.entity {
                    self.copyInternalsFromEntity(responseEntity)
                }
                completion?(response)
            }
        } else {
            client.POST(self) { response in
                if let responseEntity = response.entity {
                    self.copyInternalsFromEntity(responseEntity)
                }
                completion?(response)
            }
        }
    }

    /**
    Performs a DELETE on the `UsergridEntity` using the shared instance of the `UsergridClient`.

    - parameter completion: An optional completion block.
    */
    public func remove(_ completion: UsergridResponseCompletion? = nil) {
        self.remove(Usergrid.sharedInstance, completion: completion)
    }

    /**
    Performs a DELETE on the `UsergridEntity`.

    - parameter client:     The client to use when removing.
    - parameter completion: An optional completion block.
    */
    public func remove(_ client:UsergridClient, completion: UsergridResponseCompletion? = nil) {
        client.DELETE(self, completion: completion)
    }

    // MARK: - Asset Management -

    /**
    Uploads the given `UsergridAsset` and the data within it and creates an association between this `UsergridEntity` with the given `UsergridAsset` using the shared instance of `UsergridClient`.

    - parameter asset:      The `UsergridAsset` object to upload.
    - parameter progress:   An optional progress block to keep track of upload progress.
    - parameter completion: An optional completion block.
    */
    public func uploadAsset(_ asset:UsergridAsset, progress:UsergridAssetRequestProgress? = nil, completion:UsergridAssetUploadCompletion? = nil) {
        self.uploadAsset(Usergrid.sharedInstance, asset: asset, progress: progress, completion: completion)
    }

    /**
    Uploads the given `UsergridAsset` and the data within it and creates an association between this `UsergridEntity` with the given `UsergridAsset`.

    - parameter client:     The client to use when uploading.
    - parameter asset:      The `UsergridAsset` object to upload.
    - parameter progress:   An optional progress block to keep track of upload progress.
    - parameter completion: An optional completion block.
    */
    public func uploadAsset(_ client:UsergridClient, asset:UsergridAsset, progress:UsergridAssetRequestProgress? = nil, completion:UsergridAssetUploadCompletion? = nil) {
        client.uploadAsset(self, asset: asset, progress:progress, completion:completion)
    }

    /**
    Downloads the `UsergridAsset` that is associated with this `UsergridEntity` using the shared instance of `UsergridClient`.

    - parameter contentType: The content type of the data to load.
    - parameter progress:    An optional progress block to keep track of download progress.
    - parameter completion:  An optional completion block.
    */
    public func downloadAsset(_ contentType:String, progress:UsergridAssetRequestProgress? = nil, completion:UsergridAssetDownloadCompletion? = nil) {
        self.downloadAsset(Usergrid.sharedInstance, contentType: contentType, progress: progress, completion: completion)
    }

    /**
    Downloads the `UsergridAsset` that is associated with this `UsergridEntity`.

    - parameter client:      The client to use when uploading.
    - parameter contentType: The content type of the data to load.
    - parameter progress:    An optional progress block to keep track of download progress.
    - parameter completion:  An optional completion block.
    */
    public func downloadAsset(_ client:UsergridClient, contentType:String, progress:UsergridAssetRequestProgress? = nil, completion:UsergridAssetDownloadCompletion? = nil) {
        client.downloadAsset(self, contentType: contentType, progress:progress, completion: completion)
    }

    // MARK: - Connection Management -

    /**
    Creates a relationship between this `UsergridEntity` and the given entity using the shared instance of `UsergridClient`.

    - parameter relationship: The relationship type.
    - parameter toEntity:     The entity to connect.
    - parameter completion:   An optional completion block.
    */
    public func connect(_ relationship:String, toEntity:UsergridEntity, completion: UsergridResponseCompletion? = nil) {
        self.connect(Usergrid.sharedInstance, relationship: relationship, toEntity: toEntity, completion: completion)
    }

    /**
    Creates a relationship between this `UsergridEntity` and the given entity.

    - parameter client:       The client to use when connecting.
    - parameter relationship: The relationship type.
    - parameter toEntity:     The entity to connect.
    - parameter completion:   An optional completion block.
    */
    public func connect(_ client:UsergridClient, relationship:String, toEntity:UsergridEntity, completion: UsergridResponseCompletion? = nil) {
        client.connect(self, relationship: relationship, to: toEntity, completion: completion)
    }

    /**
    Removes a relationship between this `UsergridEntity` and the given entity using the shared instance of `UsergridClient`.

    - parameter relationship: The relationship type.
    - parameter fromEntity:   The entity to disconnect.
    - parameter completion:   An optional completion block.
    */
    public func disconnect(_ relationship:String, fromEntity:UsergridEntity, completion: UsergridResponseCompletion? = nil) {
        self.disconnect(Usergrid.sharedInstance, relationship: relationship, fromEntity: fromEntity, completion: completion)
    }

    /**
    Removes a relationship between this `UsergridEntity` and the given entity.

    - parameter client:       The client to use when disconnecting.
    - parameter relationship: The relationship type.
    - parameter fromEntity:   The entity to disconnect.
    - parameter completion:   An optional completion block.
    */
    public func disconnect(_ client:UsergridClient, relationship:String, fromEntity:UsergridEntity, completion: UsergridResponseCompletion? = nil) {
        client.disconnect(self, relationship: relationship, from: fromEntity, completion: completion)
    }

    /**
    Gets the `UsergridEntity` objects, if any, which are connected via the relationship using the shared instance of `UsergridClient`.

    - parameter direction:      The direction of the connection.
    - parameter relationship:   The relationship type.
    - parameter query:          The optional query.
    - parameter completion:     An optional completion block.
    */
    public func getConnections(_ direction:UsergridDirection, relationship:String, query:UsergridQuery? = nil, completion:UsergridResponseCompletion? = nil) {
        self.getConnections(Usergrid.sharedInstance, direction: direction, relationship: relationship, query: query, completion: completion)
    }

    /**
    Gets the `UsergridEntity` objects, if any, which are connected via the relationship.

    - parameter client:       The client to use when getting the connected `UsergridEntity` objects.
    - parameter direction:    The direction of the connection.
    - parameter relationship: The relationship type.
    - parameter query:        The optional query.
    - parameter completion:   An optional completion block.
    */
    public func getConnections(_ client:UsergridClient, direction:UsergridDirection, relationship:String, query:UsergridQuery? = nil, completion:UsergridResponseCompletion? = nil) {
        client.getConnections(direction, entity: self, relationship: relationship, query:query, completion: completion)
    }

    // MARK: - Helper methods -

    /**
     Determines if the two `UsergridEntity` objects are equal.  i.e. they have the same non nil uuidOrName.

     - parameter entity: The entity to check.

     - returns: If the two `UsergridEntity` objects are equal.  i.e. they have the same non nil uuidOrName.
     */
    public func isEqualToEntity(_ entity: UsergridEntity?) -> Bool {
        guard let selfUUID = self.uuidOrName,
              let entityUUID = entity?.uuidOrName
            else {
                return false
        }
        return selfUUID == entityUUID
    }
}
