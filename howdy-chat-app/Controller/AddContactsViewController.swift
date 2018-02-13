
import UIKit
import Firebase

class AddContactsViewController: UIViewController {
    
    @IBOutlet weak var usersTableView: UITableView!
    @IBOutlet weak var searchBar : UISearchBar!
    @IBOutlet weak var participantsCollectionView : UICollectionView!
    @IBOutlet weak var participantsCountLabel : UILabel!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    var usersArray = [User]()
    var filteredUserArray = [User]()
    var participants = [User]() {
        didSet{
            participantsCountLabel.text  = "\(participants.count) OF \(usersArray.count)"
            resizeCollectionView()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        usersTableView.delegate = self
        usersTableView.dataSource = self
        searchBar.delegate = self
        searchBar.returnKeyType = .done
        searchBar.isHidden = true
        participantsCollectionView.delegate = self
        participantsCollectionView.dataSource = self
        getAllUsersForDisplay()
    }

    func getAllUsersForDisplay () {
        DatabaseService.instance.getUsers { (users) in
            self.usersArray = users
            self.searchBar.isHidden = false
            self.filterUsersAndReloadTableView()
        }
    }
    
    func filterUsersAndReloadTableView () {
        if let query = searchBar.text, searchBar.text != "" {
            filteredUserArray = usersArray.filter{$0.name.contains(query)}
        } else{
            filteredUserArray = usersArray
        }
        participantsCountLabel.text  = "\(participants.count) OF \(usersArray.count)"
        usersTableView.reloadData()
    }
    
    @IBAction func backButtonPressed( _ sender: Any) {
        print("AddContactsViewController: Back button pressed.")
    }
    
    @IBAction func nextButtonPressed( _ sender: Any) {
        print("AddContactsViewController: Next button pressed.")
        guard let createGroupVC = storyboard?.instantiateViewController(withIdentifier: SBID_CREATE_GROUP) as? CreateGroupViewController else {
            return
        }
        createGroupVC.addContactsVC = self
        createGroupVC.participants = participants
        presentDetail(createGroupVC)
    }
}

extension AddContactsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredUserArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CONTACT_CELL_ID, for: indexPath) as? ContactCell else {
            return UITableViewCell()
        }
        cell.configure(withUser: filteredUserArray[indexPath.row], setSelected: !participants.contains(where: {$0.uid == filteredUserArray[indexPath.row].uid}))
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? ContactCell else { return }
        cell.toggleCheckmark()

        if let i = participants.index(where: {$0.uid == cell.user.uid}) {
            participants.remove(at: i)
        } else {
            participants.append(cell.user)
        }
        
        participantsCollectionView.reloadData()
        scrollToEndOfCollectionView()
    }
    
}

extension AddContactsViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterUsersAndReloadTableView()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
    }
}

extension AddContactsViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return participants.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PARTICIPANTS_CELL_ID, for: indexPath) as? ParticipantsCell else {
            return UICollectionViewCell()
        }
        cell.configure(withUser: participants[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        participants.remove(at: indexPath.row)
        participantsCollectionView.reloadData()
        usersTableView.reloadData()
    }
    
    func resizeCollectionView () {
        self.heightConstraint.constant = CGFloat(participants.count > 0 ? 120 : 1)
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    func scrollToEndOfCollectionView() {
        let item = collectionView(self.participantsCollectionView, numberOfItemsInSection: 0) - 1
        let index = IndexPath(item: item, section: 0)
        self.participantsCollectionView.scrollToItem(at: index, at: .centeredHorizontally, animated: false)
    }
}
