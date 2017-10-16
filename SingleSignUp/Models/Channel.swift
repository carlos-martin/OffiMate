//
//  Channel.swift
//  SingleSignUp
//
//  Created by Carlos Martin on 02/10/2017.
//  Copyright © 2017 Carlos Martin. All rights reserved.
//

internal func == (left: Channel, rigth: Channel) -> Bool {
    return left.id == rigth.id
}

internal func > (left: Channel, rigth: Channel) -> Bool {
    return left.id > rigth.id
}

internal func < (left: Channel, rigth: Channel) -> Bool {
    return left.id < rigth.id
}

internal func >= (left: Channel, rigth: Channel) -> Bool {
    return left.id >= rigth.id
}

internal func <= (left: Channel, rigth: Channel) -> Bool {
    return left.id <= rigth.id
}

internal class Channel: CustomStringConvertible, Hashable {
    internal let id:        String
    internal let name:      String
    internal let creator:   String
    public   var messages:  [Message]
    public   var hashValue:  Int
    
    public var description: String {
        //        return "Channel:\n" +
        //            "├── id:      \(self.id)\n" +
        //            "├── name:    \(self.name)\n" +
        //            "├── creator: \(self.creator)\n" +
        //            "└── Message: \n{\(self.messages)}"
        return "Channel:\n" +
            "├── id:      \(self.id)\n" +
            "├── name:    \(self.name)\n" +
            "├── creator: \(self.creator)\n" +
            "└── num:     \(self.messages.count)"
    }
    
    init(id: String, name: String, creator: String, messages: Dictionary<String, AnyObject>?=nil) {
        self.hashValue = id.hashValue
        self.id = id
        self.name = name
        self.creator = creator
        if let rawMessages = messages {
            var _messages: [Message] = []
            for rawMessage in rawMessages {
                let id = rawMessage.key
                let raw = rawMessage.value as! Dictionary<String, Any>
                let message = Message(id:       id,
                                      senderId: raw["uid"] as! String,
                                      text:     raw["text"] as! String,
                                      date:     raw["date"] as! Int64)
                _messages.append(message)
            }
            self.messages = _messages
        } else {
            self.messages = []
        }
    }
    
    func getUnread (from: Int64) -> Int {
        var counter = 0
        for message in self.messages {
            if message.date > from {
                counter += 1
            }
        }
        
        return counter
        
    }
}

internal class Message: CustomStringConvertible {
    internal let id:        String
    internal let senderId:  String
    internal let text:      String
    internal let date:      Int64
    public var description: String {
        let _txt = (self.text.characters.count <= 30 ? self.text : String(self.text.characters.prefix(25))+"[...]")
        return "Message:\n" +
            "   ├── id:        \(self.id)\n" +
            "   ├── senderId:  \(self.senderId)\n" +
            "   ├── date:      \(self.date)\n" +
            "   └── text:      \(_txt)\n"
    }
    
    init(id: String, senderId: String, text: String, date: Int64) {
        self.id = id
        self.senderId = senderId
        self.text = text
        self.date = date
    }
}
