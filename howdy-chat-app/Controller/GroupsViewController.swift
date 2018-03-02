//
//  GroupsViewController.swift
//  howdy-chat-app
//
//  Created by Brian  Crowley on 12/02/2018.
//  Copyright © 2018 Brian Crowley. All rights reserved.
//

import UIKit
import Firebase

class GroupsViewController: UIViewController {
    
    @IBOutlet weak var groupTableView : UITableView!
    @IBOutlet weak var menuButton: UIButton!
    
    var groupsArray = [Group]()
    var colorsArray = [UIColor]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        groupTableView.delegate = self
        groupTableView.dataSource = self
        menuButton.addTarget(self.revealViewController(), action: #selector(SWRevealViewController.revealToggle(_:)), for: .touchUpInside)
        if Auth.auth().currentUser == nil {
            guard let loginVC = storyboard?.instantiateViewController(withIdentifier: SBID_LOGIN_USER) as? LoginViewController else { return }
            present(loginVC, animated: true, completion: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        observeGroupDatabaseAndReloadOnUpdate()
    }
    
    func observeGroupDatabaseAndReloadOnUpdate () {
        DatabaseService.instance.REF_GROUPS.observe(.value) { (dataSnapshot) in
            DatabaseService.instance.getAllGroups(completion: { (groupsArray) in
                self.groupsArray = groupsArray
                while self.groupsArray.count != self.colorsArray.count {
                    self.colorsArray.append( HelperMethods.instance.getColorForCell(last: self.colorsArray.last))
                }
                self.groupTableView.reloadData()
            })
        }
    }
    
    @IBAction func menuButtonTapped (_ sender : Any) {
        print("GroupsViewController: Menu button tapped.")
    }
    
    @IBAction func addGroupButtonTapped (_ sender: Any) {
        print("GroupsViewController: Add group button tapped.")
        guard let addParticipantsVC = storyboard?.instantiateViewController(withIdentifier: SBID_ADD_PARTICIPANTS) else { return }
        presentDetail(addParticipantsVC)
    }
    
    @IBAction func unwindToGroupsViewController (segue:UIStoryboardSegue) {}
}

extension GroupsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: GROUP_CELL_ID, for: indexPath) as? GroupCell else {
            return UITableViewCell()
        }
        cell.backgroundCard.backgroundColor = self.colorsArray[indexPath.row]
        cell.configure(withGroup: groupsArray[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let chatVC = storyboard?.instantiateViewController(withIdentifier: SBID_CHAT) as? ChatViewController else { return }
        let cell = tableView.cellForRow(at: indexPath) as! GroupCell
        cell.responedToTap()
        DatabaseService.instance.getMembers(ids: groupsArray[indexPath.row].members) { (members) in
            chatVC.group = self.groupsArray[indexPath.row]
            chatVC.members = members
            
            cell.indicateSucces(completion: { _ in
                self.presentDetail(chatVC)
            })
        }
    }
}







