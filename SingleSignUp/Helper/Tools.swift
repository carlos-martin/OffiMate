//
//  Tools.swift
//  SingleSignUp
//
//  Created by Carlos Martin on 23/08/17.
//  Copyright © 2017 Carlos Martin. All rights reserved.
//

import Foundation
import UIKit
import Firebase

public class Tools {
    //place to create internal variables
    static let separator: UIColor = UIColor(
        colorLiteralRed: 211.0/255.0,
        green:           211.0/255.0,
        blue:            211.0/255.0,
        alpha:           1.0)
    static let blueSystem: UIColor = UIColor(
        colorLiteralRed: 0.0,
        green:           122.0/255.0,
        blue:            255.0/255.0,
        alpha:           1.0)
    static let redPassion: UIColor = UIColor(
        colorLiteralRed: 245.0/255.0,
        green:            64.0/255.0,
        blue:             73.0/255.0,
        alpha:           1.0)
    static let greenExecution: UIColor = UIColor(
        colorLiteralRed: 114.0/255.0,
        green:           214.0/255.0,
        blue:            227.0/255.0,
        alpha:           1.0)
    static let blueInbox: UIColor = UIColor(
        colorLiteralRed:  74.0/255.0,
        green:           144.0/255.0,
        blue:            226.0/255.0,
        alpha:           1.0)
    static let redLogout: UIColor = UIColor(
        colorLiteralRed: 208.0/255.0,
        green:             2.0/255.0,
        blue:             27.0/255.0,
        alpha:           1.0)
    static let grayTextField: UIColor = UIColor(
        colorLiteralRed: 238.0/255.0,
        green:           238.0/255.0,
        blue:            238.0/255.0,
        alpha:           1.0)
    static let backgrounsColors: [UIColor] = [
        UIColor(colorLiteralRed:  74.0/255.0, green: 143.0/255.0, blue: 138.0/255.0, alpha: 1.0),
        UIColor(colorLiteralRed: 115.0/255.0, green: 175.0/255.0, blue: 173.0/255.0, alpha: 1.0),
        UIColor(colorLiteralRed: 217.0/255.0, green: 133.0/255.0, blue:  59.0/255.0, alpha: 1.0),
        UIColor(colorLiteralRed: 236.0/255.0, green: 236.0/255.0, blue: 234.0/255.0, alpha: 1.0)
    ]
    
    static let bubbleColors: [UIColor] = [
        UIColor(colorLiteralRed:   0.0/255.0, green: 165.0/255.0, blue: 133.0/255.0, alpha: 1.0),
        UIColor(colorLiteralRed:   0.0/255.0, green: 183.0/255.0, blue:  89.0/255.0, alpha: 1.0),
        UIColor(colorLiteralRed:  23.0/255.0, green: 124.0/255.0, blue: 188.0/255.0, alpha: 1.0),
        UIColor(colorLiteralRed: 152.0/255.0, green:  34.0/255.0, blue: 178.0/255.0, alpha: 1.0),
        UIColor(colorLiteralRed:  20.0/255.0, green:  83.0/255.0, blue:  87.0/255.0, alpha: 1.0),
        UIColor(colorLiteralRed: 240.0/255.0, green: 119.0/255.0, blue:   0.0/255.0, alpha: 1.0),
        UIColor(colorLiteralRed: 203.0/255.0, green:  27.0/255.0, blue:  37.0/255.0, alpha: 1.0),
        UIColor(colorLiteralRed: 101.0/255.0, green:  77.0/255.0, blue: 179.0/255.0, alpha: 1.0)
    ]
    
    static let bubbleColorsLight: [UIColor] = [
        UIColor(colorLiteralRed: 218.0/255.0, green: 241.0/255.0, blue: 220.0/255.0, alpha: 1.0),
        UIColor(colorLiteralRed: 210.0/255.0, green: 237.0/255.0, blue: 199.0/255.0, alpha: 1.0),
        UIColor(colorLiteralRed: 184.0/255.0, green: 229.0/255.0, blue: 199.0/255.0, alpha: 1.0),
        UIColor(colorLiteralRed: 178.0/255.0, green: 227.0/255.0, blue: 187.0/255.0, alpha: 1.0),
        UIColor(colorLiteralRed: 102.0/255.0, green: 206.0/255.0, blue: 173.0/255.0, alpha: 1.0),
        UIColor(colorLiteralRed: 171.0/255.0, green: 208.0/255.0, blue: 205.0/255.0, alpha: 1.0),
        UIColor(colorLiteralRed: 160.0/255.0, green: 236.0/255.0, blue: 220.0/255.0, alpha: 1.0),
        UIColor(colorLiteralRed: 169.0/255.0, green: 243.0/255.0, blue: 203.0/255.0, alpha: 1.0),
        UIColor(colorLiteralRed: 179.0/255.0, green: 219.0/255.0, blue: 245.0/255.0, alpha: 1.0),
        UIColor(colorLiteralRed: 163.0/255.0, green: 225.0/255.0, blue: 213.0/255.0, alpha: 1.0),
        UIColor(colorLiteralRed: 176.0/255.0, green: 211.0/255.0, blue: 234.0/255.0, alpha: 1.0),
        UIColor(colorLiteralRed: 169.0/255.0, green: 233.0/255.0, blue: 197.0/255.0, alpha: 1.0)
    ]
    
