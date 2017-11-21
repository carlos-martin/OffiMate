//
//  ProfileViewCell.swift
//  SingleSignUp
//
//  Created by Carlos Martin on 29/08/17.
//  Copyright © 2017 Carlos Martin. All rights reserved.
//

import UIKit

class ProfileViewCell : UITableViewCell {
    @IBOutlet weak var profileImage:    UIImageView!
    @IBOutlet weak var nameTextField:   UITextField!
    @IBOutlet weak var emailLabel:      UILabel!
}

class PasswordViewCell : UITableViewCell {
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var showHideButton: UIButton!
}

class OptionsViewCell : UITableViewCell {
    @IBOutlet weak var optionImage: UIImageView!
    @IBOutlet weak var optionLabel: UILabel!
    @IBOutlet weak var arrowImage:  UIImageView!
    @IBOutlet weak var unreadImage: UIImageView!
}

class OfficePickerViewCell : UITableViewCell {
    @IBOutlet weak var officePickerView: UIPickerView!
}
