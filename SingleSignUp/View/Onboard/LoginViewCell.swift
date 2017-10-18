//
//  LoginViewCell.swift
//  SingleSignUp
//
//  Created by Carlos Martin on 22/08/17.
//  Copyright © 2017 Carlos Martin. All rights reserved.
//

import UIKit

class EmailLoginViewCell : UITableViewCell {
    @IBOutlet var emailTextField: UITextField!
}

class PasswordLoginViewCell : UITableViewCell {
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var showHideButton: UIButton!
}

class ForgetPasswordViewCell : UITableViewCell {
    @IBOutlet var emailTextField: UITextField!
}
