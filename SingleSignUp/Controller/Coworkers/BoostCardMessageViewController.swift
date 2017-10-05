//
//  BoostCardMessageViewController.swift
//  SingleSignUp
//
//  Created by Carlos Martin on 04/10/2017.
//  Copyright © 2017 Carlos Martin. All rights reserved.
//

import UIKit

class BoostCardMessageViewController: UIViewController {

    var coworker: Coworker?
    var type:     BoostCardType?
    var header:   String?
    
    @IBOutlet weak var frameImageView:    UIView!
    @IBOutlet weak var cardImageView:     UIImageView!
    @IBOutlet weak var headerLabel:       UILabel!
    @IBOutlet weak var coworkerLabel:     UILabel!
    @IBOutlet weak var textView:          UITextView!
    @IBOutlet weak var sendBarButtonItem: UIBarButtonItem!
    //for the keyboard
    @IBOutlet var keyboardHeightLayoutConstraint: NSLayoutConstraint?
    
    var tap: UITapGestureRecognizer = UITapGestureRecognizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initUI()
        
        //change view 
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.keyboardNotification(notification:)),
            name:     NSNotification.Name.UIKeyboardWillChangeFrame,
            object:   nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func initUI () {
        //MARK: boostCardImage
        self.frameImageView.layer.cornerRadius = 10
        switch type! {
        case .passion:
            self.cardImageView.image = UIImage(named: "passion-big")
            self.frameImageView.backgroundColor = Tools.redPassion
        case .execution:
            self.cardImageView.image = UIImage(named: "execution-big")
            self.frameImageView.backgroundColor = Tools.greenExecution
        }
        
        //MARK: headerLabel
        self.headerLabel.text = self.header!
        
        //MARK: coworkerLabel
        self.coworkerLabel.text = "to: \(self.coworker!.name)"
        
        //MARK: textView
        self.textView.delegate = self
        self.textView.text = "Why?"
        self.textView.textColor = UIColor.lightGray
    }
    
    @IBAction func sendBarButtonAction(_ sender: Any) {
        self.sendBarButtonItem.isEnabled = false
        if let message = self.textView.text {
            if !message.isEmpty && message != "Why?" {
                let boostCard = BoostCard(
                    senderId:   CurrentUser.user!.uid,
                    receiverId: self.coworker!.uid,
                    type:       self.type!,
                    header:     self.header!,
                    message:    message
                )
                Tools.createBoostCard(boostCard: boostCard)
                performSegue(withIdentifier: "unwindSegueToCoworkers", sender: self)
            } else {
                let error_message = "The message cannot be empty!"
                Alert.showFailiureAlert(message: error_message, handler: { (_) in
                    if !self.textView.isFirstResponder {
                        self.textView.becomeFirstResponder()
                    }
                    self.sendBarButtonItem.isEnabled = true
                })
            }
        }
        
    }
    
    
    @objc func keyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let endFrame: CGRect? =         (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let duration: TimeInterval =    (userInfo[UIKeyboardAnimationDurationUserInfoKey]as? NSNumber)?.doubleValue ?? 0
            let aniCurvRawNSN: NSNumber? =  userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let aniCurvRaw: UInt =          aniCurvRawNSN?.uintValue ?? UIViewAnimationOptions.curveEaseInOut.rawValue
            let aniCurv: UIViewAnimationOptions = UIViewAnimationOptions(rawValue: aniCurvRaw)
            if (endFrame?.origin.y)! >= UIScreen.main.bounds.size.height {
                self.keyboardHeightLayoutConstraint?.constant = 0.0
            } else {
                self.keyboardHeightLayoutConstraint?.constant = endFrame?.size.height ?? 0.0
            }
            UIView.animate(
                withDuration:   duration,
                delay:          TimeInterval(0),
                options:        aniCurv,
                animations:     { self.view.layoutIfNeeded() },
                completion:     nil)
        }
    }
}

extension BoostCardMessageViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Placeholder"
            textView.textColor = UIColor.lightGray
        }
    }
}
