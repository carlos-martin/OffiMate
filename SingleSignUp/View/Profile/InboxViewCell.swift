//
//  InboxViewCell.swift
//  SingleSignUp
//
//  Created by Carlos Martin on 05/10/2017.
//  Copyright © 2017 Carlos Martin. All rights reserved.
//

import UIKit

class InboxViewCell: UITableViewCell {
    @IBOutlet weak var dateLabel:     UILabel!
    @IBOutlet weak var senderLabel:   UILabel!
    @IBOutlet weak var headerLabel:   UILabel!
    @IBOutlet weak var messangeLabel: UILabel!
    @IBOutlet weak var readedImage:   UIImageView!
}

class BoostCardHeaderViewCell: UITableViewCell {
    @IBOutlet weak var iconView:      UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var headerLabel:   UILabel!
    @IBOutlet weak var fromLabel:     UILabel!
    @IBOutlet weak var senderButton:  UIButton!
}

class BoostCardTitleViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel:  UILabel!
    @IBOutlet weak var dateLabel:   UILabel!
}

class BoostCardBodyViewCell: UITableViewCell {
    @IBOutlet weak var messageLabel: UILabel!
}
