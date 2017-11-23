//
//  ChatInfoViewCell.swift
//  OffiMate
//
//  Created by Carlos Martin on 23/11/2017.
//  Copyright © 2017 Carlos Martin. All rights reserved.
//

import UIKit

class ChatInfoViewCell: UITableViewCell {
    @IBOutlet weak var chatNameTextField: UITextField!
}

class ChatMembersViewCell: UITableViewCell {
    @IBOutlet weak var memberLabel: UILabel!
    @IBOutlet weak var adminLabel:  UILabel!
}
