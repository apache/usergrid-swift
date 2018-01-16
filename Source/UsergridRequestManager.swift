//
//  UsergridRequestManager.swift
//  UsergridSDK
//
//  Created by Robert Walsh on 9/22/15.
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

final class UsergridRequestManager {

    unowned let client: UsergridClient

    let session: URLSession

    var sessionDelegate : UsergridSessionDelegate {
        return session.delegate as! UsergridSessionDelegate
    }

    init(client:UsergridClient) {
        self.client = client

        let config = URLSessionConfiguration.default

        #if os(tvOS)
        config.httpAdditionalHeaders = ["User-Agent": "usergrid-tvOS/v\(UsergridSDKVersion)"]
        #elseif os(iOS)
        config.httpAdditionalHeaders = ["User-Agent": "usergrid-ios/v\(UsergridSDKVersion)"]
        #elseif os(watchOS)
        config.httpAdditionalHeaders = ["User-Agent": "usergrid-watchOS/v\(UsergridSDKVersion)"]
        #elseif os(OSX)
        config.httpAdditionalHeaders = ["User-Agent": "usergrid-osx/v\(UsergridSDKVersion)"]
        #endif

        self.session = URLSession(configuration:  config,
                                    delegate:       UsergridSessionDelegate(),
                                    delegateQueue:  nil)
    }

    deinit {
        session.invalidateAndCancel()
    }

    func performRequest(_ request:UsergridRequest, completion:UsergridResponseCompletion?) {
        session.dataTask(with: request.buildNSURLRequest()) { [weak self] (data, response, error) -> Void in
            let usergridResponse = UsergridResponse(client:self?.client, data: data, response: response as? HTTPURLResponse, error: error as NSError?)
            DispatchQueue.main.async {
                completion?(usergridResponse)
            }
        }.resume()
    }
}


// MARK: - Authentication -
extension UsergridRequestManager {

    static func getTokenAndExpiryFromResponseJSON(_ jsonDict:[String:Any]) -> (token:String?,expiry:Date?) {
        var token: String? = nil
        var expiry: Date? = nil
        if let accessToken = jsonDict["access_token"] as? String {
            token = accessToken
        }
        if let expiresIn = jsonDict["expires_in"] as? Int {
            let expiresInAdjusted = expiresIn - 5000
            expiry = Date(timeIntervalSinceNow: TimeInterval(expiresInAdjusted))
        }
        return (token,expiry)
    }

    func performUserAuthRequest(_ userAuth:UsergridUserAuth, request:UsergridRequest, completion:UsergridUserAuthCompletionBlock?) {
        session.dataTask(with: request.buildNSURLRequest()) { (data, response, error) -> Void in
            let dataAsJSON = try! JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers)

            var createdUser: UsergridUser? = nil
            var responseError: UsergridResponseError? = nil

            if let jsonDict = dataAsJSON as? [String:Any] {
                let tokenAndExpiry = UsergridRequestManager.getTokenAndExpiryFromResponseJSON(jsonDict)
                userAuth.accessToken = tokenAndExpiry.token
                userAuth.expiry = tokenAndExpiry.expiry

                if let userDict = jsonDict[UsergridUser.USER_ENTITY_TYPE] as? [String:Any] {
                    if let newUser = UsergridEntity.entity(jsonDict: userDict) as? UsergridUser {
                        newUser.auth = userAuth
                        createdUser = newUser
                    }
                }
                if createdUser == nil {
                    responseError = UsergridResponseError(jsonDictionary: jsonDict) ?? UsergridResponseError(errorName: "Auth Failed.", errorDescription: "Error Description: \(error?.localizedDescription ?? "").")
                }
            } else {
                responseError = UsergridResponseError(errorName: "Auth Failed.", errorDescription: "Error Description: \(error?.localizedDescription ?? "").")
            }

            DispatchQueue.main.async {
                completion?(userAuth, createdUser, responseError)
            }
        }.resume()
    }

    func performAppAuthRequest(_ appAuth: UsergridAppAuth, request: UsergridRequest, completion: UsergridAppAuthCompletionBlock?) {
        session.dataTask(with: request.buildNSURLRequest()) { (data, response, error) -> Void in
            let dataAsJSON = try! JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers)

            var responseError: UsergridResponseError? = nil

            if let jsonDict = dataAsJSON as? [String:Any] {
                let tokenAndExpiry = UsergridRequestManager.getTokenAndExpiryFromResponseJSON(jsonDict)
                appAuth.accessToken = tokenAndExpiry.token
                appAuth.expiry = tokenAndExpiry.expiry
            } else {
                responseError = UsergridResponseError(errorName: "Auth Failed.", errorDescription: "Error Description: \(error?.localizedDescription ?? "").")
            }

            DispatchQueue.main.async {
                completion?(appAuth, responseError)
            }
        }.resume()
    }
}

// MARK: - Asset Management -
extension UsergridRequestManager {

    func performAssetDownload(_ contentType:String, usergridRequest:UsergridRequest, progress: UsergridAssetRequestProgress? = nil, completion:UsergridAssetDownloadCompletion? = nil) {
        let downloadTask = session.downloadTask(with: usergridRequest.buildNSURLRequest())
        let requestWrapper = UsergridAssetRequestWrapper(session: self.session, sessionTask: downloadTask, progress: progress)  { (request) -> Void in
            var asset: UsergridAsset? = nil
            var responseError: UsergridResponseError? = nil

            if let assetData = request.responseData , assetData.count > 0 {
                asset = UsergridAsset(data: assetData, contentType: contentType)
            } else {
                responseError = UsergridResponseError(errorName: "Download Failed.", errorDescription: "Downloading asset failed.  No data was recieved.")
            }

            DispatchQueue.main.async {
                completion?(asset, responseError)
            }
        }
        self.sessionDelegate.addRequestDelegate(requestWrapper.sessionTask, requestWrapper:requestWrapper)
        requestWrapper.sessionTask.resume()
    }

    func performAssetUpload(_ usergridRequest:UsergridAssetUploadRequest, progress:UsergridAssetRequestProgress? = nil, completion: UsergridAssetUploadCompletion? = nil) {
        let uploadTask = session.uploadTask(with: usergridRequest.buildNSURLRequest() as URLRequest, from: usergridRequest.multiPartHTTPBody as Data)
        let requestWrapper = UsergridAssetRequestWrapper(session: self.session, sessionTask: uploadTask, progress: progress)  { [weak self] (request) -> Void in
            let response = UsergridResponse(client: self?.client, data: request.responseData, response: request.response as? HTTPURLResponse, error: request.error)
            DispatchQueue.main.async {
                completion?(usergridRequest.asset, response)
            }
        }
        self.sessionDelegate.addRequestDelegate(requestWrapper.sessionTask, requestWrapper:requestWrapper)
        requestWrapper.sessionTask.resume()
    }
}
