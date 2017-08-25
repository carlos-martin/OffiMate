//
//  NameViewController.swift
//  SingleSignUp
//
//  Created by Carlos Martin on 22/08/17.
//  Copyright © 2017 Carlos Martin. All rights reserved.
//

import Foundation
import UIKit

class NameViewController: UIViewController {
    
    //MARK: IBOutlet
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: IBAction
    @IBAction func nextActionButton(_ sender: Any) {
        if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) {
            if self.readyToMove(cell: cell) {
                self.moveToEmail()
            } else {
                Tools.cellViewErrorAnimation(cell: cell)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.tableView.reloadData()
        self.startTextField()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func startTextField(){
        (self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! NameSignUpViewCell).nameTextField.becomeFirstResponder()
    }
    
    //MARK: Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //if segue.identifier == "toEmail", let nextScene = segue.destination as?
    }
    
    func readyToMove (cell: UITableViewCell) -> Bool {
        let isReady: Bool
        if let textField = (cell as! NameSignUpViewCell).nameTextField {
            isReady = !(textField.text?.isEmpty ?? true)
        } else {
            isReady = false
        }
        return isReady
    }
    
    func moveToEmail() {
        self.view.endEditing(true)
        performSegue(withIdentifier: "toEmail", sender: nil)
    }
}

//MARK: - TableView
extension NameViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "What's your name?"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "nameSignUpCell", for: indexPath) as! NameSignUpViewCell
        cell.nameTextField.delegate = self
        cell.nameTextField.placeholder = "Enter your name..."
        cell.nameTextField.tag = indexPath.row
        return cell
    }
    
    //Dismissing Keyboard
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissMode.onDrag
    }
}

//MARK: - TextField
extension NameViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let works: Bool
        if let cell = self.tableView.cellForRow(at: IndexPath(row: textField.tag, section: 0)) {
            works = self.readyToMove(cell: cell)
            if works {
                self.moveToEmail()
            } else {
                Tools.cellViewErrorAnimation(cell: cell)
            }
        } else {
            works = false
        }
        return works
    }
}
