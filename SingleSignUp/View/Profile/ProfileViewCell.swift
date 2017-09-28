//
//  ProfileViewCell.swift
//  SingleSignUp
//
//  Created by Carlos Martin on 29/08/17.
//  Copyright © 2017 Carlos Martin. All rights reserved.
//

import UIKit

class ProfileViewCell : UITableViewCell {
    @IBOutlet weak var profileLabel: UILabel!
}

class PasswordViewCell : UITableViewCell {
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var showHideButton: UIButton!
}

class InformationViewCell : UITableViewCell {
    @IBOutlet weak var textField: UITextField!
}
