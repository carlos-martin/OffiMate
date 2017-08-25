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
    
    //MARK: IBOutlet
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: IBAction
    @IBAction func saveActionButton(_ sender: Any) {
        if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) {
            if self.readyToSave(cell: cell) {
                self.goToMain()
            } else {
                Tools.cellViewErrorAnimation(cell: cell)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Segue
    func readyToSave(cell: UITableViewCell) -> Bool {
        let isReady: Bool
        if let textField = (cell as! PasswordSignUpViewCell).passwordTextField {
            isReady = Tools.validateSingelPassword(pass: textField)
        } else {
            isReady = false
        }
        return isReady
    }
    
    func goToMain () {
        self.view.endEditing(true)
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
        controller?.modalPresentationStyle = .popover
        controller?.modalTransitionStyle = .flipHorizontal
        self.present(controller!, animated: true, completion: nil)
    }
}

//MARK: - TableView
extension PasswordViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "passSignUpCell", for: indexPath) as! PasswordSignUpViewCell
        cell.passwordTextField.delegate = self
        cell.passwordTextField.placeholder = "Enter password..."
        cell.passwordTextField.tag = indexPath.row
        return cell
    }

    //Dismissing Keyboard
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissMode.onDrag
    }
}

//MARK: - TextField
extension PasswordViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let works: Bool
        if let cell = self.tableView.cellForRow(at: IndexPath(row: textField.tag, section: 0)) {
            works = self.readyToSave(cell: cell)
            if works {
                self.goToMain()
            } else {
                Tools.cellViewErrorAnimation(cell: cell)
            }
        } else {
            works = false
        }
        return works
    }
}
