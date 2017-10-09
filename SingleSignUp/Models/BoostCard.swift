//
//  BoostCard.swift
//  SingleSignUp
//
//  Created by Carlos Martin on 04/10/2017.
//  Copyright © 2017 Carlos Martin. All rights reserved.
//

import UIKit

enum BoostCardType: Int {
    case passion = 0
    case execution
}

internal func == (left: BoostCard, rigth: BoostCard) -> Bool {
    return left.date == rigth.date
}

internal func > (left: BoostCard, rigth: BoostCard) -> Bool {
    return left.date > rigth.date
}

internal func < (left: BoostCard, rigth: BoostCard) -> Bool {
    return left.date < rigth.date
}

internal func >= (left: BoostCard, rigth: BoostCard) -> Bool {
    return left.date >= rigth.date
}

internal func <= (left: BoostCard, rigth: BoostCard) -> Bool {
    return left.date <= rigth.date
}

internal class BoostCard: CustomStringConvertible, Hashable {
    internal let id:         String
    internal let senderId:   String
    internal let receiverId: String
    internal let type:       BoostCardType
    internal let header:     String
    internal let message:    String
    internal let date:       NewDate
    public   var hashValue:  Int
    
    public var description: String {
        return "BoostCard:\n" +
            "├── date:        \(self.date)\n" +
            "├── id:          \(self.id)\n" +
            "├── senderId:    \(self.senderId)\n" +
            "├── receiverId:  \(self.receiverId)\n" +
            "├── type:        \(self.type)\n" +
            "├── header:      \(self.header)\n" +
            "└── message:     \(self.message)\n"
    }
    
    init(id: String?=nil, senderId: String, receiverId: String, type: BoostCardType, header: String, message: String, date: NewDate?=nil) {
        self.id =         id ?? "~unknown~"
        self.senderId =   senderId
        self.receiverId = receiverId
        self.type =       type
        self.header =     header
        self.message =    message
        self.date =       (date != nil ? date! : NewDate(date: Date()))
        self.hashValue =  self.date.hashValue
    }
}
