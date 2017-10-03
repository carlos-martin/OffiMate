//
//  Coworker.swift
//  SingleSignUp
//
//  Created by Carlos Martin on 02/10/2017.
//  Copyright © 2017 Carlos Martin. All rights reserved.
//

internal class Coworker: CustomStringConvertible {
    internal let id:    String
    internal let uid:   String
    internal let email: String
    internal let name:  String
    
    public var description: String {
        return "Coworker:\n├── id:    \(self.id)\n├── uid:   \(self.uid)\n├── name:  \(self.name)\n└── email: \(self.email)\n"
    }
    
    init(id: String, uid: String, email: String, name: String) {
        self.id =    id
        self.uid =   uid
        self.email = email
        self.name =  name
    }
    
    
}
