//
//  DetailViewController.swift
//  SingleSignUp
//
//  Created by Carlos Martin on 14/09/17.
//  Copyright © 2017 Carlos Martin. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var auto: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if auto {
            self.toMainViewController()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
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

extension DetailViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}
