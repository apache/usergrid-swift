//
//  MessageViewController.swift
//  ActivityFeed
//
//  Created by Robert Walsh on 1/21/16.
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
import UsergridSDK
import SlackTextViewController
import WatchConnectivity

class MessageViewController : SLKTextViewController {

    static let MESSAGE_CELL_IDENTIFIER = "MessengerCell"

    private var messageEntities: [ActivityEntity] = []

    init() {
        super.init(tableViewStyle:.plain)
        commonInit()
    }

    required init(coder decoder: NSCoder) {
        super.init(coder: decoder)
        commonInit()
    }

    override static func tableViewStyle(for decoder: NSCoder) -> UITableViewStyle {
        return .plain
    }

    override func viewWillAppear(_ animated: Bool) {
        self.reloadMessages()
        if let username = Usergrid.currentUser?.name {
            self.navigationItem.title = "\(username)'s Feed"
        }
        super.viewWillAppear(animated)
    }

    func commonInit() {
        self.bounces = true
        self.shakeToClearEnabled = true
        self.isKeyboardPanningEnabled = true
        self.shouldScrollToBottomAfterKeyboardShows = true
        self.isInverted = true

        self.registerClass(forTextView:MessageTextView.classForCoder())
        self.activateWCSession()
    }

    func reloadMessages() {
        UsergridManager.getFeedMessages { (response) -> Void in
            self.messageEntities = response.entities as? [ActivityEntity] ?? []
            self.tableView!.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.rightButton.setTitle("Send", for: [])

        self.textInputbar.autoHideRightButton = true
        self.textInputbar.maxCharCount = 256
        self.textInputbar.editorTitle.textColor = UIColor.darkGray

        self.tableView!.separatorStyle = .none
        self.tableView!.register(MessageTableViewCell.self, forCellReuseIdentifier:MessageViewController.MESSAGE_CELL_IDENTIFIER)
    }

    override func didPressRightButton(_ sender: Any!) {
        self.textView.refreshFirstResponder()

        UsergridManager.postFeedMessage(self.textView.text) { (response) -> Void in
            if let messageEntity = response.entity as? ActivityEntity {
                let indexPath = NSIndexPath.init(row: 0, section: 0)
                let rowAnimation: UITableViewRowAnimation = self.isInverted ? .bottom : .top
                let scrollPosition: UITableViewScrollPosition = self.isInverted ? .bottom : .top

                self.tableView!.beginUpdates()
                self.messageEntities.insert(messageEntity, at: 0)
                self.tableView!.insertRows(at: [indexPath as IndexPath], with: rowAnimation)
                self.tableView!.endUpdates()

                self.tableView!.scrollToRow(at: indexPath as IndexPath, at: scrollPosition, animated: true)
                self.tableView!.reloadRows(at: [indexPath as IndexPath], with: .automatic)

                self.sendEntitiesToWatch(self.messageEntities)
            }
        }
        super.didPressRightButton(sender)
    }

    override func keyForTextCaching() -> String? {
        return Bundle.main.bundleIdentifier
    }


    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messageEntities.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return self.messageCellForRowAtIndexPath(indexPath)
    }

    @IBAction func unwindToChat(_ segue: UIStoryboardSegue) {

    }

    func populateCell(_ cell:MessageTableViewCell,feedEntity:ActivityEntity) {

        cell.titleLabel.text = feedEntity.displayName
        cell.bodyLabel.text = feedEntity.content
        cell.thumbnailView.image = nil

        if let imageURLString = feedEntity.imageURL, let imageURL = URL(string: imageURLString) {
            URLSession.shared.dataTask(with: imageURL) { (data, response, error) in
                if let imageData = data, let image = UIImage(data: imageData) {
                    DispatchQueue.main.async(execute: { () -> Void in
                        cell.thumbnailView.image = image
                    })
                }
            }.resume()
        }
    }

    func messageCellForRowAtIndexPath(_ indexPath:IndexPath) -> MessageTableViewCell {
        let cell = self.tableView!.dequeueReusableCell(withIdentifier: MessageViewController.MESSAGE_CELL_IDENTIFIER) as! MessageTableViewCell
        self.populateCell(cell, feedEntity: self.messageEntities[indexPath.row])

        cell.indexPath = indexPath
        cell.transform = self.tableView!.transform

        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        let feedEntity = messageEntities[(indexPath as NSIndexPath).row]

        guard let messageText = feedEntity.content, !messageText.isEmpty
        else {
                return 0
        }

        let messageUsername : NSString = (feedEntity.displayName ?? "") as NSString

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byWordWrapping
        paragraphStyle.alignment = .left

        let pointSize = MessageTableViewCell.defaultFontSize
        let attributes = [NSFontAttributeName:UIFont.boldSystemFont(ofSize: pointSize),NSParagraphStyleAttributeName:paragraphStyle]

        let width: CGFloat = self.tableView!.frame.width - MessageTableViewCell.kMessageTableViewCellAvatarHeight - 25

        let titleBounds = messageUsername.boundingRect(with: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
        let bodyBounds = messageText.boundingRect(with: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: attributes, context: nil)

        var height = titleBounds.height + bodyBounds.height + 40
        if height < MessageTableViewCell.kMessageTableViewCellMinimumHeight {
            height = MessageTableViewCell.kMessageTableViewCellMinimumHeight
        }

        return height
    }
}

extension MessageViewController : WCSessionDelegate {

    func activateWCSession() {
        if (WCSession.isSupported()) {
            let session = WCSession.default()
            session.delegate = self
            session.activate()
        }
    }

    @available(iOS 9.3, *)
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {

    }

    func sessionDidBecomeInactive(_ session: WCSession) {

    }

    func sessionDidDeactivate(_ session: WCSession) {

    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Swift.Void) {
        if let action = message["action"] as? String, action == "getMessages" {
            UsergridManager.getFeedMessages { (response) -> Void in
                if let entities = response.entities {
                    self.sendEntitiesToWatch(entities)
                }
            }
        }
    }

    func sendEntitiesToWatch(_ messages:[UsergridEntity]) {
        if WCSession.default().isReachable {
            NSKeyedArchiver.setClassName("ActivityEntity", for: ActivityEntity.self)
            let data = NSKeyedArchiver.archivedData(withRootObject: messages)
            WCSession.default().sendMessageData(data, replyHandler: nil, errorHandler: { (error) -> Void in
                self.showAlert("WCSession Unreachable.", message: "\(error)")
            })
        }
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if let action = message["action"] as? String, action == "getMessages" {
            UsergridManager.getFeedMessages { (response) -> Void in
                if let entities = response.entities {
                    self.sendEntitiesToWatch(entities)
                }
            }
        }
    }

}

