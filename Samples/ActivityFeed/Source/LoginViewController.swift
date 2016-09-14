//
//  LoginViewController.swift
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
import UIKit
import UsergridSDK

class LoginViewController: UIViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.passwordTextField.text = nil
    }

    override func viewDidAppear(_ animated: Bool) {
        Usergrid.logoutCurrentUser()
        super.viewDidAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.endEditing(true)
    }

    @IBAction func loginButtonTouched(_ sender: AnyObject) {
        guard let username = usernameTextField.text, !username.isEmpty,
              let password = passwordTextField.text, !password.isEmpty
        else {
            self.showAlert("Error Authenticating User", message: "Username and password must not be empty.")
            return;
        }

        self.loginUser(username, password: password)
    }

    func loginUser(_ username:String, password:String) {
        UsergridManager.loginUser(username,password: password) { (auth, user, error) -> Void in
            if let authErrorDescription = error {
                self.showAlert("Error Authenticating User", message: authErrorDescription.errorDescription)
            } else if let authenticatedUser = user {
                self.showAlert("Authenticated User Successful", message: "User description: \n \(authenticatedUser.stringValue)") { (action) -> Void in
                    self.performSegue(withIdentifier: "loginSuccessSegue", sender: self)
                }
            }
        }
    }

    @IBAction func unwind(_ segue: UIStoryboardSegue) {
        // Used for unwind segues back to this view controller.
    }
}
