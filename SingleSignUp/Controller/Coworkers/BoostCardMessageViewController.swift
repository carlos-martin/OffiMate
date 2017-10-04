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
    
    @IBOutlet weak var frameImageView: UIView!
    @IBOutlet weak var cardImageView:  UIImageView!
    @IBOutlet weak var headerLabel:    UILabel!
    @IBOutlet weak var coworkerLabel:  UILabel!
    @IBOutlet weak var textView:       UITextView!
    
    var tap: UITapGestureRecognizer = UITapGestureRecognizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initUI()
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
        self.textView.becomeFirstResponder()
        
        //MARK: tap
        self.tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
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
