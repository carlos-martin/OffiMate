//
//  PasswordViewController.swift
//  SingleSignUp
//
//  Created by Carlos Martin on 23/08/17.
//  Copyright © 2017 Carlos Martin. All rights reserved.
//

import Foundation
import UIKit

class PasswordViewController: UIViewController {
    
    //    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

////MARK: - TableView
//extension EmailViewController: UITableViewDelegate, UITableViewDataSource {
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
//    }
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 1
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = self.tableView.dequeueReusableCell(withIdentifier: "nameSignUpCell", for: indexPath) as! NameSignUpViewCell
//        cell.nameTextField.delegate = self
//        cell.nameTextField.placeholder = "Enter your name..."
//        cell.nameTextField.tag = indexPath.row
//        return cell
//    }
//
//    //Dismissing Keyboard
//    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
//        scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissMode.onDrag
//    }
//}
//
////MARK: - TextField
//extension EmailViewController: UITextFieldDelegate {
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        print(textField.tag)
//        self.view.endEditing(true)
//        return true
//    }
//}
