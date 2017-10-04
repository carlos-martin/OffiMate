//
//  Channel.swift
//  SingleSignUp
//
//  Created by Carlos Martin on 02/10/2017.
//  Copyright © 2017 Carlos Martin. All rights reserved.
//

internal class Channel: CustomStringConvertible {
    internal let id:        String
    internal let name:      String
    internal let creator:   String
    
    public var description: String {
        return "Channel:\n├── id:      \(self.id)\n├── name:    \(self.name)\n└── creator: \(self.creator)\n"
    }
    
    init(id: String, name: String, creator: String) {
        self.id = id
        self.name = name
        self.creator = creator
    }
}
