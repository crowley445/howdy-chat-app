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
    
    var groupsArray = [Group]()
    var colorsArray = [UIColor]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        groupTableView.delegate = self
        groupTableView.dataSource = self
        groupTableView.alpha = 0
        
        Auth.auth().addStateDidChangeListener { auth, user in
            if user == nil {
                let loginVC = self.storyboard?.instantiateViewController(withIdentifier: SBID_LOGIN_USER) as? LoginViewController
                self.present(loginVC!, animated: true, completion: nil)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        observeGroupDatabaseAndReloadOnUpdate()
    }
    
    func observeGroupDatabaseAndReloadOnUpdate () {
        DatabaseService.instance.REF_GROUPS.observe(.value) { (dataSnapshot) in
            DatabaseService.instance.getAllGroups(completion: { (groupsArray) in
                for group in groupsArray {
                    DatabaseService.instance.getMessagesFor(desiredGroup: group, completion: { (messages) in
                        group.messages = messages
                        self.groupsArray = groupsArray.reversed()
                        self.groupTableView.reloadData()
                    })
                }
                
                if self.groupTableView.alpha == 1 { return }
                
                UIView.animate(withDuration: 0.25, animations: {
                    self.groupTableView.alpha = 1
                })
            })
        }
    }

    @IBAction func addGroupButtonTapped (_ sender: Any) {
        print("GroupsViewController: Add group button tapped.")
        guard let addParticipantsVC = storyboard?.instantiateViewController(withIdentifier: SBID_ADD_PARTICIPANTS) else { return }
        present(addParticipantsVC, animated: true, completion: nil)
    }
    
    @IBAction func logoutButtonTapped (_ sender: Any) {
        print("GroupsViewController: Logout button tapped.")

        let popup = UIAlertController(title: "Logout?", message: "Are you sure you want to logout?", preferredStyle: .actionSheet)
        let logout_action = UIAlertAction(title: "Logout", style: .destructive) { (tapped) in
            do {
                try Auth.auth().signOut()
            } catch {
                 print("GroupsViewController: Logout failed. \(error)")
            }
        }
        let cancel_action = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            popup.dismiss(animated: true, completion: nil)
        }
        
        popup.addAction(logout_action)
        popup.addAction(cancel_action)
        
        present(popup, animated: true, completion: nil)
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
        cell.backgroundCard.backgroundColor = #colorLiteral(red: 0.1161550275, green: 0.1333996027, blue: 0.1527929688, alpha: 0)
        cell.configure(withGroup: groupsArray[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let chatVC = storyboard?.instantiateViewController(withIdentifier: SBID_CHAT) as? ChatViewController else { return }
        let cell = tableView.cellForRow(at: indexPath) as! GroupCell
        cell.responedToTap()
        DatabaseService.instance.getMembers(ids: groupsArray[indexPath.row].members) { (members) in
            chatVC.group = self.groupsArray[indexPath.row]            
            cell.indicateSucces(completion: { _ in
                self.presentDetail(chatVC)
            })
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {

        let leaveAction = UITableViewRowAction(style: .destructive, title: "LEAVE") { (rowAction, indexPath) in
            DatabaseService.instance.leave(Group: self.groupsArray[indexPath.row])
            self.groupsArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        
        leaveAction.backgroundColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)

        return [leaveAction]
    }
}
