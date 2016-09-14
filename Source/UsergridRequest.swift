//
//  UsergridRequest.swift
//  UsergridSDK
//
//  Created by Robert Walsh on 1/12/16.
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
 The UsergridRequest class incapsulates the properties that all requests made by the SDK have in common.  

 This class is also functions to create `NSURLRequest` objects based on the properties of the class.
*/
public class UsergridRequest : NSObject {

    // MARK: - Instance Properties -

    /// The HTTP method.
    public let method: UsergridHttpMethod

    /// The base URL.
    public let baseUrl: String

    /// The paths to append to the base URL.
    public let paths: [String]?

    /// The query to append to the URL.
    public let query: UsergridQuery?

    /// The auth that will be used.
    public let auth: UsergridAuth?

    /// The headers to add to the request.
    public let headers: [String:String]?

    /// The JSON body that will be set on the request.  Can be either a valid JSON object or NSData.
    public let jsonBody: Any?
    
    /// The query params that will be set on the request.
    public let queryParams: [String:String]?

    // MARK: - Initialization -

    /**
    The designated initializer for `UsergridRequest` objects.
    
    - parameter method:      The HTTP method.
    - parameter baseUrl:     The base URL.
    - parameter paths:       The optional paths to append to the base URL.
    - parameter query:       The optional query to append to the URL.
    - parameter auth:        The optional `UsergridAuth` that will be used in the Authorization header.
    - parameter headers:     The optional headers.
    - parameter jsonBody:    The optional JSON body. Can be either a valid JSON object or NSData.
    - parameter queryParams: The optional query params to be appended to the request url.
    
    - returns: A new instance of `UsergridRequest`.
    */
    public init(method:UsergridHttpMethod,
        baseUrl:String,
        paths:[String]? = nil,
        query:UsergridQuery? = nil,
        auth:UsergridAuth? = nil,
        headers:[String:String]? = nil,
        jsonBody:Any? = nil,
        queryParams:[String:String]? = nil) {
            self.method = method
            self.baseUrl = baseUrl
            self.paths = paths
            self.auth = auth
            self.headers = headers
            self.query = query
            self.queryParams = queryParams
            if let body = jsonBody , (body is Data || JSONSerialization.isValidJSONObject(body)) {
                self.jsonBody = body
            } else {
                self.jsonBody = nil
            }
    }

    // MARK: - Instance Methods -

    /**
    Constructs a `NSURLRequest` object with this objects instance properties.

    - returns: An initialized and configured `NSURLRequest` object.
    */
    public func buildNSURLRequest() -> URLRequest {
        let request = NSMutableURLRequest(url: self.buildURL())
        request.httpMethod = self.method.stringValue
        self.applyHeaders(request)
        self.applyBody(request)
        self.applyAuth(request)
        return request as URLRequest
    }

