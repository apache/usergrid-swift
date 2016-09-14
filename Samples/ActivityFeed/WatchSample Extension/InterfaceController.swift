//
//  InterfaceController.swift
//  WatchSample Extension
//
//  Created by Robert Walsh on 1/19/16.
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

import WatchKit
import Foundation
import UsergridSDK
import WatchConnectivity

class InterfaceController: WKInterfaceController,WCSessionDelegate {

    @IBOutlet var messageTable: WKInterfaceTable!
    var messageEntities: [ActivityEntity] = []

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        if WCSession.isSupported() {
            let session = WCSession.default()
            session.delegate = self
            session.activate()
        }
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {

    }

    override func willActivate() {
        self.reloadTable()
        if WCSession.default().isReachable {
            WCSession.default().sendMessage(["action":"getMessages"], replyHandler: nil) { (error) -> Void in
                print(error)
            }
        }
        super.willActivate()
    }

    func reloadTable() {
        self.messageTable.setNumberOfRows(messageEntities.count, withRowType: "MessageRow")
        for index in 0..<self.messageTable.numberOfRows {
            if let controller = self.messageTable.rowController(at: index) as? MessageRowController {
                let messageEntity = messageEntities[index]
                controller.titleLabel.setText(messageEntity.displayName)
                controller.messageLabel.setText(messageEntity.content)
            }
        }
    }

    func session(_ session: WCSession, didReceiveMessageData messageData: Data) {
        NSKeyedUnarchiver.setClass(ActivityEntity.self, forClassName: "ActivityEntity")
        if let messageEntities = NSKeyedUnarchiver.unarchiveObject(with: messageData) as? [ActivityEntity] {
            self.messageEntities = messageEntities
            self.reloadTable()
        }
    }
}

class MessageRowController: NSObject {

    @IBOutlet var titleLabel: WKInterfaceLabel!
    @IBOutlet var messageLabel: WKInterfaceLabel!
    
}
