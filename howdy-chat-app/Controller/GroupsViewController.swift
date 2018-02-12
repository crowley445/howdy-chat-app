//
//  GroupsViewController.swift
//  howdy-chat-app
//
//  Created by Brian  Crowley on 12/02/2018.
//  Copyright © 2018 Brian Crowley. All rights reserved.
//

import UIKit

class GroupsViewController: UIViewController {
    
    @IBOutlet weak var groupTableView : UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        groupTableView.delegate = self
        groupTableView.dataSource = self
    }
    
    @IBAction func menuButtonTapped (_ sender : Any) {
        print("GroupsViewController: Menu button tapped.")
    }
    
    @IBAction func addChannelButtonTapped (_ sender: Any) {
        print("GroupsViewController: Add group button tapped.")
    }
}

extension GroupsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: GROUP_CELL_ID, for: indexPath) as? GroupCell else {
            return UITableViewCell()
        }
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
}