    private func buildURL() -> URL {
        var constructedURLString = self.baseUrl
        if let appendingPaths = self.paths {
            for pathToAppend in appendingPaths {
                if let encodedPath = pathToAppend.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlPathAllowed) {
                    constructedURLString = "\(constructedURLString)\(UsergridRequest.FORWARD_SLASH)\(encodedPath)"
                }
            }
        }
        if let queryToAppend = self.query {
            let appendFromQuery = queryToAppend.build()
            if !appendFromQuery.isEmpty {
                constructedURLString = "\(constructedURLString)\(UsergridRequest.FORWARD_SLASH)\(appendFromQuery)"
            }
        }
        if let queryParams = self.queryParams {
            if var components = URLComponents(string: constructedURLString) {
                components.queryItems = components.queryItems ?? []
                for (key, value) in queryParams {
                    let q: URLQueryItem = URLQueryItem(name: key, value: value)
                    components.queryItems!.append(q)
                }
                constructedURLString = components.string!
            }
        }
        return URL(string:constructedURLString)!
    }

    fileprivate func applyHeaders(_ request:NSMutableURLRequest) {
        if let httpHeaders = self.headers {
            for (key,value) in httpHeaders {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
    }

    private func applyBody(_ request:NSMutableURLRequest) {
        if let jsonBody = self.jsonBody, let httpBody = UsergridRequest.jsonBodyToData(jsonBody) {
            request.httpBody = httpBody
            request.setValue(String(format: "%lu", httpBody.count), forHTTPHeaderField: UsergridRequest.CONTENT_LENGTH)
        }
    }

    private func applyAuth(_ request:NSMutableURLRequest) {
        if let usergridAuth = self.auth {
            if usergridAuth.isValid, let accessToken = usergridAuth.accessToken {
                request.setValue("\(UsergridRequest.BEARER) \(accessToken)", forHTTPHeaderField: UsergridRequest.AUTHORIZATION)
            }
        }
    }

    private static func jsonBodyToData(_ jsonBody:Any) -> Data? {
        if let jsonBodyAsNSData = jsonBody as? Data {
            return jsonBodyAsNSData
        } else {
            var jsonBodyAsNSData: Data? = nil
            do { jsonBodyAsNSData = try JSONSerialization.data(withJSONObject: jsonBody, options: JSONSerialization.WritingOptions(rawValue: 0)) }
            catch { print(error) }
            return jsonBodyAsNSData
        }
    }

    fileprivate static let AUTHORIZATION = "Authorization"
    fileprivate static let ACCESS_TOKEN = "access_token"
    fileprivate static let APPLICATION_JSON = "application/json; charset=utf-8"
    fileprivate static let BEARER = "Bearer"
    fileprivate static let CONTENT_LENGTH = "Content-Length"
    fileprivate static let CONTENT_TYPE = "Content-Type"
    fileprivate static let FORWARD_SLASH = "/"

    static func jsonHeaderContentType() -> [String:String] {
        return [UsergridRequest.CONTENT_TYPE:UsergridRequest.APPLICATION_JSON]
    }
}

/**
 The `UsergridRequest` sub class which is used for uploading assets.
 */
public class UsergridAssetUploadRequest: UsergridRequest {

    // MARK: - Instance Properties -

    /// The asset to use for uploading.
    public let asset: UsergridAsset

    /// A constructed multipart http body for requests to upload.
    public var multiPartHTTPBody: Data {
        let httpBodyString = UsergridAssetUploadRequest.MULTIPART_START +
            "\(UsergridAssetUploadRequest.CONTENT_DISPOSITION):\(UsergridAssetUploadRequest.FORM_DATA); name=file; filename=\(self.asset.filename)\r\n" +
            "\(UsergridRequest.CONTENT_TYPE): \(self.asset.contentType)\r\n\r\n"


        var httpBody = Data()
        httpBody.append(httpBodyString.data(using: String.Encoding.utf8)!)
        httpBody.append(self.asset.data)
        httpBody.append(UsergridAssetUploadRequest.MULTIPART_END.data(using: String.Encoding.utf8)!)

        return httpBody
    }

    // MARK: - Initialization -

    /**
     The designated initializer for `UsergridAssetUploadRequest` objects.

     - parameter baseUrl: The base URL.
     - parameter paths:   The optional paths to append to the base URL.
     - parameter auth:    The optional `UsergridAuth` that will be used in the Authorization header.
     - parameter asset:   The asset to upload.

    - returns: A new instance of `UsergridRequest`.
     */
    public init(baseUrl:String,
                paths:[String]? = nil,
                auth:UsergridAuth? = nil,
                asset:UsergridAsset) {
                    self.asset = asset
                    super.init(method: .put, baseUrl: baseUrl, paths: paths, auth: auth)
    }

    fileprivate override func applyHeaders(_ request: NSMutableURLRequest) {
        super.applyHeaders(request)
        request.setValue(UsergridAssetUploadRequest.ASSET_UPLOAD_CONTENT_HEADER, forHTTPHeaderField: UsergridRequest.CONTENT_TYPE)
        request.setValue(String(format: "%lu", self.multiPartHTTPBody.count), forHTTPHeaderField: UsergridRequest.CONTENT_LENGTH)
    }

    private static let ASSET_UPLOAD_BOUNDARY = "usergrid-asset-upload-boundary"
    private static let ASSET_UPLOAD_CONTENT_HEADER = "multipart/form-data; boundary=\(UsergridAssetUploadRequest.ASSET_UPLOAD_BOUNDARY)"
    private static let CONTENT_DISPOSITION = "Content-Disposition"
    private static let MULTIPART_START = "--\(UsergridAssetUploadRequest.ASSET_UPLOAD_BOUNDARY)\r\n"
    private static let MULTIPART_END = "\r\n--\(UsergridAssetUploadRequest.ASSET_UPLOAD_BOUNDARY)--\r\n"
    private static let FORM_DATA = "form-data"
}
