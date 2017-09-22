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
        
        // No avatars
        self.collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        self.collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        
        //Necessary for SplitViewController proper behavior
        if auto {
            self.toMainViewController()
        } else {
            self.observeMessage()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK:- Creating, Sending and fetcing Messages
    private func addMessage(withId id: String, name: String, text: String) {
        if let message = JSQMessage(senderId: id, displayName: name, text: text) {
            messages.append(message)
        }
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        let itemRef = self.messageRef.childByAutoId()
        let messageItem = [
            "senderId":     self.senderId!,
            "senderName":   self.senderDisplayName,
            "text":         text!
        ]
        
        itemRef.setValue(messageItem)
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        finishSendingMessage()
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
    
    //MARK:- UI and User Interaction section
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

