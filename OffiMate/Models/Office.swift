//
//  Office.swift
//  SingleSignUp
//
//  Created by Carlos Martin on 23/10/2017.
//  Copyright © 2017 Carlos Martin. All rights reserved.
//

internal func == (left: Office, rigth: Office) -> Bool {
    return left.hashValue == rigth.hashValue
}

internal func > (left: Office, rigth: Office) -> Bool {
    return left.hashValue > rigth.hashValue
}

internal func < (left: Office, rigth: Office) -> Bool {
    return left.hashValue < rigth.hashValue
}

internal func >= (left: Office, rigth: Office) -> Bool {
    return left.hashValue >= rigth.hashValue
}

internal func <= (left: Office, rigth: Office) -> Bool {
    return left.hashValue <= rigth.hashValue
}

internal class Office: CustomStringConvertible, Hashable {
    internal let id:    String
    internal let name:  String
    public   var hashValue:   Int
    public   var description: String {
        return "Office:\n" +
            "├── id:   \(self.id)\n" +
            "└── name: \(self.name)\n"
    }
    
    init(id: String, name: String) {
        self.id = id
        self.name = name
        self.hashValue = id.hashValue
    }
}
