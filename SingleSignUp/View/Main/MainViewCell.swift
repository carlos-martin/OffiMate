//
//  MainViewCell.swift
//  SingleSignUp
//
//  Created by Carlos Martin on 14/09/17.
//  Copyright © 2017 Carlos Martin. All rights reserved.
//

import UIKit

class MainViewCell : UITableViewCell {
    @IBOutlet weak var labelRigthConstraint: NSLayoutConstraint!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var counter: UILabel!
}

class NewChannelViewCell : UITableViewCell {
    @IBOutlet weak var newChannelTextField: UITextField!
}