    static var channelRef = Database.database().reference().child("channels")
    static var channelsHandle:  DatabaseHandle?
}

//MARK:- BackEnd 
extension Tools {
    //MARK: Coworker
    static func createCoworker(uid: String, email: String, name: String) -> String {
        let coworkerRef = Database.database().reference().child("coworkers")
        let newCoworkerRef = coworkerRef.childByAutoId()
        let newCoworkerItem = [
            "userId":   uid,
            "name":     name,
            "email":    email
        ]
        newCoworkerRef.setValue(newCoworkerItem)
        return newCoworkerRef.key
    }
    
    static func fetchCoworker (uid: String, completion: @escaping (_ email: String?, _ name: String?, _ id: String?) -> Void) {
        let coworkerRef = Database.database().reference().child("coworkers")
        let coworkerHandle = coworkerRef.queryOrdered(byChild: "userId").queryEqual(toValue: uid)
        coworkerHandle.observe(.value) { (snapshot: DataSnapshot) in
            let rawData = snapshot.value as! Dictionary<String, AnyObject>
            
            if let coworkerID = rawData.keys.first {
                let id = coworkerID
                let coworkerData = rawData[coworkerID] as! Dictionary<String, String>
                
                if let name = coworkerData["name"], let email = coworkerData["email"] {
                    completion(email, name, id)
                } else {
                    completion(nil, nil, nil)
                }
            } else {
                completion(nil, nil, nil)
            }
        }
    }
    
    //MARK: BoostCard
    static func createBoostCard(boostCard: BoostCard) {
        let boostcardRef = Database.database().reference().child("boostcard")
        let newBoostcardRef = boostcardRef.childByAutoId()
        let newBoostcardItem = [
            "senderId":     boostCard.senderId,
            "receiverId":   boostCard.receiverId,
            "type":         String(describing: boostCard.type),
            "header":       boostCard.header,
            "message":      boostCard.message,
            "date":         boostCard.date.id,
            "unread":       true
        ] as [String : Any]
        newBoostcardRef.setValue(newBoostcardItem)
    }
    
    static func unreadBoostCard(uid: String, completion: @escaping(_ unreads: Bool) -> Void) {
        let coworkerRef = Database.database().reference().child("boostcard")
        let coworkerHandle = coworkerRef.queryOrdered(byChild: "receiverId").queryEqual(toValue: uid)
        coworkerHandle.observe(.value) { (snapshot: DataSnapshot) in
            var counter = 0
            if let rawData = snapshot.value as? Dictionary<String, AnyObject> {
                for entry in rawData {
                    if (entry.value["unread"] as! Bool) {
                        counter += 1
                        break
                    }
                }
            }
            completion((counter > 0 ? true : false))
        }
    }
    
    //MARK: Channels
    
    static func initChannelsList (completion: @escaping() -> Void) {
        self.channelsHandle = self.channelRef.observe(.value) { (snapshot: DataSnapshot) in
            if let rawChannels = snapshot.value as? Dictionary<String, AnyObject> {
                if rawChannels.count == CurrentUser.channelsLastAccess.count {
                    var channels: [Channel] = [] {
                        didSet { channels.sort { $0.0.id < $0.1.id } }
                    }
                    for rawChannel in rawChannels {
                        let id = rawChannel.key
                        if let channelData = rawChannel.value as? Dictionary<String, AnyObject> {
                            if let name = channelData["name"] as! String!, let creator = channelData["creator"] as! String! {
                                if let messages = channelData["messages"] as! Dictionary<String, AnyObject>! {
                                    channels.append(Channel(id: id, name: name, creator: creator, messages: messages))
                                } else {
                                    channels.append(Channel(id: id, name: name, creator: creator))
                                }
                            }
                        }
                    }
                    if channels.count == CurrentUser.channelsLastAccess.count {
                        CurrentUser.initChannel(channels: channels)
                    }
                }
            }
            completion()
        }
    }
    
