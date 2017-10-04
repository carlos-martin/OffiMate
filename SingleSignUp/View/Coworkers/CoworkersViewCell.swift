//
//  CoworkersViewCell.swift
//  SingleSignUp
//
//  Created by Carlos Martin on 02/10/2017.
//  Copyright © 2017 Carlos Martin. All rights reserved.
//

import UIKit

class CoworkersViewCell : UITableViewCell {
    @IBOutlet weak var coworkerLabel: UILabel!
}

class CoworkerProfileViewCell : UITableViewCell {
    @IBOutlet weak var coworkerPictureProfile:  UIImageView!
    @IBOutlet weak var coworkerNameLabel:       UILabel!
    @IBOutlet weak var coworkerEmailLabel:      UILabel!
}

class CoworkerOptionViewCell : UITableViewCell {
    @IBOutlet weak var iconImage:   UIImageView!
    @IBOutlet weak var arrowImage:  UIImageView!
    @IBOutlet weak var actionLaben: UILabel!
}
