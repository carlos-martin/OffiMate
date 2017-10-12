//
//  ProfileViewCell.swift
//  SingleSignUp
//
//  Created by Carlos Martin on 29/08/17.
//  Copyright © 2017 Carlos Martin. All rights reserved.
//

import UIKit

class PasswordViewCell : UITableViewCell {
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var showHideButton: UIButton!
}

class InformationViewCell : UITableViewCell {
    @IBOutlet weak var textField: UITextField!
}

class EditViewCell : UITableViewCell {
    @IBOutlet weak var actionButton: UIButton!
}

class PictureViewCell : UITableViewCell {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var topView:       UIView!
    @IBOutlet weak var bottomView:    UIView!
    @IBOutlet weak var profileImage:  UIImageView!
}

class OptionsViewCell : UITableViewCell {
    @IBOutlet weak var optionImage: UIImageView!
    @IBOutlet weak var optionLabel: UILabel!
    @IBOutlet weak var arrowImage:  UIImageView!
    @IBOutlet weak var unreadImage: UIImageView!
}
