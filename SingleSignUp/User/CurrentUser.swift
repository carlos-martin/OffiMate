//
//  CurrentUser.swift
//  SingleSignUp
//
//  Created by Carlos Martin on 21/08/17.
//  Copyright © 2017 Carlos Martin. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth

class CurrentUser {
    static private(set) var name:       String!
    static private(set) var email:      String!
    static private(set) var password:   String!
    static private(set) var coworkerId: String!
    
    static var date: NewDate = NewDate(date: Date())
    //FirebaseAuth user
    static var user: User!
    
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
    
    static func localSave() throws {
        if self.name != nil && self.email != nil && self.password != nil && self.coworkerId != nil {
            UserDefaults.standard.set(self.name,       forKey: "name")
            UserDefaults.standard.set(self.email,      forKey: "email")
            UserDefaults.standard.set(self.password,   forKey: "password")
            UserDefaults.standard.set(self.coworkerId, forKey: "coworkerId")
        } else {
            throw NSError(domain: "Some of the internal variables are nil", code: 0, userInfo: nil)
        }
    }
    
    static func localClean() {
        self.name = nil
        self.email = nil
        self.password = nil
        self.coworkerId = nil
        UserDefaults.standard.removeObject(forKey: "name")
        UserDefaults.standard.removeObject(forKey: "email")
        UserDefaults.standard.removeObject(forKey: "password")
        UserDefaults.standard.removeObject(forKey: "coworkerId")
    }
    
    static func setName(name: String) throws {
        if !name.isEmpty {
            self.name = name
        } else {
            throw NSError(domain: "Not valid name", code: 0, userInfo: nil)
        }
    }
    
    static func setEmail(email: String) throws {
        if Tools.validateEmail(email: email) {
            self.email = email
        } else {
            throw NSError(domain: "Not valid email", code: 0, userInfo: nil)
        }
    }
    
    static func setPassword(password: String) throws {
        if Tools.validatePassword(pass: password) {
            self.password = password
        } else {
            throw NSError(domain: "Not valid password", code: 0, userInfo: nil)
        }
    }
    
    static func setCoworkerId(coworkerId: String) throws {
        if !coworkerId.isEmpty {
            self.coworkerId = coworkerId
        } else {
            throw NSError(domain: "Not valid name", code: 0, userInfo: nil)
        }
    }
    
    static func setData(name: String, email: String, password: String, coworkerId: String) throws {
        do {
            try self.setName(name: name)
            try self.setEmail(email: email)
            try self.setPassword(password: password)
            try self.setCoworkerId(coworkerId: coworkerId)
        } catch {
            throw NSError(domain: "Not valid input data", code: 0, userInfo: nil)
        }
    }
    
    //MARK:- Firebase
 
    static func tryToLogin (completion: @escaping (_ isLogin: Bool, _ error: Error?) -> Void) {
        if self.email != nil && self.password != nil {
            Auth.auth().signIn(withEmail: self.email!, password: self.password!, completion: { (user: User?, error: Error?) in
                if error == nil {
                    self.user = user
                    
                    Tools.fetchCoworker(uid: user!.uid, completion: { (_, name: String?, coworkerId: String?) in
                        self.name = (name != nil ? name! : "#tryToLogin#")
                        self.coworkerId = coworkerId!
                        completion(true, nil)
                    })
                } else {
                    completion(false, error)
                }
            })
        } else {
            let error: NSError = NSError(
                domain:     "CurrentUser empty",
                code:       0,
                userInfo:   ["NSLocalizedDescription" : "CurrentUser static class has no data stored"])
            
            completion(false, error)
        }
    }
    
    //MARK:- Private local function
    
    private static func localFetch() -> Bool {
        if let name = UserDefaults.standard.string(forKey: "name"),
            let email = UserDefaults.standard.string(forKey: "email"),
            let password = UserDefaults.standard.string(forKey: "password"),
            let coworkerId = UserDefaults.standard.string(forKey: "coworkerId"){
            self.name = name
            self.email = email
            self.password = password
            self.coworkerId = coworkerId
            return true
        } else {
            return false
        }
    }
    
    private static func alreadyFetched() -> Bool {
        return self.name != nil && self.email != nil && self.password != nil && self.coworkerId != nil
    }
}
