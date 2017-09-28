//
//  ChatViewController.swift
//  SingleSignUp
//
//  Created by Carlos Martin on 14/09/17.
//  Copyright © 2017 Carlos Martin. All rights reserved.
//

import UIKit
import Firebase
import JSQMessagesViewController

class ChatViewController: JSQMessagesViewController {

    //Variable necessary for SplitViewController proper behavior
    var auto: Bool = true
    
    //Chat settings
    var channelRef: DatabaseReference?
    var channel: Channel? {
        didSet {
            self.title = channel?.name
        }
    }
    
    //User is typing
    private lazy var usersTypingQuery: DatabaseQuery =
        self.channelRef!.child("typingIndicator").queryOrderedByValue().queryEqual(toValue: true)
    private lazy var userIsTypingRef:  DatabaseReference =
        self.channelRef!.child("typingIndicator").child(self.senderId)
    private var localTyping = false
    var isTyping: Bool {
        get { return localTyping }
        set { localTyping = newValue; userIsTypingRef.setValue(newValue) }
    }
    var isValidating: Bool = false
    
    //Chat UI
    lazy var outgoingBubbleImageView: JSQMessagesBubbleImage = self.setupOutgoingBubble()
    lazy var incomingBubbleImageView: JSQMessagesBubbleImage = self.setupIncomingBubble()
    
    //Chat firebase
    private lazy var messageRef: DatabaseReference = self.channelRef!.child("messages")
    private var newMessageRefHandle: DatabaseHandle?
    
    var messages = [JSQMessage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.senderId = Auth.auth().currentUser?.uid
        self.senderDisplayName = CurrentUser.email!

        //Necessary for SplitViewController proper behavior
        if auto {
            self.inputToolbar.isHidden = true
            self.toMainViewController()
        } else {
            self.initUI()
            self.channelStillAlive({ (isAlive: Bool) in
                if isAlive {
                    self.observeMessage()
                } else {
                    Alert.showFailiureAlert(message: "This channel does not exists anymore!", handler: { (_) in
                        self.toMainViewController()
                    })
                }
            })
            
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !auto {
            self.observeTyping()
        }
    }
    
    private func initUI () {
        // No avatars
        self.collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        self.collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        self.inputToolbar.contentView.leftBarButtonItem = nil
        self.inputToolbar.contentView.textView.layer.cornerRadius = 12
        self.inputToolbar.contentView.textView.placeHolder = "Add new message..."
        if #available(iOS 11.0, *) {
            self.inputToolbar.contentView.textView.becomeFirstResponder()
        }
        self.scrollToBottom(animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //=======================================================================//
    //MARK:- Creating, Sending and fetcing Messages
    private func channelStillAlive (_ completion: @escaping (_ isAlive: Bool) -> Void) {
        let currentChannelsRef = Database.database().reference().child("channels")
        currentChannelsRef.observeSingleEvent(of: .value, with: { (snapshot: DataSnapshot) in
            if snapshot.hasChild(self.channel!.id) {
                completion(true)
            } else {
                completion(false)
            }
        })
    }
    
    private func addMessage(withId id: String, name: String, text: String) {
        if let message = JSQMessage(senderId: id, displayName: name, text: text) {
            self.messages.append(message)
        }
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        self.channelStillAlive { (isAlive: Bool) in
            if isAlive {
                let itemRef = self.messageRef.childByAutoId()
                let messageItem = [
                    "senderId":     self.senderId!,
                    "senderName":   self.senderDisplayName,
                    "text":         text!
                ]
                
                itemRef.setValue(messageItem)
                JSQSystemSoundPlayer.jsq_playMessageSentSound()
                self.finishSendingMessage()
                self.isTyping = false
            } else {
                Alert.showFailiureAlert(message: "This channel does not exists anymore!", handler: { (_) in
                    self.toMainViewController()
                })
            }
        }
    }
    
    private func observeMessage() {
        self.messageRef = self.channelRef!.child("messages")
        let messageQuery = messageRef.queryLimited(toLast: 25)
        self.newMessageRefHandle = messageQuery.observe(.childAdded, with: { (snapshot: DataSnapshot) in
            let messageData = snapshot.value as! Dictionary<String, String>
            if let id = messageData["senderId"] as String!, let name = messageData["senderName"] as String!, let text = messageData["text"] as String!, !text.isEmpty {
                self.addMessage(withId: id, name: name, text: text)
                self.finishReceivingMessage()
            }
        })
    }
    
    private func observeTyping() {
        let typingIndicatorRef = channelRef!.child("typingIndicator")
        self.userIsTypingRef = typingIndicatorRef.child(self.senderId)
        self.userIsTypingRef.onDisconnectRemoveValue()
        self.usersTypingQuery.observe(.value) { (data: DataSnapshot) in
            if data.childrenCount == 1 && self.isTyping {
                return
            }
            self.showTypingIndicator = data.childrenCount > 0
            self.scrollToBottom(animated: true)
        }
    }
    
    //=======================================================================//
    //MARK:- TextView
    override func textViewDidChange(_ textView: UITextView) {
        super.textViewDidChange(textView)
        if !self.isValidating {
            self.isValidating = true
            self.channelStillAlive { (isAlive: Bool) in
                self.isValidating = false
                if isAlive {
                    self.isTyping = textView.text != ""
                } else {
                    Alert.showFailiureAlert(message: "This channel does not exists anymore!", handler: { (_) in
                        self.toMainViewController()
                    })
                }
            }
        }
        
        
    }
    
    //=======================================================================//
    //MARK:- JSQMessagesCollectionView
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item]
        if message.senderId == self.senderId {
            return self.outgoingBubbleImageView
        } else {
            return self.incomingBubbleImageView
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        let message = messages[indexPath.item]
        
        if message.senderId == self.senderId {
            cell.textView.textColor = UIColor.white
        } else {
            cell.textView.textColor = UIColor.black
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        let message = messages[indexPath.item]
        
        if message.senderId == senderId {
            return nil
        } else {
            return NSAttributedString(string: message.senderDisplayName.components(separatedBy: "@").first!)
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat {
        
        let message: JSQMessage = messages[indexPath.item]
        var height:  CGFloat    = 0.0
        
        if message.senderId != self.senderId {
            if indexPath.item == 0 { //First message
                if message.senderId != self.senderId {
                    height += 17.0
                }
            } else { //Rest of messages
                let prevMessage = messages[indexPath.item-1]
                if message.senderId != prevMessage.senderId {
                    height += 17.0
                }
            }
        }
        return height
    }
    
    //=======================================================================//
    //MARK:- UI and User Interaction section
    private func emptyMessage() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        let color = UIColor.white
        return bubbleImageFactory!.incomingMessagesBubbleImage(with: color)
    }
    
    private func setupOutgoingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        let color = UIColor.jsq_messageBubbleBlue()
        return bubbleImageFactory!.outgoingMessagesBubbleImage(with: color)
    }
    
    private func setupIncomingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        let color = UIColor.jsq_messageBubbleLightGray()
        return bubbleImageFactory!.incomingMessagesBubbleImage(with: color)
    }
    
    
    //=======================================================================//
    //MARK:- Navigation
    private func toMainViewController () {
        if let splitController = self.splitViewController {
            if splitController.isCollapsed {
                let detailNC = self.parent as! UINavigationController
                let masterNC = detailNC.parent as! UINavigationController
                masterNC.popToRootViewController(animated: false)
            }
        }
    }
}

