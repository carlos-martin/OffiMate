//
//  SignUpViewCell.swift
//  SingleSignUp
//
//  Created by Carlos Martin on 22/08/17.
//  Copyright © 2017 Carlos Martin. All rights reserved.
//

import UIKit

class NameSignUpViewCell : UITableViewCell {
    @IBOutlet var nameTextField: UITextField!
}

class EmailSignUpViewCell : UITableViewCell {
    @IBOutlet var emailTextField: UITextField!
}

class OfficeViewCell : UITableViewCell {
    @IBOutlet var officeNameLabel: UILabel!
}

class PasswordSignUpViewCell : UITableViewCell {
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var showHideButton: UIButton!
}
