//
//  CurrentUser.swift
//  SingleSignUp
//
//  Created by Carlos Martin on 21/08/17.
//  Copyright © 2017 Carlos Martin. All rights reserved.
//

import Foundation
import UIKit
import AWSCore
import AWSCognito

class CurrentUser {
    static              var cognitoId:  String!
    static private(set) var name:       String!
    static private(set) var email:      String!
    static private(set) var password:   String!
    
    //MARK:- Public funtion
    static func isInit() -> Bool {
        if self.alreadyFetched() {
            return true
        } else if localFetch() {
            return true
        } else {
            return false
        }
    }
    
    static func localSave() -> Bool {
        if Tools.validatePassword(pass: self.password) && Tools.validateEmail(email: self.email) && !self.name.isEmpty {
            UserDefaults.standard.set(self.name,     forKey: "name")
            UserDefaults.standard.set(self.email,    forKey: "email")
            UserDefaults.standard.set(self.password, forKey: "password")
            return true
        } else {
            return false
        }
    }
    
    static func localClean() {
        self.name = nil
        self.email = nil
        self.password = nil
        UserDefaults.standard.removeObject(forKey: "name")
        UserDefaults.standard.removeObject(forKey: "email")
        UserDefaults.standard.removeObject(forKey: "password")
    }
    
    static func setName(name: String) -> Bool {
        if !name.isEmpty {
            self.name = name
            return true
        } else {
            return false
        }
        
    }
    
    static func setEmail(email: String) -> Bool {
        if Tools.validateEmail(email: email) {
            self.email = email
            return true
        } else {
            return false
        }
    }
    
    static func setPassword(password: String) -> Bool {
        if Tools.validatePassword(pass: password) {
            self.password = password
            return true
        } else {
            return false
        }
    }
    
    //MARK:- Private local function
    private static func localFetch() -> Bool {
        if let name = UserDefaults.standard.string(forKey: "name"),
            let email = UserDefaults.standard.string(forKey: "email"),
            let password = UserDefaults.standard.string(forKey: "password"){
            self.name = name
            self.email = email
            self.password = password
            return true
        } else {
            return false
        }
    }
    
    private static func alreadyFetched() -> Bool {
        return self.name != nil && self.email != nil && self.password != nil
    }
}
