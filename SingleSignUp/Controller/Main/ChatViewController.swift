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
    var channel:    Channel? {
        didSet { self.title = channel?.name }
    }
    
    //Chat Firebase
    private lazy var messagesRef:         DatabaseReference = self.channelRef!.child("messages")
    private      var newMessageRefHandle: DatabaseHandle?
    
    //Typing Firebase
    private lazy var usersTypingQuery: DatabaseQuery =      self.channelRef!.child("typingIndicator").queryOrderedByValue().queryEqual(toValue: true)
    private lazy var usersIsTypingRef: DatabaseReference =  self.channelRef!.child("typingIndicator").child(self.senderId)
    private      var localTyping = false
    var isTyping: Bool {
        get { return localTyping }
        set { localTyping = newValue; usersIsTypingRef.setValue(newValue) }
    }
    
    //Chat UI
    lazy var outgoingBubble: JSQMessagesBubbleImage = self.setupOutgoingBubble()
    lazy var incomingBubble: JSQMessagesBubbleImage = self.setupIncomingBubble()
    
    //Channel is alive
    var isValidating: Bool = false
    let notExistsError = "This channel does not exists anymore!"
    
    //Data source
    var messages = [JSQMessage]() {
        didSet { messages.sort { $0.0.date < $0.1.date } }
    }
    var totalMessages: Int? {
        didSet { self.counter = self.totalMessages }
    }
    
    //Spinner data
    var spinner: SpinnerLoader?
    var counter: Int?
    
    //=======================================================================//
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.senderId = Auth.auth().currentUser?.uid ?? ""
        self.senderDisplayName = CurrentUser.name ?? ""
        
        //Necessary for SplitViewController proper behavior
        if self.auto {
            self.inputToolbar.isHidden = true
            self.toMainViewController()
        } else {
            self.initUI()
            self.channelStillAlive({ (isAlive: Bool) in
                if isAlive {
                    self.observeMessage()
                } else {
                    Alert.showFailiureAlert(message: self.notExistsError, handler: { (_) in
                        self.toMainViewController()
                    })
                }
            })
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !self.auto {
            self.observeTyping()
        }
    }
    
    //=======================================================================//
    //MARK:- UI Initializing
    private func initUI () {
        self.spinner = SpinnerLoader(view: self.view)
        self.collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        self.collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        self.inputToolbar.contentView.leftBarButtonItem = nil
        self.inputToolbar.contentView.textView.layer.cornerRadius = 12
        self.inputToolbar.contentView.textView.placeHolder = "Add new message..."
        self.scrollToBottom(animated: true)

        if Tools.iOS() > 10 {
            let navigationHeight = self.navigationController?.navigationBar.bounds.height
            let inputtoolHeight = self.inputToolbar.bounds.height
            
            self.collectionView.contentInset = UIEdgeInsetsMake(navigationHeight! + 12, 0, inputtoolHeight, 0)
            self.collectionView.scrollIndicatorInsets = self.collectionView.contentInset
        }
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
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        self.channelStillAlive { (isAlive: Bool) in
            if isAlive {
                let date = NewDate(date: Date())
                let itemRef = self.messagesRef.childByAutoId()
                let newMessageItem = [
                    "uid":  self.senderId!,
                    "text": text!,
                    "date": date.id
                    ] as [String : Any]
                itemRef.setValue(newMessageItem)
                JSQSystemSoundPlayer.jsq_playMessageSentSound()
                self.finishSendingMessage()
                self.isTyping = false
            } else {
                Alert.showFailiureAlert(message: self.notExistsError, handler: { (_) in
                    self.toMainViewController()
                })
            }
        }
    }
    
    private func observeMessage() {
        self.messagesRef = self.channelRef!.child("messages")
        let messageQuery = self.messagesRef.queryLimited(toLast: UInt(self.totalMessages!))
        
        if self.counter! > 0 {
            self.spinner?.start()
        }
        
        self.newMessageRefHandle = messageQuery.observe(.childAdded, with: { (snapshot: DataSnapshot) in
            let messageData = snapshot.value as! Dictionary<String, Any>

            if let uid = messageData["uid"] as? String, let text = messageData["text"] as? String, let date = messageData["date"] as? Int64 {
                Tools.fetchCoworker(uid: uid, completion: { (_, _name: String?, _) in
                    if let name = _name {
                        let message: JSQMessage
                        do {
                            let newDate = try NewDate(id: date)
                            message = JSQMessage(senderId: uid, senderDisplayName: name, date: newDate.date, text: text)
                        } catch {
                            message = JSQMessage(senderId: uid, displayName: name, text: text)
                        }
                        self.messages.append(message)
                        
                        self.counter! -= 1
                        if self.counter! <= 0 {
                            self.spinner?.stop()
                        }
                        
                        self.finishSendingMessage()
                    } else {
                        self.finishSendingMessage()
                    }
                })
            }
        })
    }
    
    private func observeTyping() {
        let typingIndicatorRef = channelRef!.child("typingIndicator")
        self.usersIsTypingRef = typingIndicatorRef.child(self.senderId)
        self.usersIsTypingRef.onDisconnectRemoveValue()
        self.usersTypingQuery.observe(.value) { (data: DataSnapshot) in
            if data.childrenCount == 1 && self.isTyping {
                return
            }
            self.showTypingIndicator = data.childrenCount > 0
            self.scrollToBottom(animated: true)
        }
    }
    
    //=======================================================================//
    //MARK:- JSQMessagesCollectionView
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        let message = messages[indexPath.item]
        if message.senderId == self.senderId {
            return message
        } else {
            let text = "\(message.senderDisplayName!)\n\(message.text!)"
            let finalMessage = JSQMessage(
                senderId: message.senderId!,
                senderDisplayName: message.senderDisplayName!,
                date: message.date!,
                text: text)
            return finalMessage
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item]
        if message.senderId == self.senderId {
            return self.outgoingBubble
        } else {
            return self.incomingBubble
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        
        let message = messages[indexPath.item]
        
        let font = cell.textView.font!
        
        if message.senderId == self.senderId {
            cell.textView.textColor = UIColor.white
        } else {
            let color = Tools.getColor(id: message.senderId)
            let attrs_name = [NSFontAttributeName : font, NSForegroundColorAttributeName : color]
            let attrs_text = [NSFontAttributeName : font, NSForegroundColorAttributeName : UIColor.black]
            let final_text = NSMutableAttributedString(string: message.senderDisplayName!+"\n", attributes: attrs_name)
            let array_text = message.text.components(separatedBy: "\n")
            let rawMessage = (array_text.count > 1 ? array_text.joined(separator: "\n") : array_text.first!)
            let message_text = NSMutableAttributedString(string: rawMessage, attributes: attrs_text)
            final_text.append(message_text)
            
            cell.textView.attributedText = final_text
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        let row = indexPath.row
        let currentMessage = self.messages[row]
        let currentDate = NewDate(date: currentMessage.date!)
        
        let timeStamp : NSAttributedString?
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.center
        
        if row == 0 {
            timeStamp = NSAttributedString(
                string:     currentDate.getChannelFormat(),
                attributes: [NSParagraphStyleAttributeName: paragraphStyle, NSBaselineOffsetAttributeName: NSNumber(value: 0)]
            )
        } else {
            let previousMessage = self.messages[row-1]
            let previousDate = NewDate(date: previousMessage.date)
            
            if currentDate.compare(date: previousDate) > 0 {
                timeStamp = NSAttributedString(
                    string:     NewDate(date: currentMessage.date!).getChannelFormat(),
                    attributes: [NSParagraphStyleAttributeName: paragraphStyle, NSBaselineOffsetAttributeName: NSNumber(value: 0)]
                )
            } else {
                timeStamp = nil
            }
        }
        return timeStamp
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat {
        let row = indexPath.row

        let height : CGFloat
        
        if row == 0 {
            height = 32.0
        } else {
            let currentDate =  NewDate(date: self.messages[row].date!)
            let previousDate = NewDate(date: self.messages[row-1].date)
            
            if currentDate.compare(date: previousDate) > 0 {
                height = 32.0
            } else {
                height = 0.0
            }
        }
        
        return height
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
                    Alert.showFailiureAlert(message: self.notExistsError, handler: { (_) in
                        self.toMainViewController()
                    })
                }
            }
        }
    }
    
    //=======================================================================//
}


//MARK:- Navigation
extension ChatViewController {
    func toMainViewController () {
        if let splitController = self.splitViewController {
            if splitController.isCollapsed {
                let detailNC = self.parent as! UINavigationController
                let masterNC = detailNC.parent as! UINavigationController
                masterNC.popToRootViewController(animated: false)
            }
        }
    }
}

//MARK:- JSQMessagesBubbleImage
extension ChatViewController {
    func emptyMessage() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        let color = UIColor.white
        return bubbleImageFactory!.incomingMessagesBubbleImage(with: color)
    }
    
    func setupOutgoingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        let color = UIColor.jsq_messageBubbleBlue()
        return bubbleImageFactory!.outgoingMessagesBubbleImage(with: color)
    }
    
    func setupIncomingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        let color = UIColor.jsq_messageBubbleLightGray()
        let bubble = bubbleImageFactory!.incomingMessagesBubbleImage(with: color)
        return bubble!
    }
}
