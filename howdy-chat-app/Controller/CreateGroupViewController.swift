//
//  CreateGroupViewController.swift
//  howdy-chat-app
//
//  Created by Brian  Crowley on 13/02/2018.
//  Copyright © 2018 Brian Crowley. All rights reserved.
//

import UIKit
import Firebase

class CreateGroupViewController: UIViewController {
    
    @IBOutlet weak var titleTextField : UITextField!
    @IBOutlet weak var descriptionTextField : UITextField!
    @IBOutlet weak var participantsView : UICollectionView!
    @IBOutlet weak var countLabel : UILabel!
    
    var addContactsVC : AddParticipantsViewController!
    var participants = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        participantsView.delegate = self
        participantsView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        countLabel.text  = "\(participants.count) OF \(addContactsVC.usersArray.count)"
    }
    
    @IBAction func backButtonTapped (_ sender: Any) {
        print("CreateGroupViewController: Back button tapped.\n")
        addContactsVC.participants = participants
        addContactsVC.filterUsersAndReloadTableView()
        dismissDetail()
    }
    
    @IBAction func createButtonTapped (_ sender: Any) {
        print("CreateGroupViewController: Create group button tapped.\n")
        
        guard let title = titleTextField.text, titleTextField.text != "",
                let description = descriptionTextField.text, descriptionTextField.text != "",
                    let currentId = Auth.auth().currentUser?.uid,
                        participants.count > 0
                            else { return }

        var ids = participants.map{ $0.uid }
        ids.append(currentId)
        
        DatabaseService.instance.createGroup(withTitle: title, andDescription: description, forUserIds: ids) { (success) in
            if !success {
                print ("CreateGroupViewController: Failed to create new group.\n")
            }
            print ("CreateGroupViewController: Successfully created new group.\n")
            self.performSegue(withIdentifier: UNWIND_TO_GROUPS, sender: nil)
        }
    }
    
}

extension CreateGroupViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return participants.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PARTICIPANTS_CELL_ID, for: indexPath) as? ContactCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.configure(withUser: participants[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        participants.remove(at: indexPath.row)
        countLabel.text  = "\(participants.count) OF \(addContactsVC.usersArray.count)"
        participantsView.reloadData()
    }
}
