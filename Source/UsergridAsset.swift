//
//  UsergridAsset.swift
//  UsergridSDK
//
//  Created by Robert Walsh on 9/21/15.
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

#if os(iOS) || os(watchOS) || os(tvOS)
import UIKit
import MobileCoreServices
#endif

/// The progress block used in `UsergridAsset` are being uploaded or downloaded.
public typealias UsergridAssetRequestProgress = (_ bytesFinished:Int64, _ bytesExpected: Int64) -> Void

/// The completion block used in `UsergridAsset` are finished uploading.
public typealias UsergridAssetUploadCompletion = (_ asset:UsergridAsset?, _ response: UsergridResponse) -> Void

/// The completion block used in `UsergridAsset` are finished downloading.
public typealias UsergridAssetDownloadCompletion = (_ asset:UsergridAsset?, _ error: UsergridResponseError?) -> Void

/**
As Usergrid supports storing binary assets, the SDKs are designed to make uploading assets easier and more robust. Attaching, uploading, and downloading assets is handled by the `UsergridEntity` class.

Unless defined, whenever possible, the content-type will be inferred from the data provided, and the attached file (if not already a byte-array representation) will be binary-encoded.
*/
public class UsergridAsset: NSObject, NSCoding {

    public static let DEFAULT_FILE_NAME = "file"

    // MARK: - Instance Properties -

    /// The filename to be used in the multipart/form-data request.
    public let filename: String

    /// Binary representation of the asset's data.
    public let data: Data

    /// A representation of the folder location the asset was loaded from, if it was provided in the initialization.
    public let originalLocation: String?

    /// The Content-type of the asset to be used when defining content-type inside the multipart/form-data request.
    public var contentType: String

    ///  The content length of the assets data.
    public var contentLength: Int { return self.data.count }
    
    // MARK: - Initialization -

    /**
    Designated initializer for `UsergridAsset` objects.

    - parameter fileName:         The file name associated with the file data.
    - parameter data:             The data of the file.
    - parameter originalLocation: An optional original location of the file.
    - parameter contentType:      The content type of the file.

    - returns: A new instance of `UsergridAsset`.
    */
    public init(filename:String? = UsergridAsset.DEFAULT_FILE_NAME, data:Data, originalLocation:String? = nil, contentType:String) {
        self.filename = filename ?? UsergridAsset.DEFAULT_FILE_NAME
        self.data = data
        self.originalLocation = originalLocation
        self.contentType = contentType
    }

    #if os(iOS) || os(watchOS) || os(tvOS)
    /**
    Convenience initializer for `UsergridAsset` objects dealing with image data.

    - parameter fileName:         The file name associated with the file data.
    - parameter image:            The `UIImage` object to upload.
    - parameter imageContentType: The content type of the `UIImage`

    - returns: A new instance of `UsergridAsset` if the data can be gathered from the passed in `UIImage`, otherwise nil.
    */
    public convenience init?(filename:String? = UsergridAsset.DEFAULT_FILE_NAME, image:UIImage, imageContentType:UsergridImageContentType = .png) {
        var imageData: Data?
        switch(imageContentType) {
            case .png :
                imageData = UIImagePNGRepresentation(image)
            case .jpeg :
                imageData = UIImageJPEGRepresentation(image, 1.0)
        }
        if let assetData = imageData {
            self.init(filename:filename,data:assetData,contentType:imageContentType.stringValue)
        } else {
            self.init(filename:"",data:Data(),contentType:"")
            return nil
        }
    }
    #endif

    /**
    Convenience initializer for `UsergridAsset` objects dealing directly with files on disk.

    - parameter fileName:    The file name associated with the file data.
    - parameter fileURL:     The `NSURL` object associated with the file.
    - parameter contentType: The content type of the `UIImage`.  If not specified it will try to figure out the type and if it can't initialization will fail.

    - returns: A new instance of `UsergridAsset` if the data can be gathered from the passed in `NSURL`, otherwise nil.
    */
    public convenience init?(filename:String? = UsergridAsset.DEFAULT_FILE_NAME, fileURL:URL, contentType:String? = nil) {
        if fileURL.isFileURL, let assetData = try? Data(contentsOf: fileURL) {
            var fileNameToUse = filename
            if fileNameToUse != UsergridAsset.DEFAULT_FILE_NAME, !fileURL.lastPathComponent.isEmpty {
                fileNameToUse = fileURL.lastPathComponent
            }
            if let fileContentType = contentType ?? UsergridAsset.MIMEType(fileURL) {
                self.init(filename:fileNameToUse,data:assetData,originalLocation:fileURL.absoluteString,contentType:fileContentType)
            } else {
                print("Usergrid Error: Failed to imply content type of the asset.")
                self.init(filename:"",data:Data(),contentType:"")
                return nil
            }
        } else {
            print("Usergrid Error: fileURL parameter must be a file URL.")
            self.init(filename:"",data:Data(),contentType:"")
            return nil
        }
    }

    // MARK: - NSCoding -

    /**
    NSCoding protocol initializer.

    - parameter aDecoder: The decoder.

    - returns: A decoded `UsergridUser` object.
    */
    required public init?(coder aDecoder: NSCoder) {
        guard   let filename = aDecoder.decodeObject(forKey: "filename") as? String,
                let assetData = aDecoder.decodeObject(forKey: "data") as? Data,
                let contentType = aDecoder.decodeObject(forKey: "contentType") as? String
        else {
            self.filename = ""
            self.contentType = ""
            self.originalLocation = nil
            self.data = Data()
            super.init()
            return nil
        }
        self.filename = filename
        self.data = assetData
        self.contentType = contentType
        self.originalLocation = aDecoder.decodeObject(forKey: "originalLocation") as? String
        super.init()
    }

    /**
     NSCoding protocol encoder.

     - parameter aCoder: The encoder.
     */
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(self.filename, forKey: "filename")
        aCoder.encode(self.data, forKey: "data")
        aCoder.encode(self.contentType, forKey: "contentType")
        aCoder.encode(self.originalLocation, forKey: "originalLocation")
    }

    private static func MIMEType(_ fileURL: URL) -> String? {
        let pathExtension = fileURL.pathExtension
        if !pathExtension.isEmpty {
            if let UTIRef = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension as CFString, nil) {
                let UTI = UTIRef.takeUnretainedValue()
                UTIRef.release()
                if let MIMETypeRef = UTTypeCopyPreferredTagWithClass(UTI, kUTTagClassMIMEType) {
                    let MIMEType = MIMETypeRef.takeUnretainedValue()
                    MIMETypeRef.release()
                    return MIMEType as String
                }
            }
        }
        return nil
    }
}