    static func removeChannelObserver () {
        if let refChannelHandle = self.channelsHandle {
            self.channelRef.removeObserver(withHandle: refChannelHandle)
        }
    }
    
    
    //MARK: Chat
    static func createChannelMessage(uid: String, text: String, date: NewDate) {
        let messageRef = Database.database().reference().child("messages")
        let newMessageRef = messageRef.childByAutoId()
        let newMessageItem = [
            "uid":  uid,
            "text": text,
            "date": date.id
        ] as [String : Any]
        newMessageRef.setValue(newMessageItem)
    }
}

//MARK:- Storyboard navigation
extension Tools {
    //.coverVertical .flipHorizontal .crossDissolve
    static func goToMain (vc: UIViewController) {
        if let controller = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController() {
            controller.modalPresentationStyle = .fullScreen
            controller.modalTransitionStyle = .flipHorizontal
            vc.present(controller, animated: true, completion: nil)
        }
    }
    
    static func goToOnboard (vc: UIViewController) {
        if let controller = UIStoryboard(name: "Onboard", bundle: nil).instantiateInitialViewController() {
            controller.modalPresentationStyle = .fullScreen
            controller.modalTransitionStyle = .flipHorizontal
            vc.present(controller, animated: true, completion: nil)
        }
    }
    
    static func goToProfile (vc: UIViewController) {
        if let controller = UIStoryboard(name: "Profile", bundle: nil).instantiateInitialViewController() {
            controller.modalPresentationStyle = .fullScreen
            controller.modalTransitionStyle = .flipHorizontal
            vc.present(controller, animated: true, completion: nil)
        }
    }
    
    static func goToCoworkers (vc: UIViewController) {
        if let controller = UIStoryboard(name: "Coworkers", bundle: nil).instantiateInitialViewController() {
            controller.modalPresentationStyle = .fullScreen
            controller.modalTransitionStyle = .flipHorizontal
            vc.present(controller, animated: true, completion: nil)
        }
    }
    
    static func goToWaitingRoom (vc: UIViewController) {
        if let controller = UIStoryboard(name: "Loading", bundle: nil).instantiateInitialViewController() {
            controller.modalPresentationStyle = .fullScreen
            controller.modalTransitionStyle = .crossDissolve
            vc.present(controller, animated: true, completion: nil)
        }
    }
}

//MARK:- Validations
extension Tools {
    static func validateEmail (email: UITextField) -> Bool {
        if let _email = email.text {
            return self.validateEmail(email: _email)
        } else {
            return false
        }
    }
    
    static func validateEmail (email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
    
    static func validateURL (url: String) -> Bool {
        let successful: Bool
        if let url = NSURL(string: url) {
            successful = UIApplication.shared.canOpenURL(url as URL)
        } else {
            successful = false
        }
        return successful
    }
    
    static func validatePassword (pass: UITextField) -> Bool {
        if let _pass = pass.text {
            return self.validatePassword(pass: _pass)
        } else {
            return false
        }
    }
    
    static func validatePassword (pass: String) -> Bool {
        let passRegEx = "^(?=.*[a-z])(?=.*[$@$#!%*?&])[A-Za-z\\d$@$#!%*?&]{8,}"
        let passTest = NSPredicate(format:"SELF MATCHES %@", passRegEx)
        return passTest.evaluate(with: pass)
    }
}

//MARK:- Error View Animation
extension Tools {
    static func textFieldErrorAnimation (textField: UITextField) {
        textField.backgroundColor = UIColor.red
        UIView.animate(withDuration: 1, animations: {
            textField.alpha = 0.0
        }, completion: { (finished: Bool) in
            textField.backgroundColor = UIColor.white
            textField.alpha = 1
        })
    }
    
    static func cellViewErrorAnimation (cell: UITableViewCell) {
        let view = cell.contentView
        view.backgroundColor = UIColor.red
        UIView.animate(withDuration: 1, animations: {
            view.alpha = 0.0
        }) { (finished: Bool) in
            view.backgroundColor = UIColor.white
            view.alpha = 1
        }
    }
    
}

//MARK:- Others
extension Tools {
    static func iOS () -> Int {
        guard let version = Int(UIDevice.current.systemVersion.components(separatedBy: ".").first!) else {
            return 0
        }
        return version
    }
    
    static func randomString(length: Int?=12) -> String {
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        var randomString = ""
        for _ in 0 ..< length! {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        return randomString
    }
    
    static func randomColor() -> UIColor {
        let rand = Int(arc4random_uniform(UInt32(self.backgrounsColors.count)))
        return self.backgrounsColors[rand]
    }
    
    static func getColor(id: String) -> UIColor {
        let _tmp_ = String(id.hashValue).characters.suffix(2)
        let value = Int(String(_tmp_.first!))! + Int(String(_tmp_.last!))!
        let index: Int
        if value < self.bubbleColors.count {
            index = value
        } else {
            index = value % self.bubbleColors.count
        }
        return self.bubbleColors[index]
    }
}
